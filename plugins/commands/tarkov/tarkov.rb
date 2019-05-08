module Hellblazer
  module Plugins
    # Band names plugin
    module Tarkov
      extend Discordrb::Commands::CommandContainer

      command(
        :ammo, min_args: 1,
        description: 'Display information about ammo',
        usage: 'ammo 7.62x25'
      ) do |event, ammo, sort|
        break unless check_tos(event, event.user.id) == true

        # Load database
        db = SQLite3::Database.new 'plugins/commands/tarkov/tarkov.db'
		db.results_as_hash = true
        rows = db.execute('SELECT name, flesh_damage, penetration, armor_damage, '\
                          'fragmentation_chance, sold_by '\
						  'FROM ammo WHERE name LIKE ? ORDER BY flesh_damage', "%#{ammo}%")
        db.close if db
		
        break event.respond 'There is no ammo of that type.' if rows.empty?
		rows[0].select{ |k,v| sort = k if k.start_with? sort } if !sort.nil?
		rows = rows.sort_by { |k, v| k[sort] }.reverse if !sort.nil?
		response = "```\n"
		response += "Round                 | Flesh Damage | Penetration | Armor Damage | Fragmentation Chance | Sold By\n"
		rows.each do |row|
		  response += row['name'].ljust(22) + '| ' + row['flesh_damage'].to_s.center(12) + ' | ' + row['penetration'].to_s.center(11) + ' | ' \
		           + row['armor_damage'].to_s.center(12) + ' | ' + row['fragmentation_chance'].to_s.center(20) + ' | ' \
				   + row['sold_by']
		  response += "\n"
		end
		response += '```'
		event.respond response
      end
	  
	  command(
        :map, min_args: 1,
        description: 'Display information about ammo',
        usage: 'map customs'
      ) do |event, map|
        break unless check_tos(event, event.user.id) == true

        # Load database
        db = SQLite3::Database.new 'plugins/commands/tarkov/tarkov.db'
		db.results_as_hash = true
        rows = db.execute('SELECT map_link FROM maps WHERE map_name = ?', map)
        db.close if db
		
        break event.respond 'That map doesn\'t exist' if rows.empty?
		event.respond map + ': ' + rows[0][0]
      end
    end
  end
end
