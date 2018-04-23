module Hellblazer
  module Plugins
    # Emojicode plugin
    module Emojicode
      extend Discordrb::Commands::CommandContainer

      command(
        :emojicode, max_args: 0,
        desc: "List of our emoji shorthand meanings",
        usage: "emojicode"
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        check_emojicode_table(event.server.id)

        db = SQLite3::Database.new "db/#{event.server.id}.db"
        emojicode = db.execute('SELECT emojicode_text FROM emojicode WHERE id = ?', 1)
        emojicode = emojicode[0][0]
        db.close if db

        break event.respond 'There is no emojicode.' unless !emojicode.empty?

        event.channel.send_embed do |e|
          e.thumbnail = { url: Hellblazer.conf['embed_image_emojicode'] }
          e.color = Hellblazer.conf['embed_color']
          e.title = 'Emoji Code'
          e.description = emojicode
        end
      end

      command(
        %s(emojicode.set), min_args: 0,
        desc: "Update emoji shorthand meanings",
        usage: "emojicode.set"
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        break unless event.server.member(event.user.id).defined_permission?(:administrator)
        text = event.message.content[14..-1]
        event.message.delete
        break event.respond 'Entered content not allowed' if unallowed_input(text) == true
        check_emojicode_table(event.server.id)

        db = SQLite3::Database.new "db/#{event.server.id}.db"
        db.execute('UPDATE emojicode SET emojicode_text = ? WHERE id = ?', text, 1)
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
