require 'test/unit'
require File.join(File.dirname($0), 'lib')
require 'functional/curry'

class CurryTest < Test::Unit::TestCase
  def test_methods()
    assert(Proc.new{}.respond_to?(:curry))
    assert(proc{}.respond_to?(:curry))
    assert(lambda{}.respond_to?(:curry))
  end

  def test_Proc1()
    b = Proc.new{|x, y, z| (x||0) + (y||0) + (z||0)}
    assert_equal(6, b.curry[1][2][3])
    assert_equal(6, b.curry[1][2][3])
    assert_equal(6, b.curry[1, 2][3, 4])
    assert_equal(6, b.curry(5)[1][2][3][4][5])
    assert_equal(6, b.curry(5)[1, 2][3, 4][5])
    assert_equal(1, b.curry(1)[1])
  end

  def test_Proc2()
    b = Proc.new{|x, y, z, *w| (x||0) + (y||0) + (z||0) + w.inject(0, &:+)}
    assert_equal(6, b.curry[1][2][3])
    assert_equal(10, b.curry[1, 2][3, 4])
    assert_equal(15, b.curry(5)[1][2][3][4][5])
    assert_equal(15, b.curry(5)[1, 2][3, 4][5])
    assert_equal(1, b.curry(1)[1])
  end

  def test_Proc3()
    b = Proc.new{ :foo }
    assert_equal(:foo, b.curry[])
  end

  def test_proc1()
    b = proc{|x, y, z| (x||0) + (y||0) + (z||0)}
    assert_equal(6, b.curry[1][2][3])
    assert_equal(6, b.curry[1][2][3])

    if RUBY_VERSION >= '1.9'
      assert_equal(6, b.curry[1, 2][3, 4])
      assert_equal(6, b.curry(5)[1][2][3][4][5])
      assert_equal(6, b.curry(5)[1, 2][3, 4][5])
      assert_equal(1, b.curry(1)[1])
    else
      assert_raise(ArgumentError){ b.curry[1, 2][3, 4] }
      assert_raise(ArgumentError){ b.curry(5)[1][2][3][4][5] }
      assert_raise(ArgumentError){ b.curry(5)[1, 2][3, 4][5] }
      assert_raise(ArgumentError){ b.curry(1)[1] }
      assert_nothing_raised{ b.curry(5) }
      assert_nothing_raised{ b.curry(1) }
    end
  end

  def test_proc2()
    b = proc{|x, y, z, *w| (x||0) + (y||0) + (z||0) + w.inject(0, &:+)}
    assert_equal(6, b.curry[1][2][3])
    assert_equal(10, b.curry[1, 2][3, 4])
    assert_equal(15, b.curry(5)[1][2][3][4][5])
    assert_equal(15, b.curry(5)[1, 2][3, 4][5])

    if RUBY_VERSION >= '1.9'
      assert_equal(1, b.curry(1)[1])
    else
      assert_raise(ArgumentError){ b.curry(1)[1] }
      assert_nothing_raised{ b.curry(1) }
    end
  end

  def test_proc3()
    b = proc{ :foo }
    assert_equal(:foo, b.curry[])
  end

  def test_lambda1()
    b = lambda{|x, y, z| (x||0) + (y||0) + (z||0)}
    assert_equal(6, b.curry[1][2][3])
    assert_raise(ArgumentError){ b.curry[1, 2][3, 4] }
    assert_raise(ArgumentError){ b.curry(5)[1][2][3][4][5] }
    assert_raise(ArgumentError){ b.curry(1)[1] }

    if RUBY_VERSION >= '1.9'
      assert_raise(ArgumentError){ b.curry(5) }
      assert_raise(ArgumentError){ b.curry(1) }
    else
      assert_nothing_raised{ b.curry(5) }
      assert_nothing_raised{ b.curry(1) }
    end
  end

  def test_lambda2()
    b = lambda {|x, y, z, *w| (x||0) + (y||0) + (z||0) + w.inject(0, &:+)}
    assert_equal(6, b.curry[1][2][3])
    assert_equal(10, b.curry[1, 2][3, 4])
    assert_equal(15, b.curry(5)[1][2][3][4][5])
    assert_equal(15, b.curry(5)[1, 2][3, 4][5])
    assert_raise(ArgumentError){ b.curry(1)[1] }

    if RUBY_VERSION >= '1.9'
      assert_raise(ArgumentError){ b.curry(1) }
    else
      assert_nothing_raised{ b.curry(1) }
    end
  end
end
