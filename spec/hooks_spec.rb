require "spec_helper"
require "jekyll-littlefinger/hooks"

RSpec.describe Littlefinger::Hooks do
  ENV['JEKYLL_ENV'] = "production"
  let(:overrides) { Hash.new }
  let(:config) do
    Jekyll.configuration(Jekyll::Utils.deep_merge_hashes({
      "full_rebuild" => true,
      "source"       => source_dir,
      "destination"  => dest_dir,
      "show_drafts"  => true,
      "url"          => "http://example.org",
      "name"         => "My awesome site",
      "author"       => {
        "name"        => "Dr. Jekyll"
      },
      "plugins"     => ["jekyll-littlefinger"],
      "collections" => {
        "my_collection" => { "output" => true },
        "other_things"  => { "output" => false }
      }
    }, overrides))
  end
  let(:site)     { Jekyll::Site.new(config) }
  let(:context)  { make_context(site: site) }
  before(:each) do
    site.process
  end

  it "fingerprints assets" do
    expect(Pathname.new(dest_dir("assets/style-7495849f4def68c781c127f2f25864f4.css"))).to exist
  end
end

