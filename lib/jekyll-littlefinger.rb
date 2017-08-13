require "jekyll-littlefinger/version"
require "jekyll"

module Littlefinger
  class Fingerprint
    def initialize(asset)
      @asset = asset
    end

    def path
      extn = File.extname  @asset 
      asset_name = File.basename @asset, extn
      fingerprint = Digest::MD5.hexdigest(File.read(@asset))
      dirname = File.dirname(@asset)

      new_path = "#{dirname}/#{asset_name}-#{fingerprint}#{extn}"
    end
  end

  Jekyll::Hooks.register :site, :after_init do |site|
    unless site.config['exclude'].include? '_fingertmp'
      site.config['exclude'].push('_fingertmp')
    end

    unless site.config.key?("littlefinger")
      site.config['littlefinger'] = { cdnurl: '', include: ["assets"] }
    end

    unless site.config['littlefinger'].key?("cdnurl")
      site.config['littlefinger']['cdnurl'] = ""
    end

    unless site.config['littlefinger'].key?("include")
      site.config['littlefinger']['include'] = ["assets"]
    end
  end

  Jekyll::Hooks.register :site, :pre_render do |site|
    puts 'hi there!!!'
    if site.dest.split('/').last != "_fingertmp" && ENV['JEKYLL_ENV'] == "production"
      puts "Creating _fingertmp site..."
      puts `JEKYLL_ENV=development jekyll build --destination _fingertmp`
    end
  end

  Jekyll::Hooks.register :site, :post_write do |site|
    if site.dest.split('/').last != "_fingertmp" && ENV['JEKYLL_ENV'] == "production"

      puts "\n   Fingerprinting images..."

      includes = site.config['littlefinger']['include']

      includes.each do |path|
        if File.directory?("./_site/#{path}")
          assets = Dir["./_site/#{path}/**/*"]

          assets.each do |asset|
            unless File.directory?(asset)
              fingerprint = Fingerprint.new(asset)
              new_path = fingerprint.path
              puts "   renaming #{asset} to #{new_path}"

              File.rename(asset, new_path)
            end
          end

        else
          asset = "./_site/#{path}"
          fingerprint = Fingerprint.new(asset)
          new_path = fingerprint.path
          puts "   renaming #{asset} to #{new_path}"

          File.rename(asset, new_path)
        end
      end
      puts "\n"
    end
  end

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
end
