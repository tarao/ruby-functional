class Proc
  class Bind < Proc
    module Trait
      module Variable
        def argument_index?()
          return to_s =~ /^_([1-9][0-9]*)?$/ && ($1||1).to_i
        end

        def to_argument_index() return argument_index? end
        def bind_arity() return to_argument_index end
        def [](*args) return call(*args) if argument_index? end

        def call(*args)
          i = to_argument_index - 1
          return args[i] if argument_index? && i < args.length
          return self
        end
      end

      module Method
        def [](*args)
          return super if argument_index?
          return to_proc.bind(*args)
        end
      end
    end
  end
end
