class Reporter
  attr_reader :date, :channel

  def initialize(date:, channel:)
    @date = date
    @channel = channel
  end

  def generate
    hitorigoto_list = Hitorigoto.fetch(@channel, @date)
    hitorigoto_list.empty? ? nil : to_markdown(hitorigoto_list)
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
end
