def check_quotes_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'quotes')
  if table[0][0] == 0
    # Create quotes table
    db.execute <<-SQL
      create table if not exists quotes (
        quote text,
        added_by int,
        server_id int,
        server_name text
      );
    SQL

    query = [
      'ALTER TABLE quotes ADD COLUMN quote text',
      'ALTER TABLE quotes ADD COLUMN added_by int',
      'ALTER TABLE quotes ADD COLUMN server_id int',
      'ALTER TABLE quotes ADD COLUMN server_name text'
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
