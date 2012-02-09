require 'formula'

class Libmpdclient < Formula
  url 'http://downloads.sourceforge.net/project/musicpd/libmpdclient/2.7/libmpdclient-2.7.tar.bz2'
  homepage 'http://mpd.wikia.com/wiki/ClientLib:libmpdclient'
  sha1 'a8ec78f6a7ae051fbf1cc0f47564301423c281b0'

  option "universal"

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}", "--disable-dependency-tracking"
    system "make install"
  end
end
