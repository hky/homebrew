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
        @patches << Patch.new(patch_p, '%03d-homebrew.diff' % n, url)
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
    return unless external_patches?

    # downloading all at once is much more efficient, especially for FTP
    curl(*external_curl_args)

    external_patches.each{|p| p.stage!}
  end

private

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

class Patch
  # Used by formula to unpack after downloading
  attr_reader :compression
  attr_reader :compressed_filename
  # Used by audit
  attr_reader :url

  def initialize patch_p, filename, url
    @patch_p = patch_p
    @patch_filename = filename
    @compressed_filename = nil
    @compression = nil
    @url = nil
    @checksum = nil

    if url.kind_of? File # true when DATA is passed
      write_data url
    elsif looks_like_url(url)
      @url = url
      @url, @checksum = @url.split('#', 2) if @url =~ /#/
    else
      # it's a file on the local filesystem
      # use URL as the filename for patch
      @patch_filename = url
    end
  end

  # rename the downloaded file to take compression into account
  # verify the file if a checksum is given
  def stage!
    return unless external?

    # Verify the download; but if no checksum was given
    # skip this step, for compatibility
    type = checksum_type
    unless type.nil?
      type = type.to_s.upcase
      hasher = Digest.const_get(type)
      hash = Pathname.new(@patch_filename).incremental_hash(hasher)
      message = <<-EOF
#{type} mismatch
Expected: #{@checksum}
Got: #{hash}
Patch: #{@url}
EOF
      raise message unless @checksum.upcase == hash.upcase
    end

    detect_compression!

    case @compression
    when :gzip
      @compressed_filename = @patch_filename + '.gz'
      FileUtils.mv @patch_filename, @compressed_filename
    when :bzip2
      @compressed_filename = @patch_filename + '.bz2'
      FileUtils.mv @patch_filename, @compressed_filename
    end
  end

  def external?
    not @url.nil?
  end

  def patch_args
    ["-#{@patch_p}", '-i', @patch_filename]
  end

  def curl_args
    [@url, '-o', @patch_filename]
  end

private

  # Detect which type of checksum is being used, or nil.
  # Use the length of the checksum string to determine the type.
  def checksum_type
    return nil if @checksum.nil?
    case @checksum.size
    when 32 then :md5
    when 40 then :sha1
    when 64 then :sha256
    else raise "Invalid checksum #{@checksum}"
    end
  end

  # Detect compression type from the downloaded patch.
  def detect_compression!
    # If nil we have not tried to detect yet
    if @compression.nil?
      path = Pathname.new(@patch_filename)
      if path.exist?
        @compression = path.compression_type
        @compression ||= :none # If nil, convert to :none
      end
    end
  end

  # Write the given file object (DATA) out to a local file for patch
  def write_data f
    pn = Pathname.new @patch_filename
    pn.write(brew_var_substitution(f.read.to_s))
  end

  # Do any supported substitutions of HOMEBREW vars in a DATA patch
  def brew_var_substitution s
    s.gsub("HOMEBREW_PREFIX", HOMEBREW_PREFIX)
  end

  def looks_like_url str
    str =~ %r[^\w+\://]
  end
end
