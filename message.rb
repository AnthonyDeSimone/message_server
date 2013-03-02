require "win32/api"       
require 'json'
require 'eventmachine'

PORT	=	1233
MB_OK = 0x00000000
ICONS = {question: 0x00000020, 
				exclamation: 0x00000030, 
				info: 0x00000040}


loop do
	Thread.start(TCPServer.new(PORT).accept) do |client|
		begin
			while command = client.gets
				begin
					params = JSON.parse(command)
					if(params.has_key?("title") && params.has_key?("message") && params.has_key?("icon"))
						title = params["title"]
						message = params["message"]
						icon = ICONS[params["icon"].to_sym]
						
						messagebox = Win32::API.new("MessageBox", 'LPPI', 'I', "user32")
						messagebox.call(0, message, title, MB_OK | icon) 			
						client.puts "ack"
					else
						client.puts "nak"
					end
				rescue
					client.puts "nak"
				end
			end
		ensure
			s.close
		end
	end
end

