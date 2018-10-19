module Hellblazer
  module Plugins
    # Band names plugin
    module BandNames
      extend Discordrb::Commands::CommandContainer

      class Bandnames < ActiveRecord::Base
      end

      command(
        :band, min_args: 0,
        description: 'Display a random band name.',
        usage: 'band'
      ) do |event|
        break unless check_tos(event, event.user.id) == true

        rows = Bandnames.where(server_id: event.server.id)
        output = rows.sample unless rows.empty?

        break event.respond 'There are no bands.' if rows.empty?
        user = event.bot.member(event.server.id, event.user.id).display_name
        response = "#{output.name} is #{user}'s new band name." if output.genre.nil?
        response = "#{output.name} is #{user}'s new #{output.genre} band name." unless output.genre.nil?

        creator = event.bot.member(event.server.id, output.added_by).display_name

        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_bandnames'] }
          e.add_field name: 'Band Name:', value: response, inline: false
          e.add_field name: 'Creator:',
                      value: creator,
                      inline: true
          e.color = Hellblazer.conf['embed_color']
        end
      end

      command(
        %s(band.add), min_args: 1,
        description: 'Add a band name to the database.',
        usage: 'band.add <text> :: optional<genre>'
      ) do |event, *text|
        break unless check_tos(event, event.user.id) == true
        event.message.delete
        break event.respond 'Entered content not allowed' if unallowed_input(text.join(' ')) == true

        textarray = text.join(' ').split('::')
        band = textarray[0].strip
        genre = textarray[1].strip unless textarray[1].nil? || textarray[1] == ' '
        genre = nil if textarray[1].nil? || textarray[1] == ' '
        user = event.user.id

        check = Bandnames.where(name: band, server_id: event.server.id)
        break event.respond 'That band already exists.' unless check.empty?

        bandname = Bandnames.create(
          name: band,
          genre: genre,
          added_by: event.user.id,
          server_id: event.server.id,
          server_name: event.server.name
        )
        bandname.save

        genre = 'N/A' if genre.nil?

        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_bandnames'] }
          e.description = 'The following band was added to the database:'
          e.add_field name: 'Band:', value: band, inline: false
          e.add_field name: 'Genre:', value: genre, inline: true
          e.add_field name: 'Added By:', value: user,
                      inline: true
          e.color = Hellblazer.conf['embed_color']
        end
      end

      command(
        %s(band.remove), min_args: 1,
        description: 'Remove a band from your quote database.',
        usage: 'band.remove <text>'
      ) do |event, *text|
        break unless check_tos(event, event.user.id) == true
        break if !Hellblazer.conf['owners'].include? event.user.id
        event.message.delete

        check = Bandnames.where(name: text.join(' '), server_id: event.server.id)
        break event.respond 'That band Doesn\'t exist.' unless !check.empty?
        Bandnames.where(
          name: text.join(' '),
          server_id: event.server.id
        ).delete_all

        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_bandnames'] }
          e.description = 'The following band name '\
                          'was removed from the database:'
          e.add_field name: 'Band Name:', value: text.join(' '), inline: false
          e.add_field name: 'Removed By:', value: event.user.display_name,
                      inline: false
          e.color = Hellblazer.conf['embed_color']
        end
      end
    end
  end
end
