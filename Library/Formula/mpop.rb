require 'formula'

class Mpop < Formula
  url 'http://downloads.sourceforge.net/project/mpop/mpop/1.0.19/mpop-1.0.19.tar.bz2'
  homepage 'http://mpop.sourceforge.net/'
  md5 '40a48d486121a15075faee944a7b8fb7'

  option 'with-macosx-keyring', "Support Mac OS X Keyring."

  def install
    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}"]
    args << "--with-macosx-keyring" if ARGV.include? '--with-macosx-keyring'
    system "./configure", *args
    system "make install"
  end
end
