#!/usr/bin/env ruby

require 'bundler/setup'
require 'discordrb'
require 'fileutils'
require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'yajl'
require_relative('classes.rb')
require_relative('db_functions.rb')

# This is the main bot Module
module Hellblazer
  class << self
    attr_accessor :conf
    attr_accessor :api
    attr_accessor :bot
    attr_accessor :server
    attr_accessor :started
    attr_accessor :reminder_running
  end

  $LOAD_PATH << File.join(File.dirname(__FILE__))

  self.conf = Yajl::Parser.parse(File.new('config.json', 'r'))
  self.api = Yajl::Parser.parse(File.new('apikeys.json', 'r'))

  prefix_proc = proc do |message|
    # Since we may get commands in channels we didn't define a prefix for, we can
    # use a logical OR to set a "default prefix" for any other channel as
    # PREFIXES[] will return nil.
    db = SQLite3::Database.new 'db/master.db'
    prefix = db.execute('SELECT prefix FROM bot_prefix WHERE server_id = ?', message.channel.server.id)[0][0] || conf['prefix']
    message.content[prefix.size..-1] if message.content.start_with?(prefix)
  end

  self.bot = Discordrb::Commands::CommandBot.new(
    token: api['discord_token'],
    client_id: api['client_id'],
    prefix: prefix_proc,
    intents: :all
  )
  self.started = false
  self.reminder_running = false

  Dir['plugins/*/*/*.rb'].each do |file|
    require file
  end

  Plugins.constants.each do |mod|
    bot.include! Plugins.const_get mod
  end

  Yajl::Encoder.encode(
    conf, [File.new('config.json', 'w'), { pretty: true, indent: '\t' }]
  )

  # Configure a database for each connected server.
    bot.ready do |event|
      if self.started == false
        check_tos_table
		    check_api_table
        check_prefix_table
        event.bot.servers.keys.each do |s|
          #manageMusic(s)
          #event.bot.server(s).members.each do |m|
          #  db = SQLite3::Database.new "db/#{s}.db"
          #  db.execute('INSERT OR IGNORE INTO currency (userid, amount) '\
          #           'VALUES (?, ?)', m.id, 100)
          #  db.execute('INSERT OR IGNORE INTO levels (userid, level, xp) '\
          #           'VALUES (?, ?, ?)', m.id, 1, 0)
          #  db.close if db
          #end
          #self.bot.send_message(s, 'I\'m here and ready for commands!')
          #db = SQLite3::Database.new "db/#{s}.db"
          #poll_table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'poll')
          #pollstarted = ''
          #if poll_table[0][0] == 1
          #  begin
          #    pollstarted = db.execute('SELECT started FROM poll WHERE id=1')[0][0].to_i
          #    db.close if db
          #  rescue NoMethodError
          #    db.close if db
          #    next
          #  end
          #  pollLoop(s)
          #end
          self.started == true
        end
        # Here we output the invite URL to the console so the bot account can be
        # invited to the channel.
        puts "This bot's invite URL is #{bot.invite_url}&permissions=261120"
        puts 'Click on it to invite it to your server.'
      end
    end

    bot.server_create do |event|
      joinedServer = event.server.id
      add_default_prefix(joinedServer)
      #manageMusic(joinedServer)
      #dbSetup(joinedServer)
      event.bot.server(event.server.id).members.each do |m|
        #db = SQLite3::Database.new "db/#{joinedServer}.db"
        #db.execute('INSERT OR IGNORE INTO currency (userid, amount) '\
        #           'VALUES (?, ?)', m.id, 100)
        #db.execute('INSERT OR IGNORE INTO levels (userid, level, xp) '\
        #           'VALUES (?, ?, ?)', m.id, 1, 0)
        #db.close if db
      end
    end

    #bot.server_delete do |event|
    #  File.delete('db/' + event.server.id + '.db')
    #end

  bot.run
end
