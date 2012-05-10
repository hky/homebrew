require 'formula'

class Gerbv < Formula
  homepage 'http://gerbv.gpleda.org/'
  url 'http://downloads.sourceforge.net/project/gerbv/gerbv/gerbv-2.6.0/gerbv-2.6.0.tar.gz'
  md5 '44a37dd202bc60fab54cbc298a477572'

  depends_on 'pkg-config' => :build
  depends_on 'gtk+'
  depends_on 'cairo'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-update-desktop-database"
    system "make install"
  end

  def caveats
    "Note: gerbv is an X11 application."
  end
end
