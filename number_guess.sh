#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number

# get username
echo "Enter you username:"
read USERNAME

echo $USERNAME

# check if it is an old user
  # if old user
  # get username, games_played, best_game
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  
  # if new user
  # add new user to db
  echo "Welcome, $USERNAME! It looks like this is your first time here."

# game start
  # echo random number and get user input
  echo "Guess the secret number between 1 and 1000:"
  read USERGUESS

  # add number_of_guesses

  # if input is a valid integer
    # check if it match with the secret_number
   
      # if match
        echo "You guessed it in $NUMBER_OF_GUSSES tries. The secret number was $SECRET_NUMBER. Nice job!"
        # END GAME
        
      # if not match
        # if lower than the secret_number
        echo "It's higher than that, guess again:"
        read USERGUESS

        # if higher than the secret_number
        echo "It's lower than that, guess again:"
        read USERGUESS

  # if input is not an integer
    echo "That is not an integer, guess again:"
    read USERGUESS