require 'pathname'
require 'exceptions'
require 'macos'
require 'github'

class Tty
  class <<self
    def blue; bold 34; end
    def white; bold 39; end
    def red; underline 31; end
    def yellow; underline 33 ; end
    def reset; escape 0; end
    def em; underline 39; end
    def green; color 92 end

    def width
      `/usr/bin/tput cols`.strip.to_i
    end

  private
    def color n
      escape "0;#{n}"
    end
    def bold n
      escape "1;#{n}"
    end
    def underline n
      escape "4;#{n}"
    end
    def escape n
      "\033[#{n}m" if $stdout.tty?
    end
  end
end

# args are additional inputs to puts until a nil arg is encountered
def ohai title, *sput
  title = title.to_s[0, Tty.width - 4] if $stdout.tty? unless ARGV.verbose?
  puts "#{Tty.blue}==>#{Tty.white} #{title}#{Tty.reset}"
  puts sput unless sput.empty?
end

def oh1 title
  title = title.to_s[0, Tty.width - 4] if $stdout.tty? unless ARGV.verbose?
  puts "#{Tty.green}==> #{Tty.reset}#{title}"
end

def opoo warning
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning}"
end

def onoe error
  lines = error.to_s.split'\n'
  puts "#{Tty.red}Error#{Tty.reset}: #{lines.shift}"
  puts lines unless lines.empty?
end

def ofail error
  onoe error
  Homebrew.failed = true
end

def odie error
  onoe error
  exit 1
end

def pretty_duration s
  return "2 seconds" if s < 3 # avoids the plural problem ;)
  return "#{s.to_i} seconds" if s < 120
  return "%.1f minutes" % (s/60)
end

def interactive_shell f=nil
  unless f.nil?
    ENV['HOMEBREW_DEBUG_PREFIX'] = f.prefix
    ENV['HOMEBREW_DEBUG_INSTALL'] = f.name
  end

  fork {exec ENV['SHELL'] }
  Process.wait
  unless $?.success?
    puts "Aborting due to non-zero exit status"
    exit $?
  end
end

module Homebrew
  def self.system cmd, *args
    puts "#{cmd} #{args*' '}" if ARGV.verbose?
    fork do
      yield if block_given?
      args.collect!{|arg| arg.to_s}
      exec(cmd, *args) rescue nil
      exit! 1 # never gets here unless exec failed
    end
    Process.wait
    $?.success?
  end
end

# Kernel.system but with exceptions
def safe_system cmd, *args
  unless Homebrew.system cmd, *args
    args = args.map{ |arg| arg.to_s.gsub " ", "\\ " } * " "
    raise ErrorDuringExecution, "Failure while executing: #{cmd} #{args}"
  end
end

# prints no output
def quiet_system cmd, *args
  Homebrew.system(cmd, *args) do
    # Redirect output streams to `/dev/null` instead of closing as some programs
    # will fail to execute if they can't write to an open stream.
    $stdout.reopen('/dev/null')
    $stderr.reopen('/dev/null')
  end
end

def curl *args
  curl = Pathname.new '/usr/bin/curl'
  raise "#{curl} is not executable" unless curl.exist? and curl.executable?

  args = [HOMEBREW_CURL_ARGS, HOMEBREW_USER_AGENT, *args]
  # See https://github.com/mxcl/homebrew/issues/6103
  args << "--insecure" if MacOS.version < 10.6
  args << "--verbose" if ENV['HOMEBREW_CURL_VERBOSE']
  args << "--silent" unless $stdout.tty?

  safe_system curl, *args
end

def puts_columns items, star_items=[]
  return if items.empty?

  if star_items && star_items.any?
    items = items.map{|item| star_items.include?(item) ? "#{item}*" : item}
  end

  if $stdout.tty?
    # determine the best width to display for different console sizes
    console_width = `/bin/stty size`.chomp.split(" ").last.to_i
    console_width = 80 if console_width <= 0
    longest = items.sort_by { |item| item.length }.last
    optimal_col_width = (console_width.to_f / (longest.length + 2).to_f).floor
    cols = optimal_col_width > 1 ? optimal_col_width : 1

    IO.popen("/usr/bin/pr -#{cols} -t -w#{console_width}", "w"){|io| io.puts(items) }
  else
    puts items
  end
end

def which cmd
  path = `/usr/bin/which #{cmd} 2>/dev/null`.chomp
  if path.empty?
    nil
  else
    Pathname.new(path)
  end
end

def which_editor
  editor = ENV['HOMEBREW_EDITOR'] || ENV['EDITOR']
  # If an editor wasn't set, try to pick a sane default
  return editor unless editor.nil?

  # Find Textmate
  return 'mate' if which "mate"
  # Find # BBEdit / TextWrangler
  return 'edit' if which "edit"
  # Default to vim
  return '/usr/bin/vim'
end

def exec_editor *args
  return if args.to_s.empty?

  # Invoke bash to evaluate env vars in $EDITOR
  # This also gets us proper argument quoting.
  # See: https://github.com/mxcl/homebrew/issues/5123
  system "bash", "-c", which_editor + ' "$@"', "--", *args
end

# GZips the given paths, and returns the gzipped paths
def gzip *paths
  paths.collect do |path|
    system "/usr/bin/gzip", path
    Pathname.new("#{path}.gz")
  end
end

# Returns array of architectures that the given command or library is built for.
def archs_for_command cmd
  cmd = which(cmd) unless Pathname.new(cmd).absolute?
  Pathname.new(cmd).archs
end

def inreplace path, before=nil, after=nil
  [*path].each do |path|
    f = File.open(path, 'r')
    s = f.read

    if before == nil and after == nil
      s.extend(StringInreplaceExtension)
      yield s
    else
      sub = s.gsub!(before, after)
      if sub.nil?
        opoo "inreplace in '#{path}' failed"
        puts "Expected replacement of '#{before}' with '#{after}'"
      end
    end

    f.reopen(path, 'w').write(s)
    f.close
  end
end

def ignore_interrupts
  std_trap = trap("INT") {}
  yield
ensure
  trap("INT", std_trap)
end

def nostdout
  if ARGV.verbose?
    yield
  else
    begin
      require 'stringio'
      real_stdout = $stdout
      $stdout = StringIO.new
      yield
    ensure
      $stdout = real_stdout
    end
  end
end

class MetaFiles
  def initialize
    @documentation_files = %w[
      AUTHORS ChangeLog CHANGES COPYING COPYRIGHT LICENSE LICENCE
      README README.md
    ]
    @metafiles = %w[ INSTALL_RECEIPT.json ]
    @ignored_files = %w[ .DS_Store ]
  end

  # Iterates the list of documentation files.
  # TODO - make this smarter about file extensions
  def each &blk
    @documentation_files.each &blk
  end

  # true if the given pathname should show in `brew list`
  def should_list_file? pn
    # Basename, without a .txt extension, if present
    basename = pn.basename('.txt').to_s
    not @documentation_files.include? basename and
    not @metafiles.include? basename and
    not @ignored_files.include? basename
  end
end
