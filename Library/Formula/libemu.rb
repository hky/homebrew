require 'formula'

class Libemu < Formula
  head 'http://git.carnivore.it/libemu.git', :using => :git
  homepage 'http://libemu.carnivore.it/'

  depends_on 'pkg-config' => :build

  option "enable-python-bindings", "Compile bindings for Python."

  def install
    # Set .pc target to the Cellar
    inreplace 'Makefile.am', '/usr/lib/pkgconfig/', "#{lib}/pkgconfig/"

    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}"]
    args << "--enable-python-bindings" if ARGV.include? '--enable-python-bindings'

    system "autoreconf -v -i"
    system "./configure", *args
    system "make install"
  end
end
