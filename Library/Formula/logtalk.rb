require 'formula'

class Logtalk < Formula
  homepage 'http://logtalk.org'
  url 'http://logtalk.org/files/lgt2432.tar.bz2'
  md5 'b5698033aca3c5173b7afe0ce4e84782'
  version '2.43.2'

  if ARGV.include?("--swi-prolog")
    depends_on 'swi-prolog'
  else
    depends_on 'gnu-prolog'
  end

  if ARGV.include?("--use-git-head")
    head 'git://github.com/pmoura/logtalk.git'
  else
    head 'http://svn.logtalk.org/logtalk/trunk', :using =>   :svn
  end

  option "swi-prolog", "Build using SWI Prolog as backend instead of GNU Prolog."
  option "use-git-head", "Use GitHub mirror."

  def install
    system "scripts/install.sh #{prefix}"
    man1.install Dir['man/man1/*']
    bin.install Dir['bin/*']
  end
end
