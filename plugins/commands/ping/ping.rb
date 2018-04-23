module Hellblazer
  module Plugins
    # Eightball plugin module
    module Ping
      extend Discordrb::Commands::CommandContainer

      command(
        :ping,
        description: 'Ping',
        usage: 'ping'
      ) do |event|
        # Output a random message from the eightball array in the config file.
        break unless check_tos(event, event.user.id) == true
        event.respond 'Pong'
      end
      # End of the 8ball command.
    end
    # End of the Eightball module.
  end
end
