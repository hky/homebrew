class Patches
  # The patches defined in a formula and the DATA from that file
  def initialize patches
    @patches = []
    return if patches.nil?
    n = 0
    normalize_patches(patches).each do |patch_p, urls|
      # Wrap the urls list in an array if it isn't already;
      # DATA.each does each line, which doesn't work so great
      urls = [urls] unless urls.kind_of? Array
      urls.each do |url|
        patch_class = detect_patch_class(url)
        patch = patch_class.new(patch_p, '%03d-homebrew.diff' % n, url)
        @patches << patch
        n += 1
      end
    end
  end

  def external_patches?
    not external_curl_args.empty?
  end

  def each(&blk)
    @patches.each(&blk)
  end
  def empty?
    @patches.empty?
  end

  def download!
    # Get external patches.
    # Downloading all at once is much more efficient, especially for FTP.
    curl_args = external_curl_args
    curl(*curl_args) unless curl_args.empty?

    @patches.each{|p| p.stage!}
  end

private

  def looks_like_url str
    str =~ %r[^\w+\://]
  end

  def detect_patch_class(url)
    if url.kind_of? File
      DataPatch
    elsif looks_like_url(url)
      ExternalPatch
    else
      FilePatch
    end
  end

  def external_patches
     @patches.select{|p| p.external?}
  end

  # Collects the urls and output names of all external patches
  def external_curl_args
    external_patches.collect{|p| p.curl_args}.flatten
  end

  def normalize_patches patches
    if patches.kind_of? Hash
      patches
    else
      { :p1 => patches } # We assume -p1
    end
  end

end

# Base class for Patch classes.
# All patches need a -p argument and a filename
class Patch
  def initialize patch_p, filename, external
    @patch_p = patch_p
    @patch_filename = Pathname.new(filename)
    @external = external
  end

  def patch_args
    ["-#{@patch_p}", '-i', @patch_filename]
  end

  def external?
    @external
  end

  # Subclasses can override as needed
  def stage!; end
end

# A patch class for handling inline (DATA / __END__) patches
class DataPatch < Patch
  def initialize patch_p, filename, data_file
    super(patch_p, filename, false)
    @data_file = data_file
  end

  # Do any supported substitutions of HOMEBREW vars in a DATA patch
  def brew_var_substitution s
    s.gsub("HOMEBREW_PREFIX", HOMEBREW_PREFIX)
  end

  def compression; :none; end

  def stage!
    @patch_filename.write(brew_var_substitution(@data_file.read.to_s))
  end
end

class FilePatch < Patch
  def initialize patch_p, ignored, local_path
    super(patch_p, local_path, false)
  end

  def compression; :none; end
end

class ExternalPatch < Patch
  # Used by formula to unpack after downloading
  attr_reader :compression
  attr_reader :compressed_filename
  # Used by audit
  attr_reader :url

  def initialize patch_p, filename, url
    super(patch_p, filename, true)

    @compressed_filename = nil
    @compression = nil

    if url =~ /#/
      @url, digest = url.split('#', 2)
    else
      @url = url
      digest = nil
    end
    @checksum = detect_checksum(digest)
  end

  # rename the downloaded file to take compression into account
  # verify the file if a checksum is given
  def stage!
    # Verify the download; but if no checksum was given
    # skip this step, for compatibility
    unless @checksum.nil?
      @patch_filename.verify_checksum @checksum
    end

    detect_compression!

    case @compression
    when :gzip
      @compressed_filename = @patch_filename.to_s + '.gz'
      FileUtils.mv @patch_filename, @compressed_filename
    when :bzip2
      @compressed_filename = @patch_filename.to_s + '.bz2'
      FileUtils.mv @patch_filename, @compressed_filename
    end
  end

  def curl_args
    [@url, '-o', @patch_filename]
  end

private

  # Detect which type of checksum is being used, or nil.
  # Use the length of the checksum string to determine the type.
  def detect_checksum digest
    return nil if digest.nil?
    case digest.size
    when 32 then Checksum.new(:md5, digest)
    when 40 then Checksum.new(:sha1, digest)
    when 64 then Checksum.new(:sha256, digest)
    else raise "Invalid digest #{digest}"
    end
  end

  # Detect compression type from the downloaded patch.
  def detect_compression!
    # If compression is nil we have not tried to detect yet
    if @compression.nil?
      if @patch_filename.exist?
        @compression = @patch_filename.compression_type
        @compression ||= :none # If nil, convert to :none
      end
    end
  end

end
