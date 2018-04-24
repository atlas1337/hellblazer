#!/bin/bash

if [ $1 == "restart" ]; then
	echo "#########Restarting############"
	echo "###############################"
	ruby bot.rb
elif [ $1 == "update" ]; then
  git pull
	ruby bot.rb
else
	echo "Nothing happened."
fi
