#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo Enter your username:
read USERNAME

# get user
USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")

# if user doesn't exist
if [[ -z $USER_ID ]]
then
  # error message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  # insert new player
  INSERT_PLAYER_RESULT=$($PSQL "INSERT INTO players(username)")
else
  echo nice!
  # get name
  USERNAME=$($PSQL "SELECT username FROM players WHERE user_id=$USER_ID")
  # get games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE user_id=$USER_ID")
  # get best game
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE user_id=$USER_ID")

  # proceed
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME gueses."

fi
# get random number
RANDOM_NUMBER=$((1 + $RANDOM % 1000))
# guess the number
echo Guess the secret number between 1 and 1000:
read USER_GUESS

# integer verification
while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
do
  echo That is not an integer, guess again:
  read USER_GUESS
done

USER_ATTEMPTS=1

while [[ ! $USER_GUESS = $RANDOM_NUMBER ]]
do
  if [[ $USER_GUESS < $RANDOM_NUMBER ]]
  then
    echo "you guessed $USER_GUESS"
    echo -e "\nIt's higher than that, guess again:"
  else
    echo "you guessed $USER_GUESS"
    echo -e "\nIt's lower than that, guess again:"
  fi

  read USER_GUESS
  # int verify
  while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
do
  echo That is not an integer, guess again:
  read USER_GUESS
done
  # increment attempt
  ((USER_ATTEMPTS++))

done

# update best game
if [[ $GAMES_PLAYED = 0 ]]
then
  UPDATE_BEST_GAME=$($PSQL "INSERT INTO players(best_game) VALUES($USER_ATTEMPTS)")

if [[ $USER_ATTEMPTS < $BEST_GAME ]]

# get games_played

# update games_played

echo "You guessed it in $USER_ATTEMPTS tries. The secret number was $RANDOM_NUMBER. Nice job!"
