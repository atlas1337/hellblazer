module Hellblazer
  module Plugins
    # Emojicode plugin
    module Emojicode
      extend Discordrb::Commands::CommandContainer
      require_relative('emojicode_db.rb')
      check_emojicode_table

      command(
        :emojicode, max_args: 0,
        desc: "List of our emoji shorthand meanings",
        usage: "emojicode"
      ) do |event|
        break unless check_tos(event, event.user.id) == true

        db = SQLite3::Database.new 'db/master.db'
        emojicode = db.execute('SELECT emojicode_text FROM emojicode WHERE server_id = ?', event.server.id)[0][0]
        db.close if db

        break event.respond 'This server has no Emoji Code.' if emojicode.empty?

        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_emojicode'] }
          e.color = Hellblazer.conf['embed_color']
          e.title = 'Emoji Code'
          e.description = emojicode.first.emojicode_text
        end
      end

      command(
        %s(emojicode.set), min_args: 0,
        desc: 'Update emoji shorthand meanings',
        usage: 'emojicode.set'
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        break unless event.server.member(event.user.id).defined_permission?(:administrator)
        text = event.message.content[15..-1]
        event.message.delete
        break event.respond 'Entered content not allowed' if unallowed_input(text) == true

        db = SQLite3::Database.new 'db/master.db'
        db.execute('UPDATE emojicode SET emojicode_text = ? WHERE server_id = ?', text, event.server.id)
        db.close if db

        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_emojicode'] }
          e.color = Hellblazer.conf['embed_color']
          e.title = 'Emoji Code Updated'
          e.description = 'The emojicode was updated'
        end
      end
    end
  end
end
