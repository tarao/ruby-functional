class Proc
  class Internal
    def self.assert_arg_len(f, n, arity)
      arity = arity[] if arity.is_a?(Proc)
      seq = (f.arity < 0)
      if f.respond_to?(:lambda?) && f.lambda? && (n<arity || (n>arity && !seq))
        msg = 'wrong number of arguments (%d for %d)' % [ n, arity ]
        raise ArgumentError, msg
      end
      return true
    end
  end
end
