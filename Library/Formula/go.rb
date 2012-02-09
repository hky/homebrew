require 'formula'

class Go < Formula
  homepage 'http://golang.org'
  version 'r60.3'

  if ARGV.include? "--use-git"
    url 'https://github.com/tav/go.git', :tag => 'release.r60.3'
    head 'https://github.com/tav/go.git'
  else
    url 'http://go.googlecode.com/hg/', :revision => 'release.r60.3'
    head 'http://go.googlecode.com/hg/'
  end

  skip_clean 'bin'

  option "use-git", "Use git mirror instead of official hg repository."

  def install
    prefix.install %w[src include test doc misc lib favicon.ico AUTHORS]
    cd prefix do
      mkdir %w[pkg bin]
      File.open('VERSION', 'w') {|f| f.write('release.r60.3 9516') }

      # Tests take a very long time to run. Build only
      cd 'src' do
        system "./make.bash"
      end

      # Don't need the src folder, but do keep the Makefiles as Go projects use these
      Dir['src/*'].each{|f| rm_rf f unless f.match(/^src\/(pkg|Make)/) }
      rm_rf %w[include test]
    end
  end
end
