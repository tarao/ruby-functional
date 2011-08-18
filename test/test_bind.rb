require 'test/unit'
require File.join(File.dirname($0), 'lib')
require 'functional/bind'

class ProcBindTest < Test::Unit::TestCase
  def setup()
    Proc::Bind::Syntax::Symbol.as_variable
    Proc::Bind::Syntax::Method.from_symbol[]
  end

  def test_methods()
    assert(Proc.new{}.respond_to?(:bind))
    assert(proc{}.respond_to?(:bind))
    assert(lambda{}.respond_to?(:bind))
  end

  def test_bind()
    assert_equal(7, proc{|x,y,z| x+y*z}.bind(:_1, :_2, :_3)[1,2,3])
    assert_equal(5, proc{|x,y,z| x+y*z}.bind(:_3, :_2, :_1)[1,2,3])
    assert_equal(12, proc{|x,y,z| x+y*z}.bind(:_3, :_3, :_3)[1,2,3])
  end

  def test_arg_len()
    assert_nothing_raised{ proc{|x,y,z| x+y*z}.bind(:_1, :_2, :_3)[1,2,3] }
    assert_nothing_raised{ proc{|x,y,z| x+y*z}.bind(:_1, :_2, :_3)[1,2,3,4] }
    assert_nothing_raised{ proc{|x| x}.bind(:_1)[1] }
    assert_nothing_raised{ proc{|x| x}.bind(:_3)[1,2,3] }

    assert_raise(ArgumentError){ lambda{|x,y,z| x+y*z}.bind(:_1)[1] }
    assert_raise(ArgumentError){ lambda{|x,y,z| x+y*z}.bind(:_1)[1,2,3] }
    assert_raise(ArgumentError){ lambda{|x,y| x}.bind(:_1, :_2, :_3)[1,2,3] }

    if RUBY_VERSION >= '1.9'
      assert_nothing_raised{ proc{|x,y,z| x}.bind(:_1)[1] }
      assert_nothing_raised{ proc{|x,y,z| x}.bind(:_1)[1,2,3] }
      assert_nothing_raised{ proc{|x,y| x}.bind(:_1, :_2, :_3)[1,2,3] }
      assert_raise(ArgumentError){ lambda{|x,y,z| x}.bind(:_1) }
      assert_raise(ArgumentError){ lambda{|x,y,*z| x}.bind(:_1) }
      assert_nothing_raised{ lambda{|x,*y| x}.bind(:_1) }
      assert_raise(ArgumentError){ lambda{|x| x}.bind(:_1, :_2) }
      assert_nothing_raised{ lambda{|x,*y| x}.bind(:_1, :_2) }
    else
      assert_raise(ArgumentError){ proc{|x,y,z| x+y*z}.bind(:_1)[1] }
      assert_raise(ArgumentError){ proc{|x,y,z| x+y*z}.bind(:_1)[1,2,3] }
      assert_raise(ArgumentError){ proc{|x,y| x}.bind(:_1, :_2, :_3)[1,2,3] }
      assert_nothing_raised{ lambda{|x,y,z| x+y*z}.bind(:_1) }
      assert_nothing_raised{ lambda{|x,y,*z| x}.bind(:_1) }
      assert_nothing_raised{ lambda{|x,*y| x}.bind(:_1) }
      assert_nothing_raised{ lambda{|x| x}.bind(:_1, :_2) }
      assert_nothing_raised{ lambda{|x,*y| x}.bind(:_1, :_2) }
    end
  end

  def test_nest1()
    b = :+.to_proc.bind(:_1, :*.to_proc.bind(:_1, :_1))
    assert_equal([ 2, 6, 12 ], [ 1, 2, 3 ].map(&b))
  end

  def test_nest2()
    foo = proc{|x| x+1}
    bar = proc{|x,y| x-y}

    assert_equal(4, foo.bind(:_1)[3])
    assert_equal(-3, bar.bind(1, :_1).bind(:_2)[3, 4])
  end

  def test_curry()
    b = :+.to_proc.bind(:_1, :-.to_proc.bind(:_2, :_3)).curry
    assert_equal(0, b[1][2][3])
  end
end

class SymbolBindTest < Test::Unit::TestCase
  def setup()
    Proc::Bind::Syntax::Symbol.as_variable
    Proc::Bind::Syntax::Method.from_symbol[]
  end

  def test_methods()
    assert(:foo.respond_to?(:argument_index?))
    assert(:foo.respond_to?(:to_argument_index))
    assert(:foo.respond_to?(:[]))
  end

  def test_argument_index()
    assert(!:foo.argument_index?)
    assert(!:_0.argument_index?)
    assert(:_1.argument_index?)
    assert(:_2.argument_index?)
    assert(:_34567.argument_index?)
    assert(!:_3456a7.argument_index?)

    assert_equal(3, :_3.to_argument_index)
    assert_equal(4, :_4.to_argument_index)
    assert_equal(5678, :_5678.to_argument_index)
  end

  def test_bind()
    assert_equal(5, :_1[5])
    assert_equal(3, :_3[1, 2, 3])
    assert_equal(6, :+[:_1, :_1][3], 6)
    assert_equal(2, :-[:_2, :_1][3, 5])
    assert_equal([ 2, 6, 12 ], [ 1, 2, 3 ].map(&:+[:_1, :*[:_1, :_1]]))
  end

  def test_block()
    if RUBY_VERSION >= '1.9'
      m = proc{|r,&p| r.map(&p)}
      assert_equal([ 2, 6, 12 ], m.bind([1,2,3]).call(&:+[:_1, :*[:_1, :_1]]))
      assert_equal([ 2, 6, 12 ], :map[ [1,2,3] ].[](&:+[:_1, :*[:_1, :_1]]))
    end
  end
end
