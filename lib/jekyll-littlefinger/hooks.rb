require "jekyll-littlefinger/fingerprint"
require "jekyll"
require 'fileutils'

module Littlefinger
  module Hooks
    def self.merge_config(site)
      config = {
        "littlefinger" => {
          "include" => ["assets"],
          "environments" => ["production", "development"],
          "add_baseurl" => true
        }
      }

      unless site.config['exclude'].include? '_fingertmp'
        site.config['exclude'].push('_fingertmp')
      end

      Jekyll::Utils.deep_merge_hashes(config, site.config)
    end

    def self.build_temp_site(site)
      if self.should_fingerprint(site)
        config = {
          "destination" => self.temp_destination(site),
          "source" => site.config["source"]
        }

        config = Jekyll::Utils.deep_merge_hashes(site.config, config)

        puts "Creating #{config["destination"]} site..."
        site = Jekyll::Site.new(config)
        site.process
      end
    end

    def self.should_fingerprint(site)
      environments = site.config['littlefinger']['environments']
      destination = site.dest.split('/').last

      destination != "_fingertmp" && (environments.include? ENV["JEKYLL_ENV"])
    end

    def self.fingerprint_assets(site)
      if self.should_fingerprint(site)
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

    def self.temp_destination(site)
        destination_parent = File.expand_path("..", site.config["destination"])
        "#{destination_parent}/_fingertmp"
    end

    def self.cleanup(site)
      destination = site.dest.split('/').last
      temp_destination = self.temp_destination(site)

      if destination != "_fingertmp" && File.directory?(temp_destination)
        FileUtils.remove_dir temp_destination, true
      end
    end

    def self.init
      Jekyll::Hooks.register :site, :after_init do |site|
        site.config = self.merge_config(site)
      end

      Jekyll::Hooks.register :site, :pre_render do |site|
        self.build_temp_site(site)
      end

      Jekyll::Hooks.register :site, :post_write do |site|
        self.fingerprint_assets(site)
        self.cleanup(site)
      end
    end
  end
end

Littlefinger::Hooks.init
