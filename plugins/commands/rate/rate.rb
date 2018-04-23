
module Hellblazer
  module Plugins
    # Rate plugin
    module Rate
      extend Discordrb::Commands::CommandContainer

      command(
        :rate, min_args: 1,
        description: 'Rate things!',
        usage: 'rate <stuff>'
      ) do |event, *text|
        break unless check_tos(event, event.user.id) == true
        break event.respond 'Entered content not allowed' if unallowed_input(text.join(' ')) == true
        event.respond "I give #{text.join(' ')} a "\
                      "#{rand(0.0..10.0).round(1)}/10.0!"
      end
    end
  end
end
