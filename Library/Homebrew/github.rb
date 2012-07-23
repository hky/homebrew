module GitHub extend self
  def issues_for_formula name
    # bit basic as depends on the issue at github having the exact name of the
    # formula in it. Which for stuff like objective-caml is unlikely. So we
    # really should search for aliases too.

    name = f.name if Formula === name

    require 'open-uri'
    require 'vendor/multi_json'

    issues = []

    uri = URI.parse("https://api.github.com/legacy/issues/search/mxcl/homebrew/open/#{name}")

    open uri do |f|
      MultiJson.decode(f.read)['issues'].each do |issue|
        # don't include issues that just refer to the tool in their body
        issues << issue['html_url'] if issue['title'].include? name
      end
    end

    issues
  rescue
    []
  end

  def find_pull_requests rx
    require 'open-uri'
    require 'vendor/multi_json'

    query = rx.source.delete('.*').gsub('\\', '')
    uri = URI.parse("https://api.github.com/legacy/issues/search/mxcl/homebrew/open/#{query}")

    open uri do |f|
      MultiJson.decode(f.read)['issues'].each do |pull|
        yield pull['pull_request_url'] if rx.match pull['title'] and pull['pull_request_url']
      end
    end
  rescue
    nil
  end
end
