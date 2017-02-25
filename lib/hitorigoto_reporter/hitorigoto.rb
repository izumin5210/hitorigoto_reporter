module HitorigotoReporter
  class Hitorigoto
    attr_reader :username, :text, :permalink, :created_at, :stamps

    def initialize(json, stamps = [])
      @username   = json['username']
      @text       = json['text']
      @permalink  = json['permalink']
      @created_at = Time.at(json['ts'].to_f)
      @stamps     = stamps
    end

    class << self
      def fetch(channel_name, target_date)
        date_query = target_date.strftime("%Y-%m-%d")
        query = ["on:#{date_query}", "in:#{channel_name}"].join(' ')
        fetch_all(query: query)
      end

      private

      def fetch_all(query:)
        list = []
        loop.with_index(1) do |_, i|
          res = Slack.client.search_messages(query: query, page: i)
          list += extract_higorigoto_list_from_res(res)
          break if complete?(res)
        end
        list
      end

      def extract_higorigoto_list_from_res(res)
        res['messages']['matches']
          .select { |m| m['type'] == 'message' }
          .map { |m|
            reaction = Slack.client.reactions_get(channel: m['channel']['id'], timestamp: m['ts'])
            stamps = (reaction['message']['reactions'] || []).map { |r| r['name'] }
            Hitorigoto.new(m, stamps) 
          }
      end

      def complete?(res)
        res['messages']['paging'].tap { |paging| break paging['page'] >= paging['pages'] }
      end
    end
  end
end
