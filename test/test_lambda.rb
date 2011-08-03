require 'test/unit'
require File.join(File.dirname($0), 'lib')
require 'functional/lambda'

class LambdaVariableTest < Test::Unit::TestCase
  Variable = Lambda::Internal::Variable

  def test_methods()
    assert(Variable.new(:foo).respond_to?(:argument_index?))
    assert(Variable.new(:foo).respond_to?(:to_argument_index))
    assert(Variable.new(:foo).respond_to?(:[]))
  end

  def test_argument_index()
    assert(!Variable.new(:foo).argument_index?)
    assert(!Variable.new(:_0).argument_index?)
    assert(Variable.new(:_1).argument_index?)
    assert(Variable.new(:_2).argument_index?)
    assert(Variable.new(:_34567).argument_index?)
    assert(!Variable.new(:_3456a7).argument_index?)

    assert_equal(3, Variable.new(:_3).to_argument_index)
    assert_equal(4, Variable.new(:_4).to_argument_index)
    assert_equal(5678, Variable.new(:_5678).to_argument_index)
  end

  def test_bind()
    v1 = Variable.new(:_1)
    v2 = Variable.new(:_2)
    v3 = Variable.new(:_3)
    assert_equal(5, v1[5])
    assert_equal(3, v3[1, 2, 3])
    assert_equal(6, :+[v1, v1][3], 6)
    assert_equal(2, :-[v2, v1][3, 5])
    assert_equal([ 2, 6, 12 ], [ 1, 2, 3 ].map(&:+[v1, :*[v1, v1]]))
  end
end

class LambdaTest < Test::Unit::TestCase
  include Lambda::Variable
  include Lambda::Statement

  def test_var()
    assert_equal(2, :-[_2, _1][3, 5])
    assert_equal(2, (_2 - _1)[3, 5])
  end

  def test_object()
    assert_equal(3, 3._)
    assert_equal("hoge", "hoge"._)
    assert_equal(3, :_[:_1][3])
    assert_equal(1, 1.to_lambda[])
    assert_equal(2, (5.to_lambda - :_1)[3])
    assert_equal(1, :_[1][])
    assert_equal(2, (:_[5] - :_1)[3])
  end

  def test_send()
    x = {}
    def x.hoge() return 1 end
    assert_equal(1, :_1.hoge[x])
    assert_equal(4, (:_1.hoge + 3)[x])

    assert_equal([4, 5, 6], [1, 2, 3].map(& :_1 + 3 ))
    assert_equal([16, 20, 24], [1, 2, 3].map(& (:_1 + 3)*4 ))
    assert_equal(['16', '20', '24'], [1, 2, 3].map(& :to_s[ (:_1 + 3)*4 ] ))
  end

  def test_if()
    assert_equal(3, if_(true){ _1 }[3])
    assert_equal(3, if_(_1 > 2){ _1 }[3])
    assert_equal(nil, if_(_1 < 2){ _1 }[3])
    assert_equal(9, if_(_1 < 2){ _1 }.else_{ _1 * _1 }[3])
    assert_equal(nil, if_(_1 < 2){ _1 }.elsif_(_1 < 3){ _1 * _1 }[3])
    assert_equal(9, if_(_1 < 2){ _1 }.elsif_(_1 < 4){ _1 * _1 }[3])
    assert_equal(3, unless_(false){ _1 }[3])
    assert_equal(3, unless_(_1 < 2){ _1 }[3])
    assert_equal(nil, unless_(_1 > 2){ _1 }[3])
    assert_equal(9, unless_(_1 > 2){ _1 }.else_{ _1 * _1 }[3])
    assert_equal(nil, unless_(_1 > 2){ _1 }.elsif_(_1 < 3){ _1 * _1 }[3])
    assert_equal(9, unless_(_1 > 2){ _1 }.elsif_(_1 < 4){ _1 * _1 }[3])
  end
end
