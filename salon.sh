#!/bin/bash 


PSQL="psql --username=freecodecamp --dbname=salon -t -c"


echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"
SERVICE_MENU() {
 
  if [[ $1 ]]
  then
  echo -e "\n$1"
  fi
  
SERVICES=$($PSQL "SELECT service_id,name FROM services")
echo "$SERVICES" | while read SERVICE_NUMBER BAR SERVICE_NAME
do
echo -e "$SERVICE_NUMBER) $SERVICE_NAME"
done

read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
SERVICE_MENU "I could not find that service. What would you like today?"
else
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
 
  if [[ -z $SERVICE_NAME ]]
    then
    SERVICE_MENU "I could not find that service. What would you like today?"
  else
  
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id from customers where phone='$CUSTOMER_PHONE'")
  
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')?" 
  
  read SERVICE_TIME
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
  
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')."
  fi
fi

}

SERVICE_MENU

