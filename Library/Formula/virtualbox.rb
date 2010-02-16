require 'formula'

# See: http://www.virtualbox.org/wiki/Mac%20OS%20X%20build%20instructions

class Virtualbox < Formula
  url 'http://download.virtualbox.org/virtualbox/4.0.8/VirtualBox-4.0.8.tar.bz2'
  version '4.0.8-OSE'
  homepage 'http://www.virtualbox.org/'
  sha256 '48961f0d6fe70c3887cbca5ea987767ac1bafd4b64dd3c4d25445682351e118e'

  # We only build VirtualBox 32-bit, due to its architecture.
  # This means that Universal (or 32-bit only) builds of the following are needed:
  # * qt
  # * libldl
  # ** gettext
  # ** glib

  # To build, you need to make sure the deps are built correctly:
  # brew install gettext glib libidl --universal
  # brew install qt --universal
  #
  # Then do:
  # brew install virtualbox
  #
  # Note that building Qt with --universal on a 2007 MBP takes about 3 hours.
  # No joke.

  depends_on "libidl"
  depends_on "openssl" # System-provided version is too old on both 10.5 and 10.6
  depends_on "qt"

  def install
    # On Snow Leopard and newer, force compilation against the 10.6 SDK
    if MacOS.snow_leopard?
      here=Pathname.new(Dir.pwd)
      (here+'LocalConfig.kmk').write <<-EOF.undent
        VBOX_DEF_MACOSX_VERSION_MIN=10.6
        VBOX_DARWIN_NO_COMPACT_LINKEDIT=
        VBOX_MACOS_10_5_WORKAROUND=
      EOF
    end

    openssl_prefix = Formula.factory("openssl").prefix
    qt_prefix = Formula.factory("qt").prefix

    args = ["--disable-hardening",
            "--with-openssl-dir=#{openssl_prefix}",
            "--with-qt-dir=#{qt_prefix}",
            "--target-arch=x86"]

    # TODO - this should only enable 64-bit if the *Kernel* is
    # running in 64-bit mode
    # args << "--target-arch=amd64" if snow_leopard_64?

    system "./configure", *args
    system ". ./env.sh ; kmk"

    # Move all the build outputs into libexec
    libexec.install Dir["out/darwin.*/release/dist/*"]

    app_contents = libexec+"VirtualBox.app/Contents/MacOS/"

    # remove test scripts and files
    (app_contents+"testcase").rmtree
    rm Dir.glob(app_contents+"tst*")

    # Slot the command-line tools into bin
    bin.mkpath

    cd prefix do
      %w[ VBoxHeadless VBoxManage VBoxVRDP vboxwebsrv ].each do |c|
        ln_s "libexec/VirtualBox.app/Contents/MacOS/#{c}", "bin" if File.exist? app_contents+c
      end
    end

    # TODO - download guest additions iso & manual and put it in share somewhere?
  end

  def caveats; <<-EOS.undent
    Compiled outputs installed to:
      #{libexec}

    To load the kernerl extensions run:
      #{libexec}/loadall.sh

    Pre-compiled binaries are available from:
      http://www.virtualbox.org/wiki/Downloads
    EOS
  end
end
