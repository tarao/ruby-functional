require 'functional/internal'

class Proc
  class Curry
    def self.body(f, args, n)
      return args.length < n ? make(f, args, n) : f.call(*args)
    end

    def self.make(f, args, n)
      b = proc{|*x| body(f, args+x, n)}
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
