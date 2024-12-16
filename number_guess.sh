#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# 1. Get player info
# prompt for username
echo Enter your username:
read USERNAME

# get user_id by username
USER_ID=$($PSQL "SELECT user_id FROM players WHERE username='$USERNAME'")

# if player doesn't exist
if [[ -z $USER_ID ]]
then
  # show new player message
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0

else
  # get name
  USERNAME=$($PSQL "SELECT username FROM players WHERE user_id=$USER_ID")
  # get games played
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE user_id=$USER_ID")
  # get best game
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE user_id=$USER_ID")

  # show existing player message
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi

# 2. Number guessing game
# generate random number
RANDOM_NUMBER=$((1 + $RANDOM % 1000))

# prompt user guess
echo Guess the secret number between 1 and 1000:
read USER_GUESS

# integer verification
while [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
do
  echo That is not an integer, guess again:
  read USER_GUESS
done

# starting attempt
USER_ATTEMPT=1

# keep prompting if guess is not correct
while [[ ! $USER_GUESS = $RANDOM_NUMBER ]]
do
  # if guess is higher/lower than answer, give hint and prompt again
  if [[ $USER_GUESS < $RANDOM_NUMBER ]]
  then
    echo -e "\nIt's higher than that, guess again:"
  else
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
  ((USER_ATTEMPT++))
done

# exit loop when correct, show message
echo "You guessed it in $USER_ATTEMPT tries. The secret number was $RANDOM_NUMBER. Nice job!"

# 3. Update database
# update best_game
# if new player
if [[ $GAMES_PLAYED = 0 ]]
then
  #set current result to best_game
  INSERT_BEST_GAME=$($PSQL "INSERT INTO players(username, best_game) VALUES('$USERNAME', $USER_ATTEMPT)")
else
  # if existing player
  if [[ $USER_ATTEMPT < $BEST_GAME ]]
  then
    #compare and update best_game
    UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game=$USER_ATTEMPT WHERE username='$USERNAME'")
  fi
fi

# update games_played
UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE players SET games_played=$(( $GAMES_PLAYED + 1 )) WHERE username='$USERNAME'")
