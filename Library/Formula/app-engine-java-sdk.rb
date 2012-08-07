require 'formula'

class AppEngineJavaSdk < Formula
  homepage 'http://code.google.com/appengine/docs/java/overview.html'
  url 'http://googleappengine.googlecode.com/files/appengine-java-sdk-1.6.6.zip'
  sha1 'bb67c8984606fc8d28ab4f49afc088b5b70d9097'

  def install
    rm Dir['bin/*.cmd']
    libexec.install Dir['*']

    Dir["#{libexec}/bin/*"].each do |n|
      bin.write_exec_script n
    end
  end
end
