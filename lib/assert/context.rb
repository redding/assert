require 'assert/suite'

module Assert
  class Context

    # if a class subclasses Context, add it to the suite
    def self.inherited(klass)
      Assert.suite << klass
    end

    # put logic here to keep context instances pure for running tests
    class << self

    end

  end
end