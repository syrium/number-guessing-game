#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# game start
GAME_START () {
  if [[ $1 ]]
  then
    USERID=$1
  fi
  # generate random number
  SECRET_NUMBER=$((RANDOM % 1000 + 1))

  # assign user
  ADD_SECRET_NUMBER=$($PSQL "INSERT INTO games(user_id, secret_number) VALUES($USERID, $SECRET_NUMBER);") 
  
  if [[ $ADD_SECRET_NUMBER == "INSERT 0 1" ]]
  then
    # get game_id
    GAMEID=$($PSQL "SELECT game_id FROM games WHERE secret_number=$SECRET_NUMBER;")
    GUESS_CHECK "Guess the secret number between 1 and 1000:" $GAMEID 

  fi
}

ADD_USER () {
  if  [[ $1 ]]
  then
    USERNAME=$1
  fi
  # check if it is an old user
  USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
  if [[ -z $USERID ]]
  # if new user
  then
    # add new user to db
    ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
    if [[ $ADD_USER == "INSERT 0 1" ]]
    then
      NEW_USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      GAME_START $NEW_USERID
    fi
  else
    # if an old user
    # get games_played, best_game
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = $USERID;")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id= $USERID;")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    GAME_START $USERID
  fi
}

GUESS_CHECK () {

  if [[ $1,$2 ]]
  then
    echo $1
    GAMEID=$2
  fi

  read USERGUESS
  
  # add number_of_guesses
  NUMBER_OF_GUESSES=$($PSQL "SELECT number_of_guesses FROM games WHERE game_id=$GAMEID;")
  ADD_NUMBER_GUESSED=$($PSQL "UPDATE games SET number_of_guesses=$NUMBER_OF_GUESSES + 1 WHERE game_id=$GAMEID;")
  
  # if input is a valid integer
  if [[ $USERGUESS =~ ^[0-9]+$ ]]
  then
#    # if the number is greater than 1000
#    if [[ $USERGUESS < 1001 ]]
#    then  
      # check if it match with the secret_number
      SECRET_NUMBER=$($PSQL "SELECT secret_number FROM games WHERE game_id=$GAMEID;")
      if [[ $SECRET_NUMBER == $USERGUESS ]]
      then
        # if match
          # update number_of_guesses
          BEST_GAMEID=$($PSQL "SELECT game_id FROM games WHERE user_id = $USERID ORDER BY number_of_guesses ASC LIMIT 1;")
          UPDATE_NUMBER_OF_GUESSES=$($PSQL "UPDATE users SET best_game=(SELECT number_of_guesses FROM games WHERE game_id = $GAMEID) WHERE user_id=$USERID;")

          # update games_played
          UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=(SELECT COUNT(user_id) FROM games WHERE user_id=$USERID) WHERE user_id=$USERID;")
          # get number_of_guesses
          NUMBER_OF_GUESSES=$($PSQL "SELECT number_of_guesses FROM games WHERE game_id=$GAMEID;")
          echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
          # END GAME
      else   
        # if not match
        # if lower than the secret_number
        if [[ $USERGUESS < $SECRET_NUMBER ]]
        then
          GUESS_CHECK "It's higher than that, guess again:" $GAMEID
        else
        # if higher than the secret_number
          GUESS_CHECK "It's lower than that, guess again:" $GAMEID
        fi
      fi
#    # if input is greater than 1000
#    else
#      GUESS_CHECK "The number is larger than 1000, guess again:" $GAMEID
#    fi
  else
  # if input is not an integer
    GUESS_CHECK "That is not an integer, guess again:" $GAMEID
  fi
}

# get username
echo "Enter your username:"
read USERNAME
ADD_USER $USERNAME