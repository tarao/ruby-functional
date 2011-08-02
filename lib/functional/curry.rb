require 'functional/internal'

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

    def self.make(f, args, n)
      b = proc{|*x, &p| body(f, args+x, n, &p)}
      return (f.respond_to?(:lambda?) && f.lambda?) ? lambda(&b) : proc(&b)
    end
  end

  def curry(n = nil)
    marity = arity
    marity = -marity - 1 if marity < 0

    if n
      Internal.assert_arg_len(self, n, marity)
    else
      n = marity
    end

    return Curry.make(self, [], n)
  end
end
