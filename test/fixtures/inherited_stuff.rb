module MixinStuff
  def test_mixin_stuff
    "from mixin"
  end

  def mixednottestmeth
    "mixed in not test meth"
  end
end

class SuperStuff
  def superclass_stuff
    "from superclass"
  end

  def other_stuff
    "super not test meth"
  end

end

class SubStuff
  include MixinStuff

  def test_subclass_stuff
    "from subclass"
  end

  def nottestmeth
    "not test meth"
  end

  def more_other_stuff
    "more other stuff"
  end
end
