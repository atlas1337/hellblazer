module Hellblazer
  module Plugins
    # Avatar plugin
    module Avatar
      extend Discordrb::Commands::CommandContainer

      command(
        :avatar, min_args: 1, max_args: 1,
        description: 'Fetches a user\'s avatar.'
      ) do |event, arg|
        break unless check_tos(event, event.user.id) == true
        parse = event.bot.parse_mention(arg)
        break event.respond 'You must mention a user' if parse.nil?
        event.respond parse.avatar_url
      end

      command(
        %s(avatar.server), max_args: 0,
        description: 'Fetches a server\'s avatar.'
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        event.respond event.server.icon_url
      end
    end
  end
end
