module Hellblazer
  module Plugins
    # Plugin to quote John Constantine
    module Mention
      extend Discordrb::EventContainer

      mention do |event|
        event.channel.start_typing
        sleep 5
        event.respond Hellblazer.conf['mention_text'].sample
      end
    end
  end
end
