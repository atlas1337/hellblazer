module Hellblazer
  module Plugins
    # Quotes Plugin
    module Reminders

      extend Discordrb::Commands::CommandContainer

      command(
        %s(remind.me),
        description: 'Sets a reminder.',
        usage: 'remind.me'
      ) do |event, time, *reminder|
        break unless check_tos(event, event.user.id) == true
        check_reminders_table
        if unallowed_input(reminder.join(' ')) == true || unallowed_input(time) == true
          break event.respond 'Entered content not allowed'
        end

        time = time.gsub('d', ' * 86400 +').gsub('h', ' * 3600 +').gsub('m', ' * 60 +').gsub('s', ' * 1 +')
        raw_remind_time = Time.now + time.calculate
        remind_time = raw_remind_time.strftime("%Y-%m-%d %H:%M:%S")

        db = SQLite3::Database.new 'db/master.db'
        db.execute(
          'INSERT INTO reminders (reminder, user, remind_time) '\
          'VALUES (?, ?, ?)', reminder.join(' '), event.user.id, remind_time.to_s
        )
        reminderLoop unless Hellblazer.reminder_running == true
        nil
      end
    end
  end
end
