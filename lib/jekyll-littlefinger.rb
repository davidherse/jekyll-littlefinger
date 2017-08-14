require "jekyll-littlefinger/hooks"
require "jekyll"

module Jekyll
  module AssetFilter
    def fingerprint(input)
      if ENV['JEKYLL_ENV'] == "production"
        path = relative_path(Fingerprint.new("./_fingertmp#{input}").path).gsub('/_fingertmp', '')

        "#{site.config['littlefinger']['cdnurl']}#{path}"
      else
        relative_url(input)
      end
    end

    private
    
    def sanitized_baseurl
      site = @context.registers[:site]
      site.config["baseurl"].to_s.chomp("/")
    end

    def relative_path(input)
      return if input.nil?
      parts = [sanitized_baseurl, input]
      Addressable::URI.parse(
        parts.compact.map { |part| ensure_leading_slash(part.to_s) }.join
      ).normalize.to_s
    end
  end
end

Liquid::Template.register_filter(Jekyll::AssetFilter)
