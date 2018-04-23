
module Hellblazer
  module Plugins
    # Play plugin
    module Play
      extend Discordrb::Commands::CommandContainer

      command(
        :play, min_args: 2,
        description: 'Invite groups to play a game.',
        usage: 'play <gamename>, <groupname>'
      ) do |event, *text|
        break unless check_tos(event, event.user.id) == true
        event.message.delete
        break event.respond 'Entered content not allowed' if unallowed_input(text.join(' ')) == true

        # Convert array into string and back into an array separating game name
        # and groups/people with a comma.
        infoarray = text.join(' ').split(', ')

        # Assign variables to insert into message
        gamename = infoarray[0]
        groupname = infoarray[1]
        usermentions = event.message.mentions
        rolementions = event.message.role_mentions

        usermentions.map! do |g|
          g = event.bot.member(event.server.id, g.id).display_name
        end

        rolementions.map! do |g|
          g = "#{g.name} Role"
        end

        (usermentions << rolementions).flatten!
        recipients = usermentions.join(', ')

        event.respond groupname
        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_play'] }
          e.description = Hellblazer.conf['play_message'].sample
          e.add_field name: 'Game:',\
                      value: Hellblazer.conf['play_game_name'] % { gamename: gamename },\
                      inline: false
          e.add_field name: 'Sender:', value: event.user.mention, inline: true
          e.add_field name: 'Recipients:', value: recipients, inline: true
          e.color = Hellblazer.conf['embed_color']
        end
      end
    end
  end
end
