module HitorigotoReporter
  def self.configure(&block)
    @config = Config::Builder.new(&block).build
  end

  def self.configuration
    @config ||= configure {}
  end

  class Config
    attr_accessor :logger,
      :slack_access_token, :slack_target_channels, :slack_target_channels_delimiter,
      :esa_access_token, :esa_current_team, :esa_report_category

    def self.configure(&block)
      @config = Config::Builder.new(&block).build
    end

    def self.configuration
      @config ||= configure {}
    end

    def initialize
      @logger = Logger.new(STDOUT)
      @slack_target_channels_delimiter = ";"
    end

    class Builder
      def initialize(&block)
        @config = Config.new
        block.call(@config)
      end

      def build
        configure_slack
        @config
      end

      private

      def configure_slack
        Slack.configure do |config|
          config.token = @config.slack_access_token
        end
      end
    end
  end
end
