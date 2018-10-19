
module Hellblazer
  module Plugins
    # Choose plugin
    module Spoiler
      extend Discordrb::Commands::CommandContainer

      FileUtils.mkpath 'images/spoiler' unless File.exist?('images/spoiler')

      command(
        :spoiler, min_args: 1,
        description: 'Create a spoiler for entered text',
        usage: 'spoiler <spoiler name> :: <spoiler text>'
      ) do |event, *args|
        # Create an image with text
        break unless check_tos(event, event.user.id) == true
        break event.respond 'Entered content not allowed' if unallowed_input(args.join(' ')) == true
        event.message.delete
        textarray = args.join(' ').split(' :: ')
        break event.respond 'Command usage: ``` !spoiler Harry Potter :: Hagrid is a giant ```' if textarray[0] == nil || textarray[1] == nil

        spoiler_name = textarray[0]
        message = textarray[1]

        event.channel.send_embed do |e|
          e.title = spoiler_name + ' Spoiler'
          #e.description = 
          e.add_field name: 'Poster:', value: event.user.mention, inline: false
          e.add_field name: 'Spoiler:', value: "[Hover to View](https://dummyimage.com/600x400/000/fff&text=#{URI.escape(message).gsub(/[_]/, "")} \"#{message}\")", inline: false
          #e.footer = Discordrb::Webhooks::EmbedFooter.new(text: event.user.name)
          e.color = Hellblazer.conf['embed_color']
        end
        nil
      end
    end
  end
end
