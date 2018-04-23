module Hellblazer
  module Plugins
    # Plugin to quote John Constantine
    module Tableflip
      extend Discordrb::EventContainer

      # Load config file
      quotes = Yajl::Parser.parse(
        File.new("#{__dir__}/config.json", 'r')
      )

      mention do |event|
        event.respond quotes['quotes'].sample
      end
    end
  end
end
