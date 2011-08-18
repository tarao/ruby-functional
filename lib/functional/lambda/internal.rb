module Lambda
  module Internal
    class Variable
      include Proc::Bind::Variable
      include Expression

      def initialize(v) @v = v end
      def to_s() return @v.to_s end
      def bind_arity() return to_argument_index end
    end

    class If < Proc::Bind
      include Statement

      if RUBY_VERSION >= '1.9'
        def self.empty_block?(block) return block.arity == 0 end
      else
        def self.empty_block?(block) return block.arity == -1 end
      end

      def self.bind(&block)
        block = block.call if empty_block?(block)
        block = block.to_lambda
        return block
      end

      def bind_arity()
        return [ :cond, :then, :else ].map{|x| @holder[x].bind_arity}.max
      end

      def else_(&block)
        @holder[:else] = self.class.bind(&block)
        return self
      end

      def elsif_(cond, &block)
        @holder[:else] = if_(cond, &block)
        return self
      end

      private

      def set_place_holder(holder)
        @holder = holder
        return self
      end
    end
  end
end
