module Hellblazer
  module Plugins
    # Myanimelist lookup plugin
    module Myanimelist
      require 'jikan.rb'
      require "#{__dir__}/regexmap.rb"
      extend Discordrb::Commands::CommandContainer

      command(
        :anime, min_args: 1,
        desc: 'Search for an anime.',
        usage: 'anime <search terms>'
      ) do |event, *query|
        break unless check_tos(event, event.user.id) == true
        if unallowed_input(query.join(' ')) == true
          event.message.delete
          event.respond 'Entered content not allowed'
        end

        jikan = Jikan::Query.new
        search = jikan.search(query.join(' '), :anime)
        id = search.result[0].raw['mal_id']
        anime = jikan.anime_id id
        re = Regexp.new(REGEXMAP.keys.join('|'))
        anime.raw['synopsis'] = anime.raw['synopsis'].gsub(re, REGEXMAP) unless anime.raw['synopsis'].nil?

        break event << 'No results found' if anime.nil?

        japtitle = anime.raw['title']
        engtitle = anime.raw['title_english']
        status = anime.raw['status']
        episodes = anime.raw['episodes'].to_s
        score = anime.raw['score'].to_s
        type = anime.raw['type']
        image = anime.raw['image_url']
        start = anime.raw['aired']['from']
        finish = anime.raw['aired']['to']
        synopsis = anime.raw['synopsis']
        url = anime.raw['link_canonical']

        event.channel.send_embed do |e|
          e.title = "English Title: #{engtitle}/ Japanese Title: #{japtitle}"
          e.description = synopsis
          e.thumbnail = { url: image }
          e.add_field name: 'Status', value: status, inline: true
          e.add_field name: 'Air Dates', value: "#{start} to #{finish}",\
                      inline: true
          e.add_field name: 'Score', value: score, inline: true
          e.add_field name: 'Episodes', value: episodes, inline: true
          e.add_field name: 'Type', value: type, inline: true
          e.add_field name: 'URL', value: url,\
                      inline: true
          e.color = Hellblazer.conf['embed_color']
        end
      end

      command(
        :manga, min_args: 1,
        desc: 'Search for a Manga.',
        usage: 'manga <search terms>'
      ) do |event, *query|
        break unless check_tos(event, event.user.id) == true
        if unallowed_input(query.join(' ')) == true
          event.message.delete
          event.respond 'Entered content not allowed'
        end

        jikan = Jikan::Query.new
        search = jikan.search(query.join(' '), :manga)
        id = search.result[0].raw['mal_id']
        manga = jikan.manga_id id
        break event << 'No results found' if manga.nil?
        re = Regexp.new(REGEXMAP.keys.join('|'))
        manga.raw['synopsis'] = manga.raw['synopsis'].gsub(re, REGEXMAP) unless manga.raw['synopsis'].nil?

        japtitle = manga.raw['title']
        engtitle = manga.raw['title_english']
        status = manga.raw['status']
        volumes = manga.raw['volumes'].to_s
        score = manga.raw['score'].to_s
        image = manga.raw['image_url']
        start = manga.raw['published']['from']
        finish = manga.raw['published']['to']
        synopsis = manga.raw['synopsis']
        url = manga.raw['link_canonical']

        event.channel.send_embed do |e|
          e.title = "English Title: #{engtitle}/ Japanese Title: #{japtitle}"
          e.description = synopsis
          e.thumbnail = { url: image }
          e.add_field name: 'Status', value: status, inline: true
          e.add_field name: 'Run Dates', value: "#{start} to #{finish}",\
                      inline: true
          e.add_field name: 'Score', value: score, inline: true
          e.add_field name: 'Volumes', value: "#{volumes}",\
                      inline: true
          e.add_field name: 'URL', value: url,\
                      inline: true
          e.color = Hellblazer.conf['embed_color']
        end
      end
    end
  end
end
