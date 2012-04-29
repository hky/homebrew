# Determine the compression type of a file on disk
#
# For most file types, detect using magic bytes, as some
# downloaded files will not have a proper extension name.

def determine_file_compression path
  # Don't treat jars as compressed
  return nil if path.extname == '.jar'

  # OS X installer package
  return :pkg if path.extname == '.pkg'

  # get the first six bytes
  magic_bytes = nil
  File.open(path) { |f| magic_bytes = f.read(6) }

  # magic numbers stolen from /usr/share/file/magic/
  case magic_bytes
  when /^PK\003\004/   # zip
    return :zip
  when /^\037\213/     # gzip
    return :gzip
  when /^BZh/          # bz2
    return :bz2
  when /^\037\235/     # compress
    return :compress
  when /^\xFD7zXZ\x00/ # xz compressed
    return :xz
  when /^Rar!/
    return :rar
  else
    # Assume it is not an archive
    return nil
  end
end
