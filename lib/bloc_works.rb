require "bloc_works/version"

module BlocWorks
  class Application
    # "call" returns an array containing an HTTP status code, an HTTP header, and the text to display in the browser.
    # Rack objects must return this triplet(an array of extactly three itmes).
    # Rack object usually takes the "env" variable, which represents the rack environment.
    def call(env)
      [200, {'Content-Type' => 'text/html'}, ["Hello Blocheads!"]]
    end
  end
end
