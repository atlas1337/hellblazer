
module Hellblazer
  module Plugins
    # Dice roller plugin
    module Diceroller
      require 'rounding'

      extend Discordrb::Commands::CommandContainer

      command(
        :roll, max_args: 1,
        description: 'Rolls a die or dice',
        usage: 'roll <text>'
      ) do |event, dice|
        break unless check_tos(event, event.user.id) == true
        if !dice.nil?
          # Remove the d from between the number of dice and the number of sides of the dice.
          info = dice.split('d')

          numberofdice = info[0].to_i
          numberofsides = info[1].to_i
          break unless numberofdice.to_s == info[0] &&
                       numberofsides.to_s == info[1]

          # Assign a random number to roll based on the number of dice and the number of sides of the dice.
          # Max roll = number of dice * number of sides on the dice.
          roll = rand(numberofdice..(numberofdice * numberofsides))

          # Output the user, and what they rolled.
          event.respond "#{event.user.username} rolled a #{roll}"

        # Do this in all other situations. EX: The roll command is used with no arguments.
        else

          # Output the user, and what they rolled on a six sided die.
          event.respond "#{event.user.username} rolled a #{rand(1..6)}"

        # End the if statement to see what dice need to be rolled.
        end
      # End roll command
      end

      command(
        %s(roll.mod), min_args: 3, max_args: 3,
        description: 'Rolls dice with a modifier',
        usage: 'roll <dice> <symbol> <modifier>'
      ) do |event, dice, symbol, mod|
        break unless check_tos(event, event.user.id) == true
        break unless ["+", "-", "*", "/"].include? symbol

        # Remove the d from between the number of dice and the number of sides of the dice.
        info = dice.split('d')

        numberofdice = info[0].to_i
        numberofsides = info[1].to_i
        modifier = mod.to_i
        break unless (numberofdice.to_s == info[0]) && (numberofsides.to_s == info[1]) && (modifier.to_s == mod)

        # Assign a random number to roll based on the number of dice and the number of sides of the dice.
        # Max roll = number of dice * number of sides on the dice.
        roll = rand(info[0].to_i..(info[0].to_i * info[1].to_i))

        event.respond "#{event.user.username} rolled a (:game_die:#{roll} "\
                      "#{symbol} #{modifier}) for a total of :game_die:"\
                      "#{(roll.to_f.send symbol, modifier).round_to(1)}"
      end

      command(
        %s(roll.fudge), max_args: 0,
        description: 'Rolls fudge dice',
        usage: 'fudge'
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        # Output a roll of fudge dice from the array in the config.
        event.respond 'You rolled the following fudge dice: ('\
                      "#{Hellblazer.conf['diceroller_fudge'].sample}, "\
                      "#{Hellblazer.conf['diceroller_fudge'].sample}, "\
                      "#{Hellblazer.conf['diceroller_fudge'].sample}, "\
                      "#{Hellblazer.conf['diceroller_fudge'].sample})"
      end

      command(
        :coin, max_args: 0,
        description: 'Flip a coin'
      ) do |event|
        break unless check_tos(event, event.user.id) == true
        # Output an option from the coin array in the config.
        event.respond Hellblazer.conf['diceroller_coin'].sample
      # End coin flip command
      end
    # End diceroll module
    end
  end
end
