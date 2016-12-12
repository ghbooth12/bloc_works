module BlocWorks
  class Application
    def controller_and_action(env)
      puts "\n<router.rb> BlocWorks::Application.controller_and_action(env)\nenv: #{env}\n"
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
      puts "\n<router.rb> BlocWorks::Application.fav_icon(env)\nenv: #{env}\n"
      if env['PATH_INFO'] == '/favicon.ico'
        # This route returns an empty HTML page, with the status code 404.
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end

    # &block consists of the routes we want to map.
    # This starts the mapping process.
    def route(&block)  # When Proc is used, &proc_name
      puts "\n<router.rb> BlocWorks::Application.route(&block)\nblock: #{block}\n"
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
  end

  class Router
    def initialize
      puts "\n<router.rb> BlocWorks::Router.initialize\n"
      # This defines which routes map to which destinations.
      @rules = []
    end

    # This builds route / action rules and add them to @rules.
    def map(url, *args)
      puts "\n<router.rb> BlocWorks::Router.map(url, *args)\nBEFORE url: #{url}, *args: #{args}\n"
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
      parts = url.split("/")
      parts.reject! {|part| part.empty?}  # Reject "", []

      vars, regex_parts = [], []

      # url is ":controller/:id"
      # parts is [":controller", ":id"]
      parts.each do |part|
        case part[0] # part is ":controller"
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)" # any one or more words
        when "*"
          vars << part[1..-1]  # . (Any character except line break), * (zero or more)
          regex_parts < "(.*)" # .* (first sentence)
        else
          regex_parts << part
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
      puts "\n<router.rb> BlocWorks::Router.map(url, *args)\nAFTER regex: #{regex}, vars: #{vars}, destination: #{destination}, options: #{options}\n"
      # regex: , vars: [], destination: books#welcome, options: {:default=>{}}
      # regex: ([a-zA-Z0-9]+)/([a-zA-Z0-9]+)/([a-zA-Z0-9]+), vars: ["controller", "id", "action"], destination: , options: {:default=>{}}
      # regex: ([a-zA-Z0-9]+)/([a-zA-Z0-9]+), vars: ["controller", "id"], destination: , options: {:default=>{"action"=>"show"}}
      # regex: ([a-zA-Z0-9]+), vars: ["controller"], destination: , options: {:default=>{"action"=>"index"}}
    end # Ends map

    # 'look_up_url' takes a URL and checks it against the @rules array of mapped routes.
    # If it finds a match it uses 'get_destination' to return the correct controller and action to call.
    def look_up_url(url)
      puts "\n<router.rb> BlocWorks::Router.look_up_url(url)\nurl: #{url}\n"
      @rules.each do |rule|
        # match is a Regexp method
        # /hay/.match('haystack') => #<MatchData "hay">
        rule_match = rule[:regex].match(url)

        if rule_match  # "", [] is truthy
          options = rule[:options] #=> {:default => { "action" => "show" }}
          params = options[:default].dup  # Read more below about dup

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
      puts "\n<router.rb> BlocWorks::Router.get_destination(destination, routing_params = {})\ndestination: #{destination}, routing_params: #{routing_params}\n"
      if destination.respond_to?(:call)
        return destination
      end

      if destination =~ /^([^#]+)#([^#]+)&/
        name = $1.capitalize
        controller = Object.const_get("#{name}Controller")
        return controller.action($2, routing_params)
      end
      raise "Destination no found: #{destination}"
    end

    # Map URLs to routes and look up routes when given a URL.
    def get_rack_app(env)
      puts "\n<router.rb> BlocWorks::Router.get_rack_app(env)\nenv: #{env}\nenv['PATH_INFO']: #{env["PATH_INFO"]}"
      if @router.nil?
        raise "No routes defined"
      end

      @router.look_up_url(env["PATH_INFO"])
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
