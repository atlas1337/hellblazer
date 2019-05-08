module Hellblazer
  module Plugins
    # Quotes Plugin
    module Quotes

      extend Discordrb::Commands::CommandContainer

      command(
        :quote, max_args: 0,
        description: 'Output a random quote, or manage quotes.',
        usage: 'quote'
      ) do |event|
        break unless check_tos(event, event.user.id) == true

		# Load database
        db = SQLite3::Database.new 'db/master.db'
        rows = db.execute('SELECT quote FROM quotes WHERE server_id = ?', event.server.id)
        db.close if db

        output = rows.sample.sample.to_s unless rows.empty?
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

        begin
          db = SQLite3::Database.new 'db/master.db'
          db.execute(
            'INSERT INTO quotes (quote, added_by, server_id, server_name) '\
            'VALUES (?, ?, ?, ?)', text.join(' '), event.user.id, event.server.id, event.server.name
          )
          db.close if db
        rescue SQLite3::Exception => e
          event.respond 'That quote already exists.'
          break
        end

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

        db = SQLite3::Database.new 'db/master.db'
        check = db.execute('SELECT count(*) FROM quotes '\
                           'WHERE quote = ? AND server_id = ?', text.join(' '), event.server.id)[0][0]
        break event.respond 'That quote doesn\'t exist.' unless check == 1

        db.execute('DELETE FROM quotes WHERE quote = ? AND server_id = ?', text.join(' '), event.server.id)
        db.close if db

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
