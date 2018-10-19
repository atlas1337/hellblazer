class String
  def numeric?
    begin
      Integer(self)
    rescue
      false # not numeric
    else
      true # numeric
    end
  end
end

class String
  def calculate
    [:+, :-, :*, :/].each do |op|
      factors = self.split(op.to_s)
      return factors.map(&:calculate).inject(op) if factors.size > 1
    end
    to_f # No calculation needed
  end
  alias calc calculate
end

#class Object
#  def blank?
#    if self.nil? || self.empty?
#      true # no value or nil value
#    else
#      false # numeric
#    end
#  end
#end

def unallowed_input(text)
  bad_words = ['http', 'https', 'www.', '.com', '.org', '.net', '.us', '://']
  return bad_words.any? {|bad_word| text.include?(bad_word) }
end

def pollLoop(server)
  Thread::abort_on_exception = true
  Thread.new do
    db = SQLite3::Database.new "db/#{server}.db"
    time = db.execute('SELECT poll_time FROM poll WHERE id=1')[0][0].to_i
    channel = db.execute('SELECT channel_id FROM poll WHERE id=1')[0][0].to_i
    loop do
      break_loop = false
      x = db.execute('SELECT elapsed_time FROM poll WHERE id = 1')[0][0]
      if x <= time
        db.execute('UPDATE poll SET elapsed_time = elapsed_time + 1 WHERE id = 1')
        sleep 1
      else
        break_loop = true
      end
      break if break_loop
    end

    winner = 'Poll Results:' + "\n\n"
    winners = db.execute(
      'SELECT * FROM poll WHERE votes = (SELECT MAX(votes) FROM poll)'
    )

    winners.each do |w|
      winner << w[4] + ': with ' + w[5].to_s + ' votes!' + "\n"
    end
    Hellblazer.bot.send_message(channel, winner)
    db.execute('DELETE FROM poll')
    db.execute('DELETE FROM poll_voters')
    Thread.exit
  end
end

def reminderLoop
  Thread::abort_on_exception = true
  reminderthread = Thread.new do
    loop do
      Hellblazer.reminder_running = true
      db = SQLite3::Database.new "db/master.db"
      reminders = db.execute('SELECT * FROM reminders ORDER BY datetime(remind_time) DESC')
      if !reminders.empty? && (Time.parse(reminders[0][3]) <= Time.now)
        Hellblazer.bot.user(reminders[0][2]).pm(reminders[0][1])
        db.execute('DELETE FROM reminders WHERE id = ?', reminders[0][0])
      elsif reminders.empty?
        Hellblazer.reminder_running = false
        reminderthread.exit
      end
      db.close if db
      sleep 1
    end
  end
end
