## Assert Changes

### v0.8.x
* added more succinct `have_imeth` and `have_cmeth` macro methods
* deprecated assert-view sister repo
* `DefaultView` now provided by assert directly
* views render by defining callbacks that are fired by the runner
* added in the corresponding `not_*` method macros (#87)
* added in aliases for `assert_responds_to` assertion helpers (#86)
* added in `assert_file_exists` assertion helpers (#85)
* allows test files ending in `_tests.rb` to be recognized by rake task generator
* `DefaultView` syncs its io output
* README enhanced; added docs for view rendering and customization

### v0.7.x
* tests know context info (klass, called_from, file) (#62)
* suites track tests ungrouped
* fixed issue where method macros display incorrect fail traces
* fixed bug where 'assert_raises' and 'assert_nothing_raised' generate fail messages with trailing newlines
* default halt on failed assertions (#68)
* fixed for setup error when no $HOME env var (#76)
* changelog tracking (#79)
* removed past tense from Result model #to_sym (#75)
* showing exception class in Error result message (#64)
* don't show verbose loading statement when running rake tasks (#72)
* forced loading rubygems when running rake tasks (#65)
* removed warning if no test/helper present (#66)
* fix to not load helpers twice (#67)
* overhaul to how the rake tasks are generated and handled (#69)
* added name attr to Result model (#61)

### v0.6.x
* everything prior to changelog tracking...
