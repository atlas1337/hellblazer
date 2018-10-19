module Hellblazer
  module Plugins
    # Plugin to quote John Constantine
    module Mention
      extend Discordrb::EventContainer

      # Load config file
      quotes = Yajl::Parser.parse(
        File.new("#{__dir__}/config.json", 'r')
      )

      mention do |event|
        event.channel.start_typing
        sleep 5
        event.respond quotes['quotes'].sample
      end
    end
  end
end
