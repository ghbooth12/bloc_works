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
      puts "\n<bloc_works.rb> BlocWorks::Application.call(env)\nenv: #{env}\n"

      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end


      # # ===== Old Code =====
      # klass, action = controller_and_action(env)
      # controller = klass.new(env)
      # text = controller.send(action)
      # puts "\n<bloc_works.rb> BlocWorks::Application.call(env)\nklass: #{klass}, action: #{action}, controller: #{controller}, text: #{text}\n"
      #
      # if controller.has_response?
      #   status, header, response = controller.get_response
      #   puts "\n<bloc_works.rb> BlocWorks::Application.call(env)\nIF STMT response: #{[response.body].flatten}\n"
      #   [status, header, [response.body].flatten]
      # else
      #   [200, {'Content-Type' => 'text/html'}, [text]]
      # end
      # # ===== Ends Old Code =====


      # Create a new Rack application every time a request is made.
      rack_app = get_rack_app(env)
      puts "\n<bloc_works.rb> BlocWorks::Application.call(env)\nAFTER rack_app: #{rack_app}\n"
      rack_app.call(env)
    end
  end
end
