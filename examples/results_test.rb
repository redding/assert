require 'assert'

class ResultsTest < Assert::Context

  def test_that_passes
    assert 1==1
  end

  def test_that_fails
    assert 1==0
  end

  def test_that_skips
    skip
  end

  def test_that_errors
    raise Exception
  end

end
