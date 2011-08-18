require 'functional/util'

class Proc
  class Curry
    def self.body(f, args, n, &block)
      if args.length < n
        warn('given block not used') if block
        return make(f, args, n)
      else
        return f.call(*args, &block)
      end
    end

    if RUBY_VERSION >= '1.9'
      def self.make(f, args, n)
        b = proc{|*x, &p| body(f, args+x, n, &p)}
        return Functional::Util.may_send(f, :lambda?) ? lambda(&b) : proc(&b)
      end
    else
      def self.make(f, args, n)
        b = proc{|*x| body(f, args+x, n)}
        return Functional::Util.may_send(f, :lambda?) ? lambda(&b) : proc(&b)
      end
    end

    def self.curry(p, n=nil)
      marity = p.arity
      marity = -marity - 1 if marity < 0

      if n
        Functional::Util.assert_arg_len(p, n, marity)
      else
        n = marity
      end

      return make(p, [], n)
    end
  end

  unless RUBY_VERSION >= '1.9'
    def curry(n=nil) return Curry.curry(self, n) end
  end
end
