module Hellblazer
  module Plugins
    # Plugin to quote John Constantine
    module Mention
      extend Discordrb::EventContainer
	  #require 'ruby-cleverbot-api'

      mention do |event|
	    puts 'test'
	    # Load database
        #db = SQLite3::Database.new 'db/master.db'
        #api_key = db.execute('SELECT api_key FROM api WHERE server_id = ? AND api = cleverbot', event.server.id)
        #db.close if db
		#if !api_key.empty?
		  
        event.channel.start_typing
        sleep 5
        event.respond Hellblazer.conf['mention_text'].sample
		
		#bot = Cleverbot.new('a7c71377c311617ef99de13b4b7a09b8')
		#text = event.content
		#text.slice! '<@!436248155697315850>'
		#puts text
		#event.respond text
		#event.respond bot.send_message(text)
      end
    end
  end
end
