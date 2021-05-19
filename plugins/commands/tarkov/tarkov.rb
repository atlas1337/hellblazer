module Hellblazer
  module Plugins
    # Tarkov plugin
    module Tarkov
      extend Discordrb::Commands::CommandContainer

      command(
        :ammo,
        description: 'Link to ammo chart.',
        usage: 'ammo'
      ) do |event|
        break unless check_tos(event, event.user.id) == true
	
	event.respond "https://kokarn.github.io/tarkov-tools/"
      end

	  command(
        :map, min_args: 1,
        description: 'Display information about ammo',
        usage: 'map customs'
      ) do |event, map|
        break unless check_tos(event, event.user.id) == true

        # Load database
        db = SQLite3::Database.new 'db/tarkov.db'
		db.results_as_hash = true
        rows = db.execute('SELECT map_link FROM maps WHERE map_name = ?', map)
        db.close if db

        break event.respond 'That map doesn\'t exist' if rows.empty?
		event.respond map + ': ' + rows[0][0]
      end
    end
  end
end
