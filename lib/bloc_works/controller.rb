require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      puts ">>>> Controller class Initialize, env: #{env}"
      @env = env
    end

    def render(view, locals = {})
      puts ">>>> Controller class render, view: #{view}, locals: #{locals}"
      # File.join("usr", "mail", "gumby")   #=> "usr/mail/gumby"
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)
      # Erubis converts erb file into HTML.
      eruby = Erubis::Eruby.new(template)
      eruby.result(locals.merge(env: @env))
    end

    def controller_dir
      klass = self.class.to_s # klass = "LabelsController"
      klass.slice!("Controller") #=> Cut "Controller" out of klass
      BlocWorks.snake_case(klass) # klass == "Labels"
    end
  end
end
