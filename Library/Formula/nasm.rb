require 'formula'

class Nasm < Formula
  url 'http://www.nasm.us/pub/nasm/releasebuilds/2.09.10/nasm-2.09.10.tar.bz2'
  homepage 'http://www.nasm.us/'
  sha1 'ca57a7454b29e18c64018e49cdf5c832937497ab'

  option "universal"

  def install
    ENV.universal_binary if build.universal?
    system "./configure", "--prefix=#{prefix}"
    system "make everything"
    system "make install_everything"
  end
end
