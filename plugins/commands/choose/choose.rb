module Hellblazer
  module Plugins
    # Choose plugin
    module Choose
      extend Discordrb::Commands::CommandContainer

      command(
        :choose, min_args: 2,
        description: 'Make the bot choose something randomly.',
        usage: 'choose <choice>, <choice>'
      ) do |event, *choices|
        break unless check_tos(event, event.user.id) == true
        if unallowed_input(choices.join(' ')) == true
          event.message.delete
          event.respond 'Entered content not allowed'
        end
        # Output a message from the choicemessage array in the config file,
        # and insert a random choice from the ones provided
        event.respond Hellblazer.conf['choose_message'].sample % {
          choice: choices.join(' ').split(', ').sample
        }
        nil
      end
    end
  end
end
