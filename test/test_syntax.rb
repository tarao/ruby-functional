require 'test/unit'
require File.join(File.dirname($0), 'lib')
require 'functional/lambda'

class ASyntaxTest < Test::Unit::TestCase
  def test_00_none()
    assert(!Lambda.lambda?(:_1))
    assert(!Lambda.lambda?(:_2))

    assert_raise(NoMethodError){ :+[1, 2].call }
  end

  def test_01_sym()
    Lambda::Syntax::Symbol.as_variable
    assert(Lambda.lambda?(:_1))
    assert(Lambda.lambda?(:_2))
  end

  def test_02_meth()
    Lambda::Syntax::Method.from_symbol[]
    assert_equal(3, :+[1, 2].call)
  end
end
