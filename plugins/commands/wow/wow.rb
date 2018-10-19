module Hellblazer
  module Plugins
    # WoW plugin module
    module Wow
      extend Discordrb::Commands::CommandContainer
      require 'ruby_blizzard'

      RubyBlizzard.initialize(api_key: Hellblazer.api['blizzard'])

      command(
        %s(wow.character), min_args: 2,
        description: 'Look up a WoW charcater.',
        usage: 'wow.character name realm'
      ) do |event, character_name, realm|
        break unless check_tos(event, event.user.id) == true
        if unallowed_input(character_name + realm) == true
          event.message.delete
          event.respond 'Entered content not allowed'
          break
        end

        event.message.delete
        character = RubyBlizzard::Wow::Character.find(character_name: character_name, realm: realm)
        # Output a random message from the eightball array in the config file.
        if character['error_code'] != 404
          event.channel.send_embed do |embed|
            embed.image = { url: character['thumbnail'] }
            embed.title = '**Character Name:** ' + character['name']
            embed.description = '```' + "\n" +\
              'Level: ' + character['level'].to_s + "\n\n" +\
              'Faction: ' + character['faction'] + "\n\n" +\
              'Gender: ' + character['gender'] + "\n\n" +\
              'Race: ' + character['race'] + "\n\n" +\
              'Class: ' + character['class'] + "\n\n" +\
              'Achievement Points: ' + character['achievementPoints'].to_s + "\n" +\
              '```'
            embed.color = Hellblazer.conf['embed_color']
          end
        else
          event.respond 'That character does not exist.'
        end
      end

      command(
        %s(wow.item), min_args: 1,
        description: 'Look up a WoW item.',
        usage: 'wow.item name'
      ) do |event, *item_name|
        break unless check_tos(event, event.user.id) == true
        if unallowed_input(item_name.join(' ')) == true
          event.message.delete
          event.respond 'Entered content not allowed'
          break
        end

        item = RubyBlizzard::Wow::Item.find(item_name: item_name.join(' '))
        # Output a random message from the eightball array in the config file.
        stats = ''
        if item['error_code'] != 404
          item['bonusStats'].each_with_index do |array, array_index|
          	stats += '+' + array['amount'].to_s + ' ' + array['stat'] + "\n"
          end
          event.channel.send_embed do |embed|
          #embed.thumbnail = { url: Hellblazer.conf['embed_image_quotes'] }
          #embed.description = item['description']
            embed.add_field name: 'Stats:', value: stats, inline: false
          #embed.add_field name: 'Gender:', value: character['gender']
          #embed.add_field name: 'Faction:', value: character['faction']
          #embed.add_field name: 'Race:', value: character['race']
          #embed.add_field name: 'Class:', value: character['class'],\
          #  inline: false
          #embed.add_field name: 'Level:', value: character['level']
          #embed.add_field name: 'Achievement Points:', value: character['achievementPoints']
            embed.color = Hellblazer.conf['embed_color']
          end
        else
          event.respond 'That character does not exist.'
        end
      end
    end
    # End of the wow.character command.
  end
  # End of the Wow module.
end
