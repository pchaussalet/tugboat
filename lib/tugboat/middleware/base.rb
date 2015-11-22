module Tugboat
  module Middleware
    # A base middleware class to initalize.
    class Base
      # Some colors for making things pretty.
      CLEAR      = "\e[0m"
      RED        = "\e[31m"
      GREEN      = "\e[32m"
      YELLOW     = "\e[33m"

      # We want access to all of the fun thor cli helper methods,
      # like say, yes?, ask, etc.
      include Thor::Shell

      def initialize(app)
        @app = app
        # This resets the color to "clear" on the user's terminal.
        say "", :clear, false
      end

      def call(env)
        @app.call(env)
      end

      def wait_for_state(droplet_id, desired_state,ocean)
        start_time = Time.now

        response = ocean.droplet.show droplet_id

        say ".", nil, false

        if !response.success?
          say "Failed to get status of Droplet: #{response.message}", :red
          exit 1
        end

        while response.droplet.status != desired_state do
          sleep 2
          response = ocean.droplet.show droplet_id
          say ".", nil, false
        end

        total_time = (Time.now - start_time).to_i

        say "done#{CLEAR} (#{total_time}s)", :green
      end

      # Get all pages of droplets
      def get_droplet_list(ocean)
        page = ocean.droplet.all(per_page: 200, page: 1)
        if not page.paginated?
          return page.droplets
        end

        Enumerator.new do |enum|
          page.droplets.each { |drop| enum.yield drop }
          for page_num in 2..page.last_page
            page = ocean.droplet.all(per_page: 200, page: page_num)
            page.droplets.each { |drop| enum.yield drop }
          end
        end
      end
    end
  end
end

