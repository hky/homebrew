require 'formula'

class Mapserver < Formula
  url 'http://download.osgeo.org/mapserver/mapserver-6.0.1.tar.gz'
  homepage 'http://mapserver.org/'
  md5 'b96287449dcbca9a2fcea3a64905915a'

  depends_on 'gd'
  depends_on 'proj'
  depends_on 'gdal'
  depends_on 'geos' if ARGV.include? '--with-geos'
  depends_on 'postgresql' if ARGV.include? '--with-postgresql' and not MacOS.lion?

  option "with-geos", "Build support for GEOS spatial operations."
  option "with-php", "Build PHP MapScript module."
  option "with-postgresql", "Build support for PostgreSQL as a data source."

  def configure_args
    args = ["--prefix=#{prefix}",
            "--with-proj",
            "--with-gdal",
            "--with-ogr",
            "--with-png=/usr/X11"]

    args << "--with-geos" if ARGV.include? '--with-geos'
    args << "--with-php=/usr/include/php" if ARGV.include? '--with-php'

    if ARGV.include? '--with-postgresql'
      if MacOS.lion? # Lion ships with PostgreSQL libs
        args << "--with-postgis"
      else
        args << "--with-postgis=#{HOMEBREW_PREFIX}/bin/pg_config"
      end
    end

    args
  end

  def install
    ENV.x11
    system "./configure", *configure_args
    system "make"
    bin.install %w(mapserv shp2img legend shptree shptreevis
        shptreetst scalebar sortshp mapscriptvars tile4ms
        msencrypt mapserver-config)

    if ARGV.include? '--with-php'
      prefix.install %w(mapscript/php/php_mapscript.so)
    end
  end

  def caveats; <<-EOS.undent
    The Mapserver CGI executable is #{prefix}/mapserv

    If you built the PHP option:
      * Add the following line to php.ini:
        extension="#{prefix}/php_mapscript.so"
      * Execute "php -m"
      * You should see MapScript in the module list
    EOS
  end
end
