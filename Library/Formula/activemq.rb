require 'formula'

class Activemq < Formula
  homepage 'http://activemq.apache.org/'
  url 'http://www.apache.org/dyn/closer.cgi?path=activemq/apache-activemq/5.6.0/apache-activemq-5.6.0-bin.tar.gz'
  sha1 '3205f5fcd61cf8bc7122b2f65ce22f68b2ab487a'

  skip_clean 'libexec/webapps/admin/WEB-INF/jsp'

  def install
    rm_rf Dir['bin/linux-x86-*']

    prefix.install %w{ LICENSE NOTICE README.txt }
    libexec.install Dir['*']

    bin.write_exec_script libexec/'bin/activemq'
    bin.write_exec_script libexec/'bin/activemq-admin'
  end
end
