Hellblazer
=======
Hellblazer is a chatbot for use with the Discord chat service.

Dependencies
------------
* Ruby 2.7+
* [Bundler](https://github.com/bundler/bundler) Ruby Gem Bundler.

Other dependencies are listed in the Gemfile.

Installation - Linux
------------
1. Install dependencies using the command:
       `sudo apt-get install git`

2. Run the command:
      `git clone https://github.com/atlas1337/hellblazer.git yourfoldername`

3. Go into the directory you just cloned into with:
     `cd /path/to/yourfoldername`

4. [Bundler](https://github.com/bundler/bundler)
   Install bundler by running the following command:
	   `gem install bundler`

5. Now run the command:
     `bundle install`
   to install all of the dependencies.

Configuration
------------
1. Make a copy of apikeys.json.sample and name it apikeys.json

2. Open apikeys.json and fill in the desired API keys.

3. Go through each plugin folder in plugins, and copy the sample config files to config.json and make any desired changes.

4. To add reaction images, you can create a folder for the reaction in images/reactions and then you can put the reactions for that image in the folder. You can also use `r.add reaction :: image url` to add an image if you are hosting the bot yourself.

Running - Linux
------------
1. I recommend running using screen, so that you can have it run in the background while
   doing other things in the terminal.

2. Install screen with:
     `sudo apt-get install screen`

3. Navigate to the folder where you cloned the project, and run:
     `screen -S Hellblazer`
   You can replace Hellblazer with whatever name is easy for you to remember.

4. You will be in a screen. Run the command:
     `ruby bot.rb` or `./bot.rb`

5. Hold control and press a and then d to disconnect from the screen.

6. To rejoin the screen run:
     `screen -r Hellblazer`
   Hellblazer would be the name of your screen if you changed it to something else in Step 3.

7. Hold control and press c in the screen to stop the bot, or run the !shutdown command in your Discord server.
