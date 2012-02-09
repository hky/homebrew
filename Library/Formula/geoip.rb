require 'formula'

class Geoip < Formula
  url 'http://geolite.maxmind.com/download/geoip/api/c/GeoIP-1.4.8.tar.gz'
  homepage 'http://www.maxmind.com/app/c'
  md5 '05b7300435336231b556df5ab36f326d'

  option "universal"

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make install"
  end
end
