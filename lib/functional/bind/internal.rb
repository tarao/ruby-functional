class Proc
  class Bind < Proc
    def self.index?(obj)
      return Functional::Util.may_send(obj, :argument_index?)
    end

    def self.body(f, formal, actual, &block)
      Functional::Util.assert_arg_len(f, actual.length,
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
      return Functional::Util.may_send(obj, :bind_arity) || 0
    end

    private

    def set_bind_args(args) @bind_args = args; return self end
  end
end
