# BPI Trade Console

This program aims to solve the problem of logging in to your BPI Trade account and check your portfolio. Let's face it, BPI Trade is not that appealing to look at and its slow compare to a terminal. Why not just run a script that will fetch your portfolio for you for quick checking.

## Usage

First you will need to create a config.rb file. 

	# Config file for password
	# Include in .gitignore
	module Config
		def get_username
			"YOUR USERNAME"
		end

		def get_password
			"YOUR PASSWORD"
		end
	end

Save the `config.rb` file then run on console.

`$ ruby bpi.rb` 

## Future Features

Would like to add quotes, buying and selling through the console.