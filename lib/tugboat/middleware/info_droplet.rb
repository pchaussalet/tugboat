module Tugboat
  module Middleware
    class InfoDroplet < Base
      def call(env)
        ocean = env["ocean"]

        req = ocean.droplets.show env["droplet_id"]

        if req.status == "ERROR"
          say "#{req.status}: #{req.error_message}", :red
          exit 1
        end

        droplet = req.droplet

          if droplet.status == "active"
            status_color = GREEN
          else
            status_color = RED
          end

        attribute = env["user_attribute"]

        attributes = {
          "name" => droplet.name,
          "id" => droplet.id,
          "status" => droplet.status,
          "ip_address" => droplet.ip_address,
          "private_ip_address" => droplet.private_ip_address,
          "region_id" => droplet.region_id,
          "image_id" => droplet.image_id,
          "size_id" => droplet.size_id,
          "backups_active" => (droplet.backups_active || false)
        }

        if attribute
          if attributes.has_key? attribute
            say attributes[attribute]
          else
            say "Invalid attribute \"#{attribute}\"", :red
            say "Provide one of the following:", :red
            attributes.keys.each { |a| say "    #{a}", :red }
          end
        else
          if env["user_porcelain"]
            attributes.select{ |_, v| v }.each{ |k, v| say "#{k} #{v}"}
          else
            say
            say "Name:             #{droplet.name}"
            say "ID:               #{droplet.id}"
            say "Status:           #{status_color}#{droplet.status}#{CLEAR}"
            say "IP:               #{droplet.ip_address}"

            if droplet.private_ip_address
    	        say "Private IP:       #{droplet.private_ip_address}"
    	      end

            say "Region ID:        #{droplet.region_id}"
            say "Image ID:         #{droplet.image_id}"
            say "Size ID:          #{droplet.size_id}"
            say "Backups Active:   #{droplet.backups_active || false}"
          end
        end

        @app.call(env)
      end
    end
  end
end

