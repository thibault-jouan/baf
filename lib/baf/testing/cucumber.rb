require 'baf/testing'
require 'baf/testing/cucumber/steps/execution'
require 'baf/testing/cucumber/steps/filesystem'
require 'baf/testing/cucumber/steps/output'

$_baf = {}

Around do |_, block|
  Baf::Testing.exercise_scenario block
  $_baf.delete :process
end
