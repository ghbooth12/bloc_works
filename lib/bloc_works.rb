require "bloc_works/version"
require "bloc_works/router"
require "bloc_works/utility"
require "bloc_works/dependencies"
require "bloc_works/controller"

module BlocWorks
  class Application
    # "call" returns an array containing an HTTP status code, an HTTP header, and the text to display in the browser.
    # Rack objects must return this triplet(an array of extactly three itmes).
    # Rack object usually takes the "env" variable, which represents the rack environment.
    def call(env)
      puts "\ncall is working, env: #{env}\n"
      [200, {'Content-Type' => 'text/html'}, ["Hello Blocheads! New Version123"]]
    end
  end
end
