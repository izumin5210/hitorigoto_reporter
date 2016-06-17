require 'bundler'
Bundler.require

require 'date'
require 'uri'
require_relative 'hitorigoto'

SLACK_ACCESS_TOKEN    = ENV['SLACK_ACCESS_TOKEN']
SLACK_TARGET_CHANNELS = ENV['SLACK_TARGET_CHANNELS']
ESA_ACCESS_TOKEN      = ENV['ESA_ACCESS_TOKEN']
ESA_CURRENT_TEAM      = ENV['ESA_CURRENT_TEAM']
ESA_REPORT_CATEGORY   = ENV['ESA_REPORT_CATEGORY']

Slack.configure do |config|
  config.token = SLACK_ACCESS_TOKEN
end

def format_body(text, file_comments)
  URI.extract(text, ["http", "https"]).inject(text) do |md, url|
    pattern = /uploaded a file: \<(?<url>#{url})\|(?<title>.+)\>(:? and commented: ?(?<comment>.+)\n)?/
    replaced = md.gsub(pattern, '\k<title>: \k<url>')
    unless Regexp.last_match.nil?
      comment = Regexp.last_match[:comment]
      file_comments[url].unshift(comment) if !comment.nil? && !comment.empty? && !(/^\s*$/ =~ comment)
      replaced += "\n\n" + file_comments[url].map { |c| "- #{c}" }.join("\n")
    end
    replaced
  end
end

SLACK_TARGET_CHANNELS.split(';').each do |channel_name|
  target_date = Date.today - 1
  hitorigoto_list = Hitorigoto.fetch(channel_name, target_date)
  unless hitorigoto_list.empty?
    file_comments = Hash.new { |h, k| h[k] = [] }

    hitorigoto_list.reject! do |h|
      pattern = /commented on \<.+\>'s file \<(?<url>.+)\|.+\>: (?<comment>.+)/
      m = pattern.match(h.text)
      unless m.nil?
        file_comments[m[:url]] << "#{m[:comment]} by #{h.username} at [#{h.created_at.strftime('%T')}](#{h.permalink})"
      end
      !m.nil?
    end

    body_md = hitorigoto_list
      .reverse
      .map { |h| "### #{h.username} at [#{h.created_at.strftime('%T')}](#{h.permalink})\n#{format_body(h.text, file_comments)}" }
      .join("\n\n\n")

    category = target_date.strftime(ESA_REPORT_CATEGORY)

    client = Esa::Client.new(access_token: ESA_ACCESS_TOKEN, current_team: ESA_CURRENT_TEAM)
    client.create_post(name: channel_name, body_md: body_md, category: category, wip: false)
  end
end
