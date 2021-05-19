def check_bandnames_table
  db = SQLite3::Database.new 'db/master.db'
  table = db.execute("SELECT count(*) FROM sqlite_master WHERE type = 'table' AND name = ?", 'bandnames')
  if table[0][0] == 0
    # Create bandnames table
    db.execute <<-SQL
      create table if not exists bandnames (
        name text,
        genre text,
        added_by int,
        server_id int,
        server_name text
      );
    SQL

    query = [
      'ALTER TABLE bandnames ADD COLUMN name text',
      'ALTER TABLE bandnames ADD COLUMN genre text',
      'ALTER TABLE bandnames ADD COLUMN added_by int',
      'ALTER TABLE bandnames ADD COLUMN server_id int',
      'ALTER TABLE bandnames ADD COLUMN server_name text'
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
