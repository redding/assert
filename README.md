# The Assert Testing Framework

Test::Unit style testing framework, just better than Test::Unit.

## Usage

```ruby
# in test/my_tests.rb

require 'assert'

class MyTests < Assert::Context

  test "something" do
    assert_equal 1, 1
  end

end
```

```
$ assert test/my_tests.rb
Loaded suite (1 test)
Running tests in random order, seeded with "56382"
.

1 result: pass

(0.000128 seconds, 7812.500000 tests/s, 7812.500000 results/s)
```

## What Assert is

* **Framework**: you define tests and the context they run in - Assert runs them.  Everything is pure ruby so use any 3rd party testing tools you like.  Create 3rd party tools that extend Assert behavior.
* **First Class**: everything is a first class object and can be extended to your liking (and should be)
* **MVC**: tests and how they are defined (M) and executed (C) are distinct from how you view the test results (V).
* **Backwards compatible**: (assuming a few minor tweaks) with Test::Unit test suites

## What Assert is not

* **Rspec**
* **Unit/Functional/Integration/etc**: Assert is agnostic - you define whatever kinds of tests you like (one or more of the above) and assert runs them in context.
* **Mock/Spec/BDD/etc**: Assert is the framework and there are a variety of 3rd party tools to do such things - feel free to use whatever you like.

## Description

Assert is a Test::Unit style testing framework.  This means you can write tests in Assert the same way you would with test-unit.

