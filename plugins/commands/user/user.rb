module Hellblazer
  module Plugins
    # Choose plugin
    module User
      extend Discordrb::Commands::CommandContainer

      # Load choose config file
      user_conf = Yajl::Parser.parse(File.new("#{__dir__}/config.json", 'r'))

      command(
        :slap, min_args: 1,
        description: 'Slap someone.',
        usage: 'slap <user>'
      ) do |event, user|
        break unless check_tos(event, event.user.id) == true
        break event.respond 'Entered content not allowed' if unallowed_input(user.join(' ')) == true
        # Output a message from the choicemessage array in the config file,
        # and insert a random choice from the ones provided
        event.message.delete
        user = user.gsub(/<@!?(\d+)>/) { |s| event.bot.user($1.to_i).on(event.server).id }
        usermention = event.bot.member(event.server.id,user).mention
        event.respond "#{event.user.display_name} slapped #{usermention}!"
      end

      command(
        %s(nick.random), min_args: 0,
        description: 'Get a random nickname',
        usage: 'nick.random'
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        event.message.delete
        firstName = "#{user_conf['names'].sample}#{user_conf['names'].sample}"
        lastName = "#{user_conf['names'].sample}#{user_conf['names'].sample}"
        nick = "#{firstName} #{lastName}"
        while nick.length > 32 do
          nick = "#{firstName} #{lastName}"
        end
        event.bot.member(event.server.id, event.user.id).nick = nick
        nil
      end
    end
  end
end
