require 'formula'

class Cppunit < Formula
  url 'http://downloads.sourceforge.net/project/cppunit/cppunit/1.12.1/cppunit-1.12.1.tar.gz'
  homepage 'http://sourceforge.net/apps/mediawiki/cppunit/'
  md5 'bd30e9cf5523cdfc019b94f5e1d7fd19'

  option "universal"

  def install
    args = ["--prefix=#{prefix}", "--disable-debug", "--disable-dependency-tracking"]

    ENV.universal_binary if build.universal?

    system "./configure", *args
    system "make install"
  end
end
