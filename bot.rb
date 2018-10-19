#!/usr/bin/env ruby

require 'bundler/setup'
require 'active_record'
require 'discordrb'
require 'fileutils'
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

  ActiveRecord::Base.establish_connection(
    :adapter=> 'sqlite3',
    :host => 'localhost',
    :database=> 'db/master.db'
  )
  ActiveRecord::Base.pluralize_table_names = false

  $LOAD_PATH << File.join(File.dirname(__FILE__))

  self.conf = Yajl::Parser.parse(File.new('config.json', 'r'))
  self.api = Yajl::Parser.parse(File.new('apikeys.json', 'r'))
  self.bot = Discordrb::Commands::CommandBot.new(
    token: api['discord_token'],
    client_id: api['discord_app_id'],
    prefix: conf['prefix']
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
        check_reminders_table
        check_bandnames_table
        check_quotes_table
        check_emojicode_table
        reminderLoop
        event.bot.servers.keys.each do |s|
          #manageMusic(s)
          #dbSetup(s)
          #event.bot.server(s).members.each do |m|
          #  db = SQLite3::Database.new "db/#{s}.db"
          #  db.execute('INSERT OR IGNORE INTO currency (userid, amount) '\
          #           'VALUES (?, ?)', m.id, 100)
          #  db.execute('INSERT OR IGNORE INTO levels (userid, level, xp) '\
          #           'VALUES (?, ?, ?)', m.id, 1, 0)
          #  db.close if db
          #end
          #self.bot.send_message(s, 'I\'m here and ready for commands!')
          db = SQLite3::Database.new "db/#{s}.db"
          poll_table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'poll')
          pollstarted = ''
          if poll_table[0][0] == 1
            begin
              pollstarted = db.execute('SELECT started FROM poll WHERE id=1')[0][0].to_i
              db.close if db
            rescue NoMethodError
              db.close if db
              next
            end
            pollLoop(s)
          end
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

    bot.server_delete do |event|
      File.delete('db/' + event.server.id + '.db')
    end

  bot.run
end
