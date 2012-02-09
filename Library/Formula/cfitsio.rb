require 'formula'

class CfitsioExamples < Formula
  url 'http://heasarc.gsfc.nasa.gov/docs/software/fitsio/cexamples/cexamples.zip'
  version '2010.08.19'
  md5 '31a5f5622a111f25bee5a3fda2fdac28'
end

class Cfitsio < Formula
  homepage 'http://heasarc.gsfc.nasa.gov/docs/software/fitsio/fitsio.html'
  url 'ftp://heasarc.gsfc.nasa.gov/software/fitsio/c/cfitsio3290.tar.gz'
  version '3.29'
  md5 'bba93808486cf5edac236a941283b3c3'

  option 'with-examples', "Compile and install example programs."

  def install
    # --disable-debug and --disable-dependency-tracking are not recognized by configure
    system "./configure", "--prefix=#{prefix}"
    system "make shared"
    system "make install"

    if ARGV.include? '--with-examples'
      system "make fpack funpack"
      bin.install 'fpack', 'funpack'

      # fetch, compile and install examples programs
      CfitsioExamples.new.brew do
        mkdir 'bin'
        Dir['*.c'].each do |f|
          # compressed_fits.c does not work (obsolete function call)
          next if f == 'compress_fits.c'
          system "#{ENV.cc} #{f} -I#{include} -L#{lib} -lcfitsio -lm -o bin/#{f.sub('.c','')}"
        end
        bin.install Dir['bin/*']
      end
    end
  end
end
