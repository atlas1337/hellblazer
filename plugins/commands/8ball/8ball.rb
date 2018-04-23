module Hellblazer
  module Plugins
    # Eightball plugin module
    module Eightball
      extend Discordrb::Commands::CommandContainer

      command(
        %s(8ball), min_args: 1,
        description: 'Consult the magic 8ball',
        usage: '8ball <question>'
      ) do |event, *text|
        break unless check_tos(event, event.user.id) == true
        if unallowed_input(text.join(' ')) == true
          event.message.delete
          event.respond 'Entered content not allowed'
          break
        end
        # Output a random message from the eightball array in the config file.
        event.respond ":8ball: #{Hellblazer.conf['eightball'].sample}"
      end
      # End of the 8ball command.
    end
    # End of the Eightball module.
  end
end
