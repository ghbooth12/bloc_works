require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      puts "\n<controller.rb> BlocWorks::Controller.initialize(env)\nenv: #{env}\n"
      @env = env
      @routing_params = {}
    end

    def dispatch(action, routing_params = {})
      puts "\n<controller.rb> BlocWorks::Controller.dispatch(action, routing_params = {})\naction: #{action}, routing_params: #{routing_params}\n"
      @routing_params = routing_params
      text = self.send(action)
      if has_response?
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    def self.action(action, response = {})
      puts "\n<controller.rb> BlocWorks::Controller.self.action(action, response = {})\naction: #{action}, response: #{response}\n"
      # a proc wraps the controller action.
      # In the proc, "new" method creates a new Rack object,
      # then call dispatch to call the appropriate controller action.
      proc {|env| self.new(env).dispatch(action, response)}
    end

    # This returns either stored request object or new Rack request object.
    def request
      puts "\n<controller.rb> BlocWorks::Controller.request\nBEFORE @request: #{@request}\n"
      # Rack request objects simplify access to elements of HTTP requests.
      @request ||= Rack::Request.new(@env)
      puts "\n<controller.rb> BlocWorks::Controller.request\nAFTER @request: #{@request}\n"
    end

    def params
      puts "\n<controller.rb> BlocWorks::Controller.params\n@routing_params: #{@routing_params}\n"
      # With request object, it is possible to retrieve "params".
      request
      @request.params.merge(@routing_params)
    end

    # This creates a new Rack response object, or raises an error
    # if a controller action attempts to request multiple responses.
    def response(text, status = 200, headers = {})
      puts "\n<controller.rb> BlocWorks::Controller.response(text, status = 200, headers = {})\ntext: #{text}, status: #{status}, headers: #{headers}\n"
      raise "Cannot respond multiple times" unless @response.nil?
      # It's better to have the response encapsulated into an object than
      # a response array [200, {'Content-Type' => 'text/html'}, [text]].
      @response = Rack::Response.new([text].flatten, status, headers)
      # a = [[1, 2, 3], [4, 5, 6, [7, 8]], 9, 10]
      # a.flatten => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    end

    def render(*args)
      puts "\n<controller.rb> BlocWorks::Controller.render(*args)\nargs: #{args}\n"
      response(create_response_array(*args))
    end

    def get_response
      puts "\n<controller.rb> BlocWorks::Controller.get_response\n@response: #{@response}\n"
      @response  # @response: #<Rack::Response:0x007ffd11270db0>
    end

    def has_response?
      puts "\n<controller.rb> BlocWorks::Controller.has_response?\n...\n"
      !@response.nil?
    end

    def create_response_array(view, locals = {})
      puts "\n<controller.rb> BlocWorks::Controller.create_response_array(view, locals = {})\nview: #{view}, locals: #{locals}\n"
      # File.join("usr", "mail", "gumby")   #=> "usr/mail/gumby"
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)
      # Erubis converts erb file into HTML.
      eruby = Erubis::Eruby.new(template)
      eruby.result(locals.merge(env: @env))
    end

    def controller_dir
      puts "\n<controller.rb> BlocWorks::Controller.controller_dir\nself: #{self}"
      klass = self.class.to_s # klass = "LabelsController"
      klass.slice!("Controller") #=> Cut "Controller" out of klass
      BlocWorks.snake_case(klass) # klass == "Labels"
    end
  end
end
