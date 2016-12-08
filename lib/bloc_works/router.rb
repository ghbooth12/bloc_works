module BlocWorks
  class Application
    def controller_and_action(env)
      puts ">>>> Rounter1 is working, #{env}"
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
      puts ">>>> Rounter2 is working, #{env}"
      if env['PATH_INFO'] == '/favicon.ico'
        # This route returns an empty HTML page, with the status code 404.
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end
  end
end
