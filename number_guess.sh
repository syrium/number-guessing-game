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
    GAMEID=$($PSQL "SELECT game_id FROM games WHERE user_id=$USERID AND secret_number=$SECRET_NUMBER;")
    echo "Guess the secret number between 1 and 1000:"
    read USERGUESS

    # add number_of_guesses
    NUMBER_OF_GUESSES=1

    # if input is a valid integer   
    # check if it match with the secret_number
    while [[ $USERGUESS -ne $SECRET_NUMBER ]];
    do  
      ((NUMBER_OF_GUESSES++))      
      if [[ $USERGUESS =~ ^[0-9]+$ ]]
      then
        # if not match
        # if lower than the secret_number
        if (( $USERGUESS < $SECRET_NUMBER ))
        then
          echo "It's higher than that, guess again:"
          read USERGUESS
        elif (( $USERGUESS > $SECRET_NUMBER && $USERGUESS < 1001))
        then
        # if higher than the secret_number
          echo "It's lower than that, guess again:"
          read USERGUESS
        else
          echo "It's out of bound, guess again:"
          read USERGUESS
        fi
      else
        # if input is not an integer
        echo "That is not an integer, guess again:"
        read USERGUESS
      fi
    done

    # if match
    # update number_of_guesses
    UPDATE_NUMBER_OF_GUESSES=$($PSQL "UPDATE games SET number_of_guesses=$NUMBER_OF_GUESSES WHERE game_id=$GAMEID;")    
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    # END GAME
  fi
}

# get username
echo "Enter your username:"
read USERNAME

# check if it is an old user
USERID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

  if [[ -z $USERID ]]
  # if new user
  then
  #  # add new user to db
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
    GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id=$USERID;")
    BEST_GAME=$($PSQL "SELECT number_of_guesses FROM games WHERE user_id = $USERID ORDER BY number_of_guesses ASC LIMIT 1;")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    GAME_START $USERID
  fi

