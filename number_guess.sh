#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

USERS=$($PSQL "SELECT * FROM users;")
echo "$USERS"