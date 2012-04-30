class ChecksumResult
  attr_reader :type
  attr_reader :expected
  attr_reader :actual

  def initialize type, expected, actual
    @type = type
    @expected = expected
    @actual = actual
  end

  def success?
    expected.upcase == actual.upcase
  end
end

class Checksum
  def initialize hash_type
    @hash_type = hash_type.to_s.upcase
  end

  def validate pathname, expected
    require 'digest'
    hasher = Digest.const_get(@hash_type)
    actual = pathname.incremental_hash(hasher)
    return ChecksumResult.new(@hash_type, expected, actual)
  end
end
