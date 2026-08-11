#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generate random number
SECRET_NUMBER=$((RANDOM % 1000 + 1))

# get username
echo "Enter you username:"
read USERNAME

# check if it is an old user
USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
if [[ -z $USERID ]]
# if new user
then
  # add new user to db
  ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  if [[ $ADD_USER == "INSERT 0 1" ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  fi
else
  # if an old user
  # get games_played, best_game
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USERID;")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id= $USERID;")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
  
# game start
# assign user
ADD_SECRET_NUMBER=$($PSQL "INSERT INTO games(user_id, secret_number) VALUES($USERID, $SECRET_NUMBER);") 
if [[ $ADD_SECRET_NUMBER == "INSERT 0 1" ]]
then
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
fi
  