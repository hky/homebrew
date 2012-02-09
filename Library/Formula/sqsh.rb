require 'formula'

class Sqsh < Formula
  url 'http://downloads.sourceforge.net/sourceforge/sqsh/sqsh-2.1.7.tar.gz'
  homepage 'http://www.sqsh.org/'
  md5 'ce929dc8e23cedccac98288d24785e2d'

  depends_on 'freetds'
  depends_on 'readline'

  option "with-x", "Enable X windows support."

  def install
    ENV['LIBDIRS'] = Readline.new('readline').lib
    ENV['INCDIRS'] = Readline.new('readline').include
    ENV['SYBASE'] = Freetds.new("freetds").prefix

    args = ["--disable-debug", "--disable-dependency-tracking",
            "--prefix=#{prefix}",
            "--mandir=#{man}",
            "--with-readline"]

    if ARGV.include? "--with-x"
      args << "--with-x"
      args << "--x-libraries=/usr/X11/lib"
      args << "--x-includes=/usr/X11/includes"
    end

    system "./configure", *args
    system "make", "install"
    system "make", "install.man"
  end
end
