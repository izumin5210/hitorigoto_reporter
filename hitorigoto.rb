require 'slack'

class Hitorigoto
  attr_reader :username, :text, :permalink, :created_at

  def initialize(json)
    @username   = json['username']
    @text       = json['text']
    @permalink  = json['permalink']
    @created_at = Time.at(json['ts'].to_f)
  end

  def self.fetch(channel_name)
    today = Date.today.strftime("%Y-%m-%d")
    query = ["on:#{today}", "in:#{channel_name}"].join(' ')
    res = Slack.client.search_messages(query: query)
    res['messages']['matches']
      .select { |m| m['type'] == 'message' }
      .map { |m| Hitorigoto.new(m) }
  end
end
