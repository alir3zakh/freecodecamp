#!/bin/bash

PSQL="psql -t -U freecodecamp -d number_guess -c"

RANDOM=$$
rand_num=$(($RANDOM % 1001))
num_guess=0

read_number() {
  while read guess 
  do
    if [[ $guess =~ ^-?[0-9]+$ ]]
    then
      return
    else
      echo "That is not an integer, guess again:"
    fi
  done
}



echo "Enter your username:"
read username

userdata=$($PSQL "select username, best_game, games_played from users where username='$username'")


if [[ -z $userdata ]]
then
  echo "Welcome, $username! It looks like this is your first time here."
  echo "Guess the secret number between 1 and 1000:"
  read_number

  while [ true ]
  do
    (( num_guess++ ))
    if [ $rand_num -gt $guess ]
    then
      echo "It's higher than that, guess again:"
      read_number
    elif [ $rand_num -lt $guess ]
    then
      echo "It's lower than that, guess again:"
      read_number 
    else
      break
    fi
  done

  echo "You guessed it in $num_guess tries. The secret number was $rand_num. Nice job!"
  
  tmp=$($PSQL "insert into users(username, best_game, games_played) values('$username', $num_guess, 1)")

else
  IFS=" | "
  read -r username best_game games_played <<< $userdata
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."

  echo "Guess the secret number between 1 and 1000:"
  read_number

  while [ true ]
  do
    (( num_guess++ ))
    if [ $rand_num -gt $guess ]
    then
      echo "It's higher than that, guess again:"
      read_number
    elif [ $rand_num -lt $guess ]
    then
      echo "It's lower than that, guess again:"
      read_number 
    else
      break
    fi
  done

  echo "You guessed it in $num_guess tries. The secret number was $rand_num. Nice job!"

  (( games_played++ ))
  best_game=$(( num_guess < best_game ? num_guess : best_game ))

  tmp=$($PSQL "delete from users where username='$username'")
  tmp=$($PSQL "insert into users(username, best_game, games_played) values('$username', $num_guess, $games_played)")
fi
