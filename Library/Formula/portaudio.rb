require 'formula'

class Portaudio < Formula
  url 'http://www.portaudio.com/archives/pa_stable_v19_20111121.tgz'
  homepage 'http://www.portaudio.com'
  md5 '25c85c1cc5e9e657486cbc299c6c035a'

  depends_on 'pkg-config' => :build

  fails_with_llvm :build => 2334

  option "universal"

  def install
    ENV.universal_binary if build.universal?

    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            # portaudio builds universal unless told not to
            "--enable-mac-universal=#{build.universal? ? 'yes' : 'no'}"]

    system "./configure", *args
    system "make install"

    # Need 'pa_mac_core.h' to compile PyAudio
    include.install "include/pa_mac_core.h"
  end
end
