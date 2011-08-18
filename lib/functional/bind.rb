require 'functional/util'
require 'functional/curry'
require 'functional/bind/trait'
require 'functional/bind/internal'

class Proc
  class Bind < Proc
    Variable = Trait::Variable

    class Syntax
      class Symbol
        def self.as_variable()
          return if ::Symbol <= Trait::Variable
          ::Symbol.class_eval do
            def [](*args) super end
            include Trait::Variable
          end
        end
      end

      class Method
        def self.from_symbol()
          return proc{} if ::Symbol <= Trait::Method
          return proc do
            ::Symbol.class_eval do
              def [](*args) super end
              include Trait::Method
            end
          end
        end
      end
    end

    def self.var(n=1)
      v = "_#{n}"
      class << v; include Trait::Variable end
      return v
    end

    attr_reader :bind_args
    def bind_arity() return bind_args.map{|a| self.class.max_index(a)}.max end
    def curry(n=nil) return Curry.curry(self, n || bind_arity) end
  end

  def bind(*args)
    marity = arity
    marity = -marity - 1 if marity < 0

    Functional::Util.assert_arg_len(self, args.length, marity)
    return Bind.make(self, args)
  end
end
