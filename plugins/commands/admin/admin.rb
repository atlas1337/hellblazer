module Hellblazer
  module Plugins
    # Admin plugin module
    module Admin
      extend Discordrb::Commands::CommandContainer

      command(
        :agree,
        description: 'Agree to the terms of service',
        usage: 'agree'
      ) do |event|
        if check_tos(event, event.user.id) == 'sent'
          db = SQLite3::Database.new 'db/master.db'
          time = Time.new
          db.execute('UPDATE terms_of_service SET accepted = ? WHERE user_id = ?', 'true', event.user.id)
          db.execute('UPDATE terms_of_service SET accepted_date = ? WHERE user_id = ?', time.inspect, event.user.id)
          event.user.pm('You may now use the bot. If you wish to remove your content from the bot in the future ' \
		                'run the command !delete.me')
          db.close if db
        end
        nil
      end

      command(
        %s(delete.me),
        description: 'Remove your data from the bot',
        usage: 'delete.me'
      ) do |event|
        db = SQLite3::Database.new 'db/master.db'
        db.execute('DELETE FROM bandnames WHERE added_by = ?', event.user.id)
		db.execute('DELETE FROM quotes WHERE added_by = ?', event.user.id)
		db.execute('DELETE FROM reminders WHERE user = ?', event.user.id)
        db.close if db
		event.user.pm('Your data has been removed from the database.')
      end
      # End of the delete.me command.

      command(
        :prefix, min_args: 1,
        required_permissions: [:manage_server],
        permission_message: 'You don\'t have permission to use this command',
        description: 'Set the bot prefix for your server',
        usage: 'prefix !'
      ) do |event, prefix|
        break unless check_tos(event, event.user.id) == true
        db = SQLite3::Database.new 'db/master.db'
        begin
          db.execute(
            'REPLACE INTO bot_prefix (server_id, prefix) '\
            'VALUES (?, ?)', event.server.id, prefix.strip
          )
        rescue SQLite3::Exception
          event.respond 'Something went wrong here...'
          break
        end
        db.close if db
        nil
      end

      command(
        %s(bot.avatar), min_args: 1, max_args: 1,
        description: 'Update the bot\'s avatar.',
        usage: 'bot.avatar <image url>'
      ) do |event, arg|
        event.message.delete
        break unless check_tos(event, event.user.id) == true
        break if !BruhBot.conf['owners'].include? event.user.id

        open(arg) do |f|
          File.open('avatars/bot.png', 'wb') do |file|
            file.puts f.read
          end
        end
        Hellblazer.bot.profile.avatar = File.open('avatars/bot.png', 'r')
        File.delete('avatars/bot.png')
        nil
      end

      command(
        :update, min_args: 0, max_args: 0,
        description: 'Update the bot.',
        usage: 'update'
      ) do |event|
        event.message.delete
        break unless check_tos(event, event.user.id) == true
        break if !Hellblazer.conf['owners'].include? event.user.id

        event.respond 'Updating and restarting!'
        exec("#{File.expand_path File.dirname(__FILE__)}/update.sh update")
      end

      command(
        :restart, min_args: 0, max_args: 0,
        description: 'Restart the bot.',
        usage: 'restart'
      ) do |event|
        event.message.delete
        break unless check_tos(event, event.user.id) == true
        break if !Hellblazer.conf['owners'].include? event.user.id

        event.respond 'Restarting!'
        exec("#{File.expand_path File.dirname(__FILE__)}/update.sh restart")
      end

      command(
        :shutdown,
        help_available: false
      ) do |event|
        event.message.delete
        break unless check_tos(event, event.user.id) == true
        break if !Hellblazer.conf['owners'].include? event.user.id

        event.respond admin_conf['shutdownmessage'].sample
        event.bot.stop
      end

      command(
        %s(nick.user), min_args: 2,
        description: 'Change a user\'s nickname.',
        usage: 'nick <user id> <text>'
      ) do |event, userid, *nick|
        break unless check_tos(event, event.user.id) == true
        break event << Hellblazer.conf['perm_error'] unless event.server.member(event.user.id).defined_permission?(:manage_nicknames)

        nick = nick.join(' ')
        event.bot.member(event.server.id, userid).nick = nick
        nil
      end

      command(
        :status, min_args: 1,
        description: 'sets bot game'
      ) do |event, *game|
        event.message.delete
        break unless check_tos(event, event.user.id) == true
        break event << Hellblazer.conf['perm_error'] unless event.server.member(event.user.id).defined_permission?(:administrator)

        event.bot.game = game.join(' ')
        nil
      end

      command(
        :clear, min_args: 1, max_args: 1,
        description: 'Prune X messages from channel'
      ) do |event, number|
        event.message.delete
        break unless check_tos(event, event.user.id) == true
        break event << Hellblazer.conf['perm_error'] unless event.server.member(event.user.id).defined_permission?(:manage_messages)
        break event.respond('Please enter a valid number.') if /\A\d+\z/.match(number).nil?
        event.channel.prune(number.to_i)
        stuff = event.respond("[#{number.to_i}] messages cleared.").id
        sleep 5
        event.channel.load_message(stuff).delete
      end

      command(
        :roles, min_args: 0, max_args: 0,
        description: 'Get info on all the roles on the server.'
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        roles = event.server.roles
        output = '```'
        roles.each do |role|
          output += "Name:#{role.name}, ID:#{role.id}, "\
                    "Permissions:#{role.permissions.bits}\n"
          next if output.length < 1800
          output += '```'
          event.user.pm(output)
          output = '```'
        end
        output += '```'
        event.user.pm(output)
        nil
      end

      command(
        %s(role.add), min_args: 2,
        description: 'Assign a user a role',
        usage: 'role @user @role'
      ) do |event|
		  break unless check_tos(event, event.user.id) == true
		  break event << Hellblazer.conf['perm_error'] unless event.server.member(event.user.id).defined_permission?(:administrator)
		  break event << 'Please enter at least one user' if event.message.mentions.nil?
		  break event << 'Please enter at least one role' if event.message.role_mentions.nil?
		  event.message.mentions.each do |user|
		  	roles = []
		  	role_names = []
		  	event.message.role_mentions.each do |role|
		  	  next if event.server.member(user.id).role?(role) == true
		  	  roles << role
		  	  role_names << role.name
		  	end
		  	if !roles.empty?
		  	  event.server.member(user.id).add_role(roles)
		  	  user.pm('You have been granted the role: ' + role_names[0] + ' on the server ' + event.server.name) if roles.size <= 1
		  	  user.pm('You have been granted the roles: ' + role_names.join(', ') + ' on the server ' + event.server.name) if roles.size > 1
		  	else
		  	  event.user.pm('The user ' + user.name + ' already has all of those roles')
		  	end
		  end
        nil
      end
    end
    # End of the Admin module.
  end
end
