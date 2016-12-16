require "erubis"
require "pry"

module BlocWorks
  class Controller
    def initialize(env)
      puts "<controller.rb> BlocWorks::Controller#initialize(env)"
      @env = env
      @routing_params = {}
    end

    def dispatch(action, routing_params = {})
      puts "<controller.rb> BlocWorks::Controller#dispatch"
      @routing_params = routing_params
      text = self.send(action)
      if has_response?
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        # [200, {'Content-Type' => 'text/html'}, [text].flatten]
        self.render(action, routing_params)
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      end
    end

    def self.action(action, response = {})
      puts "<controller.rb> BlocWorks::Controller.action"
      # a proc wraps the controller action.
      # In the proc, "new" method creates a new Rack object,
      # then call dispatch to call the appropriate controller action.
      proc {|env| self.new(env).dispatch(action, response)}
    end

    # This returns either stored request object or new Rack request object.
    def request
      puts "<controller.rb> BlocWorks::Controller#request"
      # Rack request objects simplify access to elements of HTTP requests.
      @request ||= Rack::Request.new(@env)
    end

    def params
      puts "<controller.rb> BlocWorks::Controller#params"
      # With request object, it is possible to retrieve "params".
      request
      @request.params.merge(@routing_params)
    end

    # This creates a new Rack response object, or raises an error
    # if a controller action attempts to request multiple responses.
    def response(text, status = 200, headers = {})
      puts "<controller.rb> BlocWorks::Controller#response"
      raise "Cannot respond multiple times" unless @response.nil?
      # It's better to have the response encapsulated into an object than
      # a response array [200, {'Content-Type' => 'text/html'}, [text]].
      @response = Rack::Response.new([text].flatten, status, headers)
      # a = [[1, 2, 3], [4, 5, 6, [7, 8]], 9, 10]
      # a.flatten => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    end

    def render(*args) # args = ["welcome", {}]
      puts "<controller.rb> BlocWorks::Controller#render"
      response(create_response_array(*args))
    end

    def redirect(action, locals={})
      response(create_response_array(action, locals))
    end

    def get_response
      puts "<controller.rb> BlocWorks::Controller#get_response"
      @response  # @response: #<Rack::Response:0x007ffd11270db0>
    end

    def has_response?
      puts "<controller.rb> BlocWorks::Controller#has_response?"
      !@response.nil?
    end

    def create_response_array(view, locals = {})
      puts "<controller.rb> BlocWorks::Controller#create_response_array"
      # File.join("usr", "mail", "gumby")   #=> "usr/mail/gumby"
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)

      vars = {}
      instance_variables.each do |var|
        key = var.to_s.gsub("@", "").to_sym
        vars[key] = instance_variable_get(var)
      end

      # Erubis converts erb file into HTML.
      eruby = Erubis::Eruby.new(template)
      eruby.result(locals.merge(vars))
    end

    def controller_dir
      puts "<controller.rb> BlocWorks::Controller#controller_dir"
      klass = self.class.to_s # klass = "LabelsController"
      klass.slice!("Controller") #=> Cut "Controller" out of klass
      BlocWorks.snake_case(klass) # klass == "Labels"
    end
  end
end
