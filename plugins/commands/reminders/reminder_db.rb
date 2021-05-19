def check_reminders_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'reminders')
  if table[0][0] == 0
    # Create emojicode table
    db.execute <<-SQL
      create table if not exists reminders (
        id INTEGER PRIMARY KEY,
        reminder text,
        user int,
        remind_time text
      );
    SQL

    query = [
      'ALTER TABLE reminders ADD COLUMN reminder text',
      'ALTER TABLE reminders ADD COLUMN user int',
      'ALTER TABLE reminders ADD COLUMN remind_time text'
    ]
    query.each do |q|
      begin
        db.execute(q)
      rescue SQLite3::Exception
        next
      end
    end
  end
  db.close if db
  nil
end