In addition, Assert adds some helpers and syntax sugar to enhance the way tests are written. Most are taken from ideas in [Shoulda](https://github.com/thoughtbot/shoulda) and [Leftright](https://github.com/jordi/leftright/).  Assert uses class-based contexts so if you want to nest your contexts, use inheritance.

**Note**: Assert is tested using itself.  The tests are a pretty good place to look for examples and usage patterns.

## Defining tests

TODO

## Factory

TODO

## Stub

```ruby
myclass = Class.new do
  def mymeth; 'meth'; end
  def myval(val); val; end
end
myobj = myclass.new

myobj.mymeth
  # => 'meth'
myobj.myval(123)
  # => 123
myobj.myval(456)
  # => 456

Assert.stub(myobj, :mymeth)
myobj.mymeth
  # => StubError: `mymeth` not stubbed.
Assert.stub(myobj, :mymeth){ 'stub-meth' }
myobj.mymeth
  # => 'stub-meth'
myobj.mymeth(123)
  # => StubError: arity mismatch
Assert.stub(myobj, :mymeth).with(123){ 'stub-meth' }
  # => StubError: arity mismatch

Assert.stub(myobj, :myval){ 'stub-meth' }
  # => StubError: arity mismatch
Assert.stub(myobj, :myval).with(123){ |val| val.to_s }
myobj.myval
  # => StubError: arity mismatch
myobj.mymeth(123)
  # => '123'
myobj.mymeth(456)
  # => StubError: `mymeth(456)` not stubbed.

Assert.unstub(myobj, :mymeth)

myobj.mymeth
  # => 'meth'
myobj.myval(123)
  # => 123
myobj.myval(456)
  # => 456
```

Assert comes with a simple stubbing API - all it does is replace method calls.  In general it tries
to be friendly and complain if stubbing doesn't match up with the object/method being stubbed:

* each stub takes a block that is called in place of the method
* complains if you stub a method that the object doesn't respond to
* complains if you stub with an arity mismatch
* no methods added to `Object`
* stubs are auto-unstubbed on test teardown

## CLI

```sh
$ assert --help
```

Assert ships with a CLI for running tests.  Test files must end in `_tests.rb` (or `_test.rb`).  The CLI globs any given file path(s), requires any test files, and runs the tests in them.

As an example, say your test folder has a file structure like so:

```
- test
|  - basic_tests.rb
|  - helper.rb
|  - complex_tests.rb
|  - complex
|  |  - fast_tests.rb
|  |  - slow_tests.rb
```

* `$ assert` - runs all tests ('./test' is used if no paths are given)
* `$ assert test/basic` - run all tests in basic_tests.rb
* `$ assert test/complex/fast_tests.rb` - runs all tests in fast_tests.rb
* `$ assert test/basic test/comp` - runs all tests in basic_tests.rb, complex_tests.rb, fast_tests.rb and slow_tests.rb

All you need to do is pass some sort of existing file path (hint: use tab-completion) and Assert will find any test files and run the tests in them.

## Configuring Assert

```ruby
Assert.configure do |config|
  # set your config options here
end
```

Assert uses a config pattern for specifying settings.  Using this pattern, you can configure settings, extensions, custom views, etc.  Settings can be configured in 4 different scopes and are applied in this order: User, Local, CLI, ENV.

### User settings

Assert will look for and require the file `$HOME/.assert/init.rb`.  Use this file to specify user settings.  User settings can be overridden by Local, CLI, and ENV settings.

### Local settings

Assert will look for and require the file `./.assert.rb`.  Use this file to specify project settings.  Local settings can be overridden by CLI, and ENV settings.

To specify a custom local settings file path, use the `ASSERT_LOCALFILE` env var.

### CLI settings

Assert accepts options from its CLI.  Use these options to specify runtime settings.  CLI settings can be overridden by ENV settings.

### ENV settings

Assert uses ENV vars to drive certain settings.  Use these vars to specify absolute runtime settings.  ENV settings are always applied last and cannot be overridden.

## Running Tests

Assert uses its [`Assert::Runner`](/lib/assert/runner.rb) to run tests.  You can extend this default runner or use your own runner implementation.  Specify it in your user/local settings:

```ruby
require 'my_awesome_runner_class'

Assert.configure do |config|
  config.runner MyAwesomeRunnerClass.new
end
```

### Test Dir

By default Assert expects tests in the `test` dir.  The is where it looks for the helper file and is the default path used when running `$ assert`.  To override this dir, do so in your user/local settings file:

```ruby
Assert.configure do |config|
  config.test_dir "testing"
end
```

### Test Helper File

By default Assert will look for a file named `helper.rb` in the `test_dir` and require it (if found) just before running the tests.  To override the helper file name, do so in your user/local settings file:

```ruby
Assert.configure do |config|
  config.test_helper "some_helpers.rb"
end
```

### Test Order

The default runner object runs tests in random order.  To run tests in a consistant order, specify a custom runner seed:

In user/local settings file:

```ruby
Assert.configure do |config|
  config.runner_seed 1234
end
```

Using the CLI:

```sh
$ assert [-s|--runner-seed] 1234
```

Using an ENV var:

```sh
$ ASSERT_RUNNER_SEED=1234 assert
```

### Capture Output

By default, Assert shows any output on `$stdout` produced while running a test.  It provides a setting to override whether to show this output or to 'capture' it and display it in the test result details:

In user/local settings file:

```ruby
Assert.configure do |config|
  config.capture_output true
end
```

Using the CLI:

```sh
$ assert [-o|--capture-output|--no-capture-output]
```

### Failure Handling

By default, Assert will halt test execution when a test produces a Fail result.  It provides a setting to override this default:

In user/local settings file:

```ruby
Assert.configure do |config|
  config.halt_on_fail false
end
```

Using the CLI:

```sh
$ assert [-t|--halt-on-fail|--no-halt-on-fail]
```

### Changed Only

By default, Assert loads every test file in the path(s) it is given and runs the tests in those files.  At times it is convenient to only run certain test files while you are actively developing on a feature.  Assert can detect which test files have changes and only load those files:

In user/local settings file:

```ruby
Assert.configure do |config|
  config.changed_only true  # not recommended - use the CLI with the `-c` flag
end
```

Using the CLI:

```sh
$ assert [-c|--changed-only|--no-changed-only]
```

#### Changed Test File Detection

The changed files are detected using two git commands by default:

```sh
git diff --no-ext-diff --name-only        # changed files
git ls-files --others --exclude-standard  # added files
```

The git cmds have ` -- #{test_paths}` appended to them to scope their results to just the test paths specified by the CLI and are run together using ` && `.

This, of course, assumes you are working in a git repository.  If you are not or you want to use custom logic to determine the changed files, configure a custom proc.  The proc should take two parameters: the config and an array of test paths specified by the CLI.

```ruby
Assert.configure do |config|
  config.changed_proc Proc.new do |config, test_paths|
    `git diff --name-only master -- #{test_paths.join(' ')}`.split("\n")  # or whatever
  end
end
```

If you just want to disable this feature completely:

```ruby
Assert.configure do |config|

  # run nothing if the `-c` flag is given
  config.changed_proc Proc.new{ |config, test_paths| [] }

  # run all test paths if the `-c` flag is given
  config.changed_proc Proc.new{ |config, test_paths| test_paths }

end
```

### Pretty Printing values in fail messages

By default, Assert uses `inspect` when outputting value details in failure messages.  At times you may want to pretty-print complex objects as their inspect value is not very human-readable.  You can tell Assert to pretty print the assertion objects instead.

In user/local settings file:

```ruby
Assert.configure do |config|
  config.pp_objects true
end
```

Using the CLI:

```sh
$ assert [-p|--pp-objects|--no-pp-objects]
```

#### Default pretty print processor

Assert uses the stdlib's `PP.pp` to pretty print objects by default.  This is provided by the `Assert::Utils.stdlib_pp_proc` util.

Using the default `inspect` (no pretty print):

```
$ assert

FAIL: a test that fails should fail
Expected nil, not {:now_usec=>164055, :string=>"a really really really really really really really really long string", :now=>Thu Nov 14 10:28:49 -0600 2013}.
```

Using the default pretty printing (`Assert::Utils.stdlib_pp_proc`):

```
$ assert -p

FAIL: a test that fails should fail
Expected nil, not
{:now_usec=>45127,
 :string=>
  "a really really really really really really really really long string",
 :now=>Thu Nov 14 10:28:35 -0600 2013}
.
```

You can customize the width used by `PP.pp` by overriding the default `pp_proc` setting:

```ruby
# set PP.pp width used to 1
Assert.configure do |config|
  config.pp_proc Assert::Utils.stdlib_pp_proc(1)
end
```
```
$ assert -p

FAIL: a test that fails should fail
Expected nil, not
{:now_usec=>
  984698,
 :string=>
  "a really really really really really really really really long string",
 :now=>
  Thu Nov 14 10:30:52 -0600 2013}
.
```

You can provide you own custom pretty-print processor if you like:

```ruby
# set not a very useful pretty print processor
Assert.configure do |config|
  config.pp_proc Proc.new{ |obj| "herp derp" }
end
```
```
$ assert -p

FAIL: a test that fails should fail
Expected nil, not herp derp.
```

Use this if you prefer a 3rd-party tool (like awesome_print or something) over the stdlib `PP.pp` for pretty printing.

## Viewing Test Results

`Assert::View::DefaultView` is the default handler for viewing test results.  Its output goes something like this:

* before the run starts, output some info about the test suite that is about to run
* print out result abbreviations as the test results are generated
* after the run finishes...
 * display any result details (from failing or error results) in reverse test/result order
 * output some summary info

You can run a test suite and get a feel for what this default outputs.  The view has a few options you can tweak:

* `styled`: whether to apply ANSI styles to the output, default `true`
* `pass_styles`: how to style pass result output, default `:green`
* `fail_styles`: default `:red, :bold`
* `error_styles`: default `:yellow, :bold`
* `skip_styles`: default `:cyan`
* `ignore_styles`: default: `:magenta`

To override an option, do so in your user/local settings:

```ruby
Assert.configure do |config|
  config.view.styled false
end
```

However, the view handler you use is itself configurable.  Define you own view handler class and specify it in your user/local settings:

```ruby
class MyCustomView < Assert::View::Base
  # define your view here...
end

Assert.configure do |config|
  config.view MyCustomView.new
end
```

### Anatomy of a View

A view class handles the logic and templating of test result output.  A view class should inherit from `Assert::View::Base`.  This defines default callback handlers for the test runner and gives access to a bunch of common helpers for reading test result data.

Each view should implement the callback handler methods to output information at different points during the running of a test suite.  Callbacks have access to any view methods and should output information using `puts` and `prints`.  See the `DefaultView` template for a usage example.

Available callbacks from the runner, and when they are called:

* `before_load`: at the beginning, before the suite is loaded, the test files are passed as an arg
* `after_load`: after the suite is loaded, just before `on_start`
* `on_start`: when a loaded test suite starts running
* `before_test`: before a test starts running, the test is passed as an arg
* `on_result`: when a running tests generates a result, the result is passed as an arg
* `after_test`: after a test finishes running, the test is passed as an arg
* `on_finish`: when the test suite is finished running

Beyond that, each view can do as it sees fit.  Initialize how you wish, take whatever settings you'd like, and output results as you see fit, given the available callbacks.

### Using 3rd party views

To use a 3rd party custom view, first require it in and then configure it.  Assert provides a helper for requiring in views.  It can be used in two ways.  You can pass a fully qualified path to the helper and if it exists, will require it in.

```ruby
Assert::View.require_user_view '/path/to/my/view'
```

Alternatively, you can install/clone/copy/write your view implementations in `~/.assert/views` and require it in by name.  To have assert require it by name, have it installed at `~/assert/views/view_name/lib/view_name.rb` (this structure is compatible with popular conventions for rubygem development). For example:

```ruby
# assuming ~/.assert/views/my-custom-view/lib/my-custom-view.rb exists
# this will require it in
Assert::View.require_user_view 'my-custom-view'
```

Once your view class is required in, use it and configure it just as you would any view.

## Assert Models

### Suite

A `Suite` object is reponsible for collecting and structuring tests and defines the set of tests to run using the test `Runner`.  Tests are grouped within the suite by their context.  Suite provides access to the contexts, tests, and test results.  In addition, the Suite model provides some stats (ie. run_time, runner_seed, etc...).

### Runner

A `Runner` object is responsible for running a suite of tests and firing event callbacks to the `View`.  Any runner object should take the test suite and view as arguments and should provide a 'run' method that runs the tests and renders the view.

### Context

A `Context` object is the scope that tests are run in.  When tests are run, a new instance of the test context is created and the test code is evaluated within the scope of this context instance.  Context provides methods for defining tests and test callbacks and for generating test results in running tests.  Subclass context classes to achieve nested context behavior.

### Test

A `Test` object defines the test code that needs to be run and the results generated by that test code.  Tests are aware of their context and are responsible for running their code in context.

### Result

A `Result` object defines the data related to a test result.  There are a few kinds of test results available:

* `Pass`
* `Fail`
* `Error`
* `Skip`
* `Ignore`

Tests produce results as they are executed.  Every `assert` statement produces a result.  Some results, like `Error` and `Skip`, will halt execution.  `Pass` and `Ignore` results do not halt execution.  `Fail` results, by default, halt execution but there is an option to have them not halt execution.  Therefore, tests can have many results of varying types.

### View

A `View` object is responsible for rendering test result output.  Assert provides a `Assert::View::Base` object to provide common helpers and default runner callback handlers for building views.  Assert also provides a `Assert::View::DefaultView` that it renders its output with.  See the "Viewing Test Results" section below for more details.

### Macro

Macros are procs that define sets of test code and make it available for easy reuse.  Macros work nicely with the 'should' and 'test' context methods.

## Installation

```
$ gem install assert
```

## Contributing

The source code is hosted on Github.  Feel free to submit pull requests and file bugs on the issues tracker.

If submitting a Pull Request, please:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

One note: please respect that Assert itself is intended to be the flexible, base-level, framework-type logic that should change little if at all.  Pull requests for niche functionality or personal testing philosphy stuff will likely not be accepted.

If you wish to extend Assert for your niche purpose/desire/philosophy, please do so in it's own gem (preferrably named `assert-<whatever>`) that uses Assert as a dependency.  When you do, tell us about it and we'll add it to this README with a short description.
