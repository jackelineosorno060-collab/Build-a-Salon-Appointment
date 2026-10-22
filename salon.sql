#! /bin/bash

echo "~~~~~ MY SALON ~~~~~"
echo
echo "Welcome to My Salon, how can I help you?"
echo

SERVICE_LIST=$(psql --username=freecodecamp --dbname=salon -Atc "SELECT service_id || ') ' || name FROM services ORDER BY service_id")

while true; do
  printf '%s\n' "$SERVICE_LIST"
  read SERVICE_ID_SELECTED

  if [[ "$SERVICE_ID_SELECTED" =~ ^[0-9]+$ ]]; then
    SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -Atc "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  else
    SERVICE_NAME=
  fi

  if [[ -n "$SERVICE_NAME" ]]; then
    break
  fi

  echo
  echo "I could not find that service. What would you like today?"
done

echo
echo "What's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -Atc "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z "$CUSTOMER_ID" ]]; then
  echo
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" > /dev/null
  CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -Atc "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
else
  CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -Atc "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
fi

echo
echo "What time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" > /dev/null

echo
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
