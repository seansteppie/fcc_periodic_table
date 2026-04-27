#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ $# -ne 1 ]]; then
  echo "Please provide an element as an argument."
  exit
fi
SELECT_STUB="SELECT atomic_number, type_id, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties"
# The element with atomic number 1 is Hydrogen (H). It's a nonmetal, with a mass of 1.008 amu. Hydrogen has a melting point of -259.1 celsius and a boiling point of -252.9 celsius.
if [[ $1 =~ ^[0-9]+$ ]]; then
  SELECT="$SELECT_STUB WHERE atomic_number = $1"
elif [[ $1 =~ ^..?$ ]]; then
  SELECT="$SELECT_STUB WHERE atomic_number IN (SELECT atomic_number FROM elements WHERE symbol = '$1')"
elif [[ $1 =~ ^[A-Z][a-z]+$ ]]; then
  SELECT="$SELECT_STUB WHERE atomic_number IN (SELECT atomic_number FROM elements WHERE name = '$1')"
fi
IFS='|' read ATOMIC_NUMBER TYPE_ID ATOMIC_MASS MELTING_POINT BOILING_POINT <<< $($PSQL "$SELECT")
if [[ -z $ATOMIC_NUMBER ]]; then
  echo "I could not find that element in the database."
  exit
fi
read TYPE <<< $($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")
IFS='|' read ELEMENT_SYMBOL ELEMENT_NAME <<< "$($PSQL "SELECT symbol, name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")"
echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
