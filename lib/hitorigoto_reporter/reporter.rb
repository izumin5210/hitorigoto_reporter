module HitorigotoReporter
  class Reporter
    def report(date)
      target_channels.each do |channel|
        hitorigoto_list = Hitorigoto.fetch(channel, date)
        formatter = Formatter.new(hitorigoto_list)
        if formatter.empty?
          logger.debug("#{channel} has no hitorigoto on #{date.strftime("%Y-%m-%d")}")
        else
          post_report(channel: channel, report: formatter.to_markdown, date: date, tags: formatter.stamps)
        end
      end
    end

    private

    def post_report(channel:, report:, date:, wip: false, tags:)
      category = report_category(date)
      client.create_post(name: channel, body_md: report, category: category, wip: false, user: config.esa_user, tags: tags)
      logger.debug("Posted #{category}/#{channel} to #{config.esa_current_team}.esa.io")
    end

    def config
      HitorigotoReporter.configuration
    end

    def target_channels
      config.slack_target_channels.split(config.slack_target_channels_delimiter)
    end

    def client
      Esa::Client.new(access_token: config.esa_access_token, current_team: config.esa_current_team)
    end

    def report_category(date)
      date.strftime(config.esa_report_category)
    end

    def logger
      config.logger
    end
  end
end
