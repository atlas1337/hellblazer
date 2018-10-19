module Hellblazer
  module Plugins
    # Quotes Plugin
    module Quotes

      extend Discordrb::Commands::CommandContainer

      class Quotes < ActiveRecord::Base
      end

      command(
        :quote, max_args: 0,
        description: 'Output a random quote, or manage quotes.',
        usage: 'quote'
      ) do |event|
        break unless check_tos(event, event.user.id) == true

        rows = Quotes.where(server_id: event.server.id)

        output = rows.sample.quote unless rows.empty?
        output = 'There are no quotes.' if rows.empty?

        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_quotes'] }
          e.add_field name: 'Quote:', value: output, inline: true
          e.color = Hellblazer.conf['embed_color']
        end
      end

      command(
        %s(quote.add), min_args: 1,
        description: 'Add a quote to your quote database.',
        usage: 'quote.add <text>'
      ) do |event, *text|
        break unless check_tos(event, event.user.id) == true
        event.message.delete
        break event.respond 'Entered content not allowed' if unallowed_input(text.join(' ')) == true

        check = Quotes.where(quote: text.join(' '), server_id: event.server.id)
        break event.respond 'That quote already exists.' unless check.empty?

        quotes = Quotes.create(
          quote: text.join(' '),
          added_by: event.user.id,
          server_id: event.server.id,
          server_name: event.server.name
        )
        quotes.save

        event.channel.send_embed do |embed|
          embed.thumbnail = { url: Hellblazer.conf['embed_image_quotes'] }
          embed.description = 'The following quote was added to the database:'
          embed.add_field name: 'Quote:', value: text.join(' '), inline: false
          embed.add_field name: 'Added By:', value: event.user.mention,\
                          inline: false
          embed.color = Hellblazer.conf['embed_color']
        end
      end

      command(
        %s(quote.remove), min_args: 1,
        description: 'Remove a quote from your quote database.',
        usage: 'quote.remove <text>'
      ) do |event, *text|
        break unless check_tos(event, event.user.id) == true
        break if !Hellblazer.conf['owners'].include? event.user.id
        event.message.delete

        check = Quotes.where(quote: text.join(' '), server_id: event.server.id)
        break event.respond 'That quote Doesn\'t exist.' unless !check.empty?
        Quotes.where(
          quote: text.join(' '),
          server_id: event.server.id
        ).delete_all

        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_quotes'] }
          e.description = 'The following quote was removed from the database:'
          e.add_field name: 'Quote:', value: text.join(' '), inline: false
          e.add_field name: 'Removed By:', value: event.user.mention,\
                      inline: false
          e.color = Hellblazer.conf['embed_color']
        end
      end
    end
  end
end
