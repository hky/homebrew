require 'formula'

class GnuTar < Formula
  url 'http://ftpmirror.gnu.org/tar/tar-1.26.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/tar/tar-1.26.tar.gz'
  homepage 'http://www.gnu.org/software/tar/'
  md5 '00d1e769c6af702c542cca54b728920d'

  option 'default-names', "Do NOT prepend 'g' to the binary. Overrides system tar."

  def install
    args = [ "--prefix=#{prefix}" , "--mandir=#{man}" ]
    args << "--program-prefix=g" unless ARGV.include? '--default-names'

    system "./configure", *args
    system "make install"
  end
end
