class Reporter
  def report(date)
    target_channels.each do |channel|
      hitorigoto_list = Hitorigoto.fetch(channel, date)
      report = hitorigoto_list.empty? ? nil : to_markdown(hitorigoto_list)

      post_report(channel: channel, report: report, date: date) unless report.nil?
    end
  end

  private

  def to_markdown(hitorigoto_list)
    filtered_list, file_comments = filter(hitorigoto_list)

    filtered_list
      .reverse
      .map { |h| "### #{h.username} at [#{h.created_at.strftime('%T')}](#{h.permalink})\n#{format_body(h.text, file_comments)}" }
      .join("\n\n\n")
  end

  def filter(hitorigoto_list)
    file_comments = Hash.new { |h, k| h[k] = [] }

    filtered_list =
      hitorigoto_list.reject do |h|
        pattern = /commented on \<.+\>'s file \<(?<url>.+)\|.+\>: (?<comment>.+)/
        m = pattern.match(h.text)
        unless m.nil?
          file_comments[m[:url]] << "#{m[:comment]} by #{h.username} at [#{h.created_at.strftime('%T')}](#{h.permalink})"
        end
        !m.nil?
      end

    [filtered_list, file_comments]
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

  def post_report(channel:, report:, date:, wip: false)
    category = report_category(date)
    client.create_post(name: channel, body_md: report, category: category, wip: false)
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
