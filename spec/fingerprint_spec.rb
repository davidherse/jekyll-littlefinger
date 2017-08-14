require "spec_helper"
require "jekyll-littlefinger/fingerprint"

RSpec.describe Fingerprint do
  context "with a path to a file" do
    subject { Fingerprint.new('./spec/fixtures/assets/style.css') }

    it "returns a full path and filename with fingerprint" do
      expect(subject.path).to eq("./spec/fixtures/assets/style-7495849f4def68c781c127f2f25864f4.css")
    end
  end
end

