require "jekyll-littlefinger/hooks"
require "jekyll"
require 'uri'

module Jekyll
  module AssetFilter
    def fingerprint(input)
      if should_fingerprint?
        fingerprint_path(input)
      else
        add_baseurl(input)
      end
    end

    private

    def fingerprint_path(input)
      site = @context.registers[:site]

      dest_parent = File.expand_path("../", site.dest)
      input = input.gsub('./', '')
      temp_asset_path = File.join(dest_parent, '_fingertmp', input)

      fingerprint_asset_path = Fingerprint.new(temp_asset_path).path.gsub('/_fingertmp', '')
      asset_parent = File.dirname(input)
      fingerprint_name = File.basename(fingerprint_asset_path)

      add_cdn(add_baseurl("#{asset_parent}/#{fingerprint_name}"))
    end

    def add_baseurl(input)
      site = @context.registers[:site]
      base_url = site.config['baseurl']
      add_baseurl = site.config['littlefinger']['add_baseurl']
      if add_baseurl &&  !base_url.nil? && !base_url.empty?
        input = input.gsub('./', '')

        "#{base_url}/#{input}"
      else
        input
      end
    end

    def add_cdn(input)
      site = @context.registers[:site]
      cdnurl = site.config['littlefinger']['cdnurl']

      if cdnurl.nil? && cdnurl.empty?
        input
      else
        URI.join(cdnurl, input).to_s
      end
    end

    def should_fingerprint?
      site = @context.registers[:site]
      environments = site.config['littlefinger']['environments']
      destination = site.dest.split('/').last

      destination != "_fingertmp" && (environments.include? environment)
    end

    def environment
      ENV["JEKYLL_ENV"].nil? ? "development" : ENV["JEKYLL_ENV"]
    end
  end
end

Liquid::Template.register_filter(Jekyll::AssetFilter)
