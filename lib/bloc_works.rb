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
      puts "<bloc_works.rb> BlocWorks::Application#call"

      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end

      # Create a new Rack application every time a request is made.
      rack_app = get_rack_app(env)
      rack_app.call(env)
      # rack_app: #<Proc:0x007ffd112996c0@/.../bloc_works/lib/bloc_works/controller.rb:28>
    end
  end
end
