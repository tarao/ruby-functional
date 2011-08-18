require 'test/unit'
require File.join(File.dirname($0), 'lib')
require 'functional/lambda'

class ContextTest < Test::Unit::TestCase
  def test_global()
    assert_raise(NoMethodError){ protect() }
    assert_raise(NameError){ _1 }
    assert_raise(NoMethodError){ if_(true){} }
  end

  def test_context()
    assert_nothing_raised{ Lambda.eval{ protect(nil) } }
    assert_nothing_raised{ Lambda.eval{ _1 } }
    assert_nothing_raised{ Lambda.eval{ if_(true){} } }
  end
end
