require "jekyll-littlefinger/fingerprint"
require "jekyll"

module Littlefinger
  def self.merge_config(site)
    config = {
      "littlefinger" => {
        "cdnurl" => '', 
        "include" => ["assets"] 
      }
    }

    unless site.config['exclude'].include? '_fingertmp'
      site.config['exclude'].push('_fingertmp')
    end

    Jekyll::Utils.deep_merge_hashes(config, site.config)
  end

  def self.build_temp_site(site)
    if site.dest.split('/').last != "_fingertmp" && ENV['JEKYLL_ENV'] == "production"
      destination_parent = File.expand_path("..", site.config["destination"])
      destination = "#{destination_parent}/_fingertmp"

      puts "Creating #{destination} site..."
      puts `JEKYLL_ENV=development jekyll build --destination #{destination}`
    end
  end

  def self.fingerprint_assets(site)
    if site.dest.split('/').last != "_fingertmp" && ENV['JEKYLL_ENV'] == "production"

      puts "\n   Fingerprinting images..."
      includes = site.config['littlefinger']['include']

      includes.each do |path|
        if File.directory?("#{site.config["destination"]}/#{path}")
          assets = Dir["#{site.config["destination"]}/#{path}/**/*"]

          assets.each do |asset|
            unless File.directory?(asset)
              fingerprint = Fingerprint.new(asset)
              new_path = fingerprint.path
              puts "   renaming #{asset} to #{new_path}"

              File.rename(asset, new_path)
            end
          end

        else
          asset = "#{site.config["destination"]}/#{path}"
          fingerprint = Fingerprint.new(asset)
          new_path = fingerprint.path
          puts "   renaming #{asset} to #{new_path}"

          File.rename(asset, new_path)
        end
      end
      puts "\n"
    end
  end

  def self.setup_hooks
    Jekyll::Hooks.register :site, :after_init do |site|
      site.config = self.merge_config(site)
    end

    Jekyll::Hooks.register :site, :pre_render do |site|
      self.build_temp_site(site)
    end

    Jekyll::Hooks.register :site, :post_write do |site|
      self.fingerprint_assets(site)
    end
  end
end

Littlefinger.setup_hooks
