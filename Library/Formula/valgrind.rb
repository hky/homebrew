require 'formula'

class Valgrind < Formula
  homepage 'http://www.valgrind.org/'

  # Valgrind 3.8.0 drops support for OS X 10.5
  if MACOS_VERSION >= 10.6
    url 'http://valgrind.org/downloads/valgrind-3.8.0.tar.bz2'
    md5 'ec04dfd1256307432b2a7b520398c526'
  else
    url "http://valgrind.org/downloads/valgrind-3.6.1.tar.bz2"
    md5 "2c3aa122498baecc9d69194057ca88f5"
  end

  skip_clean 'lib'

  def install
    ENV.remove_from_cflags "-mmacosx-version-min=#{MACOS_VERSION}"
    ENV.remove 'CXXFLAGS', "-mmacosx-version-min=#{MACOS_VERSION}"
    args = ["--prefix=#{prefix}", "--mandir=#{man}"]
    if MacOS.prefer_64_bit?
      args << "--enable-only64bit" << "--build=amd64-darwin"
    else
      args << "--enable-only32bit"
    end

    system "./configure", *args
    system "make"
    system "make install"
  end

  def test
    system "#{bin}/valgrind", "ls", "-l"
  end
end
