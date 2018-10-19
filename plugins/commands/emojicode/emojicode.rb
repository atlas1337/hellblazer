module Hellblazer
  module Plugins
    # Emojicode plugin
    module Emojicode
      extend Discordrb::Commands::CommandContainer

      class Emojicode < ActiveRecord::Base
        self.primary_key = :server_id
      end

      command(
        :emojicode, max_args: 0,
        desc: "List of our emoji shorthand meanings",
        usage: "emojicode"
      ) do |event|
        break unless check_tos(event, event.user.id) == true

        emojicode = Emojicode.where(server_id: event.server.id)
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

        emojicode = Emojicode.where(
          server_id: event.server.id
        )

        if emojicode.empty?
          Emojicode.create(
            server_id: event.server.id,
            emojicode_text: text
          )
        elsif !emojicode.empty?
          emojicode.update(
            event.server.id,
            emojicode_text: text
          )
        end

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
