require 'bundler'
Bundler.require

require_relative 'lib/hitorigoto_reporter'

HitorigotoReporter.configure do |config|
  config.slack_access_token    = ENV['SLACK_ACCESS_TOKEN']
  config.slack_target_channels = ENV['SLACK_TARGET_CHANNELS']
  config.esa_access_token      = ENV['ESA_ACCESS_TOKEN']
  config.esa_current_team      = ENV['ESA_CURRENT_TEAM']
  config.esa_report_category   = ENV['ESA_REPORT_CATEGORY']
end

HitorigotoReporter::Reporter.new.report(Date.today - 1)
