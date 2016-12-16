require 'pry'

module BlocWorks
  class Application
    def controller_and_action(env)
      puts "<router.rb> BlocWorks::Application#controller_and_action"
      # If env["PATH_INFO"] = "/labels/new/" (String that Rack sets to the path of the HTTP request.)
      # _, controller, action, _ = ["", "labels", "new", ""]
      # _ -> "", controller -> "labels", action -> "new"
      # _ is a variable here. _ means we ingore the value.
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"

      # This method returns [LabelsController, 'new']
      [Object.const_get(controller), action]
      # The first element will be a reference to the LabelsController class, not just the string "LabelsController". const_get will assist us in mapping URLs to a controller and an action.
      # http://www.example.com/labels/new
    end

    def fav_icon(env)
      puts "<router.rb> BlocWorks::Application#fav_icon"
      if env['PATH_INFO'] == '/favicon.ico'
        # This route returns an empty HTML page, with the status code 404.
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end

    # &block consists of the routes we want to map.
    # This starts the mapping process.
    def route(&block)  # When Proc is used, &proc_name
      puts "<router.rb> BlocWorks::Application#route(&block)"
      # block = #<Proc:0x007fddc4af3da0@/.../bloc-books/config.ru:13>
      @router ||= Router.new
      @router.instance_eval(&block)

      # ===== About 'instance_eval' ======
      # class KlassWithSecret
      #   def initialize
      #     @secret = 99
      #   end
      # end
      # k = KlassWithSecret.new
      # k.instance_eval { @secret }   #=> 99
      # ==================================
    end

    # Map URLs to routes and look up routes when given a URL.
    def get_rack_app(env)
      puts "<router.rb> BlocWorks::Application#get_rack_app"
      # binding.pry
      if @router.nil?
        raise "No routes defined"
      end

      @router.look_up_url(env["PATH_INFO"])
    end
  end

  class Router
    def initialize
      puts "<router.rb> BlocWorks::Router#initialize"
      # This defines which routes map to which destinations.
      @rules = []
    end

    # This builds route / action rules and add them to @rules.
    def map(url, *args)
      puts "<router.rb> BlocWorks::Router.map"
      # map(":controller/:id", default: { "action" => "show" })
      # Then options receive {:default => { "action" => "show" }}
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}

      # Set destination controller and action.
      # This can create default routes like below:
      # e.g. match("", "books#welcome") assigns "books#welcome" to destination
      destination = nil
      destination = args.pop if args.size > 0
      raise "Too many args" if args.size > 0

      # Split url and map each part to a regular expression, while building an array of variables(ids, controllers, actions).
      url_parts = url.split("/")
      url_parts.reject! {|part| part.empty?}  # Reject "", []

      vars = []
      # url is ":controller/:id"
      # url_parts is [":controller", ":id"]
      regex_parts = url_parts.map do |part|
        if part[0] == ":"
          vars << part[1..-1]
          part[1..-1] == "id" ? "([0-9]+)" : "([a-zA-Z0-9]+)"
        else
          part
        end
      end

      # Assemble the final rule and add it to @rules.
      # ^ (Start of string or start of line)
      # $ (End of string or end of line)
      # Regexp.new('^a-z+:\s+\w+') => /^a-z+:\s+\w+/
      regex = regex_parts.join("/")
      @rules.push({ regex: Regexp.new("^/#{regex}$"),
                    vars: vars, destination: destination,
                    options: options })
    end # Ends map

    # 'look_up_url' takes a URL and checks it against the @rules array of mapped routes.
    # If it finds a match it uses 'get_destination' to return the correct controller and action to call.
    def look_up_url(url)
      puts "<router.rb> BlocWorks::Router#look_up_url"
      @rules.each do |rule|
        # match is a Regexp method
        # /hay/.match('haystack') => #<MatchData "hay">
        rule_match = rule[:regex].match(url)

        if rule_match  # "", [] is truthy
          # rule[:options] --> {:default => { "action" => "show" }}
          params = rule[:options][:default].dup  # Read more below about dup

          # rule[:vars] = ["controller", "id"]
          rule[:vars].each_with_index do |var, index|
            # params = { "action" => "show" }
            params[var] = rule_match.captures[index] # Read more below about captures
          end

          if rule[:destination]
            return get_destination(rule[:destination], params)
          else
            controller = params["controller"]
            action = params["action"]
            return get_destination("#{controller}##{action}", params)
          end
        end
      end
    end # Ends look_up_url

    def get_destination(destination, routing_params = {})
      puts "<router.rb> BlocWorks::Router.get_destination"
      if destination.respond_to?(:call)
        return destination
      end

      if destination =~ /([^#]+)#([^#]+)/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        return controller.action($2, routing_params)
      end
      raise "Destination no found: #{destination}"
    end
  end # Ends Router
end # Ends BlocWorks module


# ========== .dup vs .clone ==========
# dup is a shallow copy of obj.

# class Klass
#   attr_accessor :str
# end
#
# module Foo
#   def foo; 'foo'; end
# end
#
# s1 = Klass.new #=> #<Klass:0x401b3a381>
# s1.extend(Foo) #=> #<Klass:0x401b3a381>
# s1.foo #=> "foo"
#
# s2 = s1.clone #=> #<Klass:0x401b3a381>
# s2.foo #=> "foo"
#
# s3 = s1.dup #=> #<Klass:0x401b3a381>
# s3.foo #=> NoMethodError: undefined method `foo' for #<Klass:0x401b3a381>


# ========== .captures ==========
# Returns the array of captures; equivalent to .to_a[1..-1].

# /(.)(.)(\d+)(\d)/.match("THX1138.").captures
# => ["H", "X", "113", "8"]
