require 'functional/internal'

class Proc
  class Bind < Proc
    module Variable
      def argument_index?()
        return to_s =~ /^_([1-9][0-9]*)?$/ && ($1||1).to_i
      end

      def to_argument_index() return argument_index? end
      def [](*args) return call(*args) if argument_index? end

      def call(*args)
        i = to_argument_index - 1
        return args[i] if argument_index? && i < args.length
        return self
      end
    end

    def self.index?(obj)
      return obj.respond_to?(:argument_index?) && obj.argument_index?
    end

    def self.body(f, formal, actual, &block)
      Internal.assert_arg_len(f, actual.length,
                              proc{formal.map{|a|max_index(a)}.max})
      return f.call(*fill(formal, actual), &block)
    end

    def self.fill(formal, actual)
      return formal.map{|a| index?(a) || a.is_a?(self) ? a.call(*actual) : a}
    end

    if RUBY_VERSION >= '1.9'
      def self.make(f, args)
        return self.new do |*x, &p|
          body(f, args, x, &p)
        end.__send__(:set_bind_args, args)
      end
    else
      def self.make(f, args)
        return self.new do |*x|
          body(f, args, x)
        end.__send__(:set_bind_args, args)
      end
    end

    def self.max_index(obj)
      if obj.is_a?(Symbol) && obj.argument_index?
        return obj.to_argument_index
      elsif obj.is_a?(self)
        return obj.bind_arity
      else
        return 0
      end
    end

    attr_reader :bind_args
    def bind_arity() bind_args.map{|a| self.class.max_index(a)}.max end

    private

    def set_bind_args(args) @bind_args = args; return self end
  end

  def bind(*args)
    marity = arity
    marity = -marity - 1 if marity < 0

    Internal.assert_arg_len(self, args.length, marity)
    return Bind.make(self, args)
  end
end

class Symbol
  include Proc::Bind::Variable

  def [](*args)
    return super if argument_index?
    return to_proc.bind(*args)
  end
end
