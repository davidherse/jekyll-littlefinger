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
