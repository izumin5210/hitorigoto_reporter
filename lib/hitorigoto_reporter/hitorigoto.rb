module HitorigotoReporter
  class Hitorigoto
    attr_reader :username, :text, :permalink, :created_at, :stamps

    def initialize(json, stamps)
      @username   = json['username']
      @text       = json['text']
      @permalink  = json['permalink']
      @created_at = Time.at(json['ts'].to_f)
      @stamps     = stamps
    end

    def self.fetch(channel_name, target_date)
      date_query = target_date.strftime("%Y-%m-%d")
      query = ["on:#{date_query}", "in:#{channel_name}"].join(' ')
      res = Slack.client.search_messages(query: query)
      res['messages']['matches']
        .select { |m| m['type'] == 'message' }
        .map { |m|
          reaction = Slack.client.reactions_get(channel: m['channel']['id'], timestamp: m['ts'])
          stamps = reaction['message']['reactions'].map{ |r| r['name'] }
          Hitorigoto.new(m, stamps) 
        }
    end
  end
end
