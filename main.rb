require 'bundler'
Bundler.require

require 'date'
require 'uri'
require 'logger'
require_relative 'reporter'
require_relative 'hitorigoto'

SLACK_ACCESS_TOKEN    = ENV['SLACK_ACCESS_TOKEN']
SLACK_TARGET_CHANNELS = ENV['SLACK_TARGET_CHANNELS']
ESA_ACCESS_TOKEN      = ENV['ESA_ACCESS_TOKEN']
ESA_CURRENT_TEAM      = ENV['ESA_CURRENT_TEAM']
ESA_REPORT_CATEGORY   = ENV['ESA_REPORT_CATEGORY']

Slack.configure do |config|
  config.token = SLACK_ACCESS_TOKEN
end

logger = Logger.new(STDOUT)

SLACK_TARGET_CHANNELS.split(';').each do |channel_name|
  date = Date.today - 1
  reporter = Reporter.new(date: date, channel: channel_name)
  report = reporter.generate

  unless report.nil?
    category = date.strftime(ESA_REPORT_CATEGORY)

    client = Esa::Client.new(access_token: ESA_ACCESS_TOKEN, current_team: ESA_CURRENT_TEAM)
    client.create_post(name: channel_name, body_md: report, category: category, wip: false)

    logger.debug("Posted #{category}/#{channel_name} to #{ESA_CURRENT_TEAM}.esa.io")
  end
end
