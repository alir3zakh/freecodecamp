#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\n ~~ Inserting team data into worldcup DB ~~ \n"
$PSQL "truncate table teams cascade"


while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS;
do
  if [[ $YEAR != year ]]
  then
    WINNER_ID=$($PSQL "insert into teams(name) values('$WINNER') on conflict do nothing;
    select team_id from teams where name='$WINNER'")

    OPPONENT_ID=$($PSQL "insert into teams(name) values('$OPPONENT') on conflict do nothing; 
    select team_id from teams where name='$OPPONENT'")

    $PSQL "insert into games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) values($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)"
  fi
done < games.csv
