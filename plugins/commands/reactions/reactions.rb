module Hellblazer
  module Plugins
    # Reaction face plugin
    module Reactions
      extend Discordrb::Commands::CommandContainer

      require 'open-uri'

      FileUtils.mkpath 'images/reactions' unless File.exist?('images/reactions')

      command(
        [:react, :r], min_args: 1, max_args: 1,
        description: 'Shows a random smug reaction picture'
      ) do |event, reaction|
        break unless check_tos(event, event.user.id) == true
        break if !File.exist?('images/reactions/' + reaction) #reactions_conf[reaction].nil?
        images = Dir.entries('images/reactions/' + reaction).reject{|entry| entry =~ /^\.{1,2}$/}
        # Output a random image link from the config array
        image = images.sample
        event.send_file File.new('images/reactions/' + reaction + '/' + image) #reactions_conf[reaction.sample
      end

      command(
        %s(r.add), min_args: 2,
        description: 'Add a reaction image to the bot.',
        usage: 'r.add <reaction> :: <image URL>'
      ) do |event, *args|
        break unless check_tos(event, event.user.id) == true
        break event.respond 'You don\'t have permission.' if !Hellblazer.conf['owners'].include? event.user.id

        textarray = args.join(' ').split('::')
        reaction = textarray[0].strip
        string_url = textarray[1].strip
        url = URI.parse string_url
        accepted_formats = ['.jpg', '.jpeg', '.png', '.gif']

        break event.respond 'Please use a direct link.' unless accepted_formats.include? File.extname(string_url)
        FileUtils.mkpath 'images/reactions/' + reaction unless File.exist?('images/reactions/' + reaction)
        file_name = File.basename url.path 
        if !File.exist?('images/reactions/' + reaction + '/' + file_name)
	        open('images/reactions/' + reaction + '/' + file_name, 'wb') do |file|
	            file << open(string_url).read
	            event.respond 'Image has been added'
	        end
	    else
	    	event.respond 'That image already exists'
	    end
        nil
      end

      command(
        %s(r.import), min_args: 0, max_args: 0,
        description: 'Import reactions from an images.json file',
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        break event.respond 'You don\'t have permission.' if !Hellblazer.conf['owners'].include? event.user.id

        # Load config file
        reactions = Yajl::Parser.parse(
          File.new("#{__dir__}/images.json", 'r')
        )

        accepted_formats = ['.jpg', '.jpeg', '.png', '.gif']
        image_sites = ['https://imgur.com/', 'http://imgur.com/', 'http://i.imgur.com/']

        reactions.each do |key, array|
          FileUtils.mkpath 'images/reactions/' + key unless File.exist?('images/reactions/' + key)
          array.each do |value|
            next event.respond 'Please use a direct link.' unless accepted_formats.any? { |format| value.include?(format) }
            file_name = ''

            image_sites.each { |site|
              file_name = value.gsub(site, '')
            }

            open('images/reactions/' + key + '/' + file_name, 'wb') do |file|
              file << open(value).read
              nil
            end
          end
        end
      end
    end
  end
end
