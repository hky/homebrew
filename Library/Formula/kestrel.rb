require 'formula'

class Kestrel < Formula
  homepage 'http://robey.github.com/kestrel/'
  url 'http://robey.github.com/kestrel/download/kestrel-2.1.5.zip'
  md5 '256503b15fb7feec37e100f5ef92f94d'

  depends_on 'daemon'

  def install
    inreplace 'scripts/kestrel.sh' do |s|
      s.change_make_var! "APP_HOME", libexec
      s.gsub! "/var/log/$APP_NAME/", "#{var}/log/$APP_NAME"
      s.gsub! "/var/run/$APP_NAME/", "#{var}/run/$APP_NAME"
      # Fix path to script in help message
      s.gsub! "Usage: /etc/init.d/${APP_NAME}.sh", "Usage: kestrel"
    end

    libexec.install Dir['*']
    (libexec+'scripts/kestrel.sh').chmod 0755
    (libexec+'scripts/devel.sh').chmod 0755

    (var+'log/kestrel').mkpath
    (var+'run/kestrel').mkpath

    (bin+'kestrel').write <<-EOS.undent
      #!/bin/bash
      exec "#{libexec}/scripts/kestrel.sh" "$@"
    EOS
  end

  def test
    system "#{bin}/kestrel status"
  end
end
