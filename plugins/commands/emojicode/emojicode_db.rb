def check_emojicode_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'emojicode')
  if table[0][0] == 0
    # Create emojicode table
    db.execute <<-SQL
      create table if not exists emojicode (
        server_id int,
        emojicode_text text
      );
    SQL

    query = [
      'ALTER TABLE emojicode ADD COLUMN server_id int',
      'ALTER TABLE emojicode ADD COLUMN emojicode_text text'
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
