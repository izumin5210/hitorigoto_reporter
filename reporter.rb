require 'bundler'
Bundler.require

require 'date'
require_relative 'hitorigoto'

Dotenv.load

SLACK_ACCESS_TOKEN    = ENV['SLACK_ACCESS_TOKEN']
SLACK_TARGET_CHANNELS = ENV['SLACK_TARGET_CHANNELS']
ESA_ACCESS_TOKEN      = ENV['ESA_ACCESS_TOKEN']
ESA_CURRENT_TEAM      = ENV['ESA_CURRENT_TEAM']
ESA_REPORT_CATEGORY   = ENV['ESA_REPORT_CATEGORY']

Slack.configure do |config|
  config.token = SLACK_ACCESS_TOKEN
end

SLACK_TARGET_CHANNELS.split(';').each do |channel_name|
  body_md = Hitorigoto.fetch(channel_name)
    .reverse
    .map { |h| "- [#{h.created_at.strftime('%T')}](#{h.permalink}): #{h.text}" }
    .join("\n")

  category = Date.today.strftime(ESA_REPORT_CATEGORY)

  client = Esa::Client.new(access_token: ESA_ACCESS_TOKEN, current_team: ESA_CURRENT_TEAM)
  client.create_post(name: channel_name, body_md: body_md, category: category, wip: false)
end
