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

SLACK_TARGET_CHANNELS.split(';').each do |channel_name|
  target_date = Date.today - 1
  hitorigoto_list = Hitorigoto.fetch(channel_name, target_date)
  unless hitorigoto_list.empty?
    img_comments = Hash.new { |h, k| h[k] = [] }
    body_md = hitorigoto_list
      .reverse
      .map { |h| "### #{h.username} at [#{h.created_at.strftime('%T')}](#{h.permalink})\n#{h.text}" }
      .map { |md_raw|
        URI.extract(md_raw, ["http", "https"])
          .inject(md_raw) { |md, url|
            pattern = /uploaded a file: \<(?<url>#{url})\|(?<title>.+)\> and commented: ?(?<comment>.+)\n/
            replaced = md_raw.gsub(pattern, '\k<title>: \k<url>\k<comment><COMMENTS|\k<url>>')
            unless Regexp.last_match.nil?
              comment = Regexp.last_match[:comment]
              img_comments[url] << comment if !comment.empty? && !(/^\s*$/ =~ comment)
            end
            replaced
          }
      }
      .reject { |md|
        pattern = /commented on \<.+\>'s file \<(?<url>.+)\|.+\>: (?<comment>.+)/
        m = pattern.match(md)
        img_comments[m[:url]] << m[:comment] unless m.nil?
        !m.nil?
      }
      .map { |md_raw|
        pattern = /\<COMMENTS\|(?<url>.+)\>/
        m = pattern.match(md_raw)
        md = md_raw
        unless m.nil?
          md = md_raw.gsub(pattern, "\n\n" + img_comments[m[:url]].map { |c| "- #{c}" }.join("\n"))
        end
        md
      }
      .join("\n\n\n")

    category = target_date.strftime(ESA_REPORT_CATEGORY)

    client = Esa::Client.new(access_token: ESA_ACCESS_TOKEN, current_team: ESA_CURRENT_TEAM)
    client.create_post(name: channel_name, body_md: body_md, category: category, wip: false)
  end
end
