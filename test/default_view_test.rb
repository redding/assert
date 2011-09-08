require 'assert'
require 'assert/setup/view'

module Assert

  class DefaultViewTests < Assert::Context
    desc "assert's default view"
    subject { Assert.options.default_view }

    should "be the DefaultView" do
      assert_kind_of View::DefaultView, subject
    end

  end

end
