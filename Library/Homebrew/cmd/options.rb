require 'formula'
require 'cmd/outdated'

def ff
  if ARGV.include? "--all"
    Formula.all
  elsif ARGV.include? "--installed"
    # outdated brews count as installed
    outdated = Homebrew.outdated_brews.collect{ |b| b.name }
    Formula.all.select do |f|
      f.installed? or outdated.include? f.name
    end
  else
    raise FormulaUnspecifiedError if ARGV.named.empty?
    ARGV.formulae
  end
end

module Homebrew extend self
  def options
    ff.each do |f|
      next if f.build.empty?
      if ARGV.include? '--compact'
        puts f.build.collect {|k,v| k} * " "
      else
        puts f.name
        f.build.each do |k,v|
          puts k
          puts "\t"+v
        end
        puts
      end
    end
  end
end
