#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

GET_SERVICES_ID() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  LIST_SERVICES=$($PSQL "SELECT * FROM services")
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    ID=$(echo $SERVICE_ID | sed 's/ //g')
    NAME=$(echo $SERVICE | sed 's/ //g')
    echo "$ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5]) NEXT ;;
        *) GET_SERVICES_ID "I could not find that service. What would you like today?" ;;
  esac
}

NEXT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  # CUSTOMER_PHONE_FORMATED=$(echo $CUSTOMER_PHONE | sed 's/[^0-9]*//g')
  NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $NAME | sed 's/ //g')
  if [[ -z $NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    NAME=$(echo $NAME | sed 's/ //g')
    SAVED_TO_TABLE_CUSTOMERS=$($PSQL "INSERT INTO customers(name,phone) VALUES('$NAME','$CUSTOMER_PHONE')")
  fi
  
  GET_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME=$(echo $GET_SERVICE_NAME| sed 's/ //g')
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME
  SAVED_TO_TABLE_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  if [[ $SAVED_TO_TABLE_APPOINTMENTS == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi

}

GET_SERVICES_ID