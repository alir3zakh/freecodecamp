#!/bin/bash

NUMBER_RE='^[0-9]+$'
PSQL="psql -U freecodecamp -d salon -t -q -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?"
  fi

  NUM_SERVICES=0
  SERVICES=$($PSQL "select * from services")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    ((NUM_SERVICES++))
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ $NUMBER_RE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE;

    CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      CUSTOMER_ID=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME') returning customer_id")

      echo $CUSTOMER_ID
    else 
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE' ")
    fi

    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME

    TMP=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" )

    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

MAIN_MENU
