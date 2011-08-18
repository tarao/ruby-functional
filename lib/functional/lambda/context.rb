module Lambda
  class Context
    include Lambda::Primitive
    include Lambda::Variable
    include Lambda::Statement
  end

  def eval(&block) return Context.new.instance_eval(&block) end
  module_function :eval
end
