require 'formula'

class AdobeAirSdk < Formula
  homepage 'http://www.adobe.com/products/air/sdk/'
  url 'http://airdownload.adobe.com/air/mac/download/3.3/AdobeAIRSDK.tbz2'
  sha1 '6fd563409e59e3ee66fa8ce0b60d4e9896b9a4af'
  version '3.3'

  def install
    libexec.install Dir['*']
    bin.write_exec_script libexec/'bin/adl'
    bin.write_exec_script libexec/'bin/adt'
  end
end
