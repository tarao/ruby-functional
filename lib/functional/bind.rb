require 'functional/internal'

class Proc
  class Bind < Proc
    def self.fill(formal, actual)
      return formal.map do |a|
        if a.is_a?(Symbol) && a.argument_index?
          i = a.to_argument_index
          0 < i && i <= actual.length ? actual[i-1] : a
        elsif a.is_a?(self)
          a.call(*actual)
        else
          a
        end
      end
    end

    def self.make(f, args)
      return self.new do |*x|
        Internal.assert_arg_len(f, x.length,
                                proc{args.map{|a|max_index(a)}.max})
        f.call(*fill(args, x))
      end.__send__(:set_bind_args, args)
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
  def argument_index?() return to_s =~ /^_([1-9][0-9]*)$/ && $1.to_i end
  def to_argument_index() return argument_index? end
  def [](*args) return self.to_proc.bind(*args) end

  def method_missing(name, *args)
    if argument_index?
      name = name.to_s
      name = name[1..-1] if name =~ /^_/
      return name.to_sym[self, *args]
    end
    super
  end
end
