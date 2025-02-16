#!/bin/bash

# Adjust if your DB name or username differ:
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# 1) Check if an argument was provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# 2) Determine if the argument is a number (atomic_number) or text (symbol/name)
if [[ $1 =~ ^[0-9]+$ ]]
then
  # Search database by atomic_number
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name,
                          p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius,
                          t.type
                   FROM elements e
                   INNER JOIN properties p USING(atomic_number)
                   INNER JOIN types t USING(type_id)
                   WHERE e.atomic_number = $1")
else
  # Search database by symbol or name
  ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name,
                          p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius,
                          t.type
                   FROM elements e
                   INNER JOIN properties p USING(atomic_number)
                   INNER JOIN types t USING(type_id)
                   WHERE e.symbol = '$1' OR e.name = '$1'")
fi

# 3) If no match, print error
if [[ -z $ELEMENT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# 4) Parse the row into variables
IFS="|" read ATOMIC_NUMBER SYMBOL NAME MASS MELT BOIL TYPE <<< "$ELEMENT"

# 5) Print the required output
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
