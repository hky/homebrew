require 'tab'

# --tab command for inspecting install reciepts
# Named with some dashes in front to suggest that it
# is a temporary command; didn't want to use 'tab'
# directly so we can still use it for something useful.

module Homebrew extend self
  def tab
    ARGV.formulae.each do |f|
      next unless f.installed?
      receipt = Tab.for_formula f
      puts receipt.to_json
    end
  end
end

Homebrew.tab
