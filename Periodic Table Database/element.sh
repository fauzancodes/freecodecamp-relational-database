#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [ "$#" -eq 0 ]; then
    echo "Please provide an element as an argument."
    exit
fi

ARG="$1"

if [[ "$ARG" =~ ^[0-9]+$ ]]; then
    QUERY="SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
           FROM elements e
           JOIN properties p ON e.atomic_number = p.atomic_number
           JOIN types t ON p.type_id = t.type_id
           WHERE e.atomic_number = '$ARG';"
else
    QUERY="SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
           FROM elements e
           JOIN properties p ON e.atomic_number = p.atomic_number
           JOIN types t ON p.type_id = t.type_id
           WHERE e.symbol = '$ARG' OR e.name = '$ARG';"
fi

RESULT=$(eval "$PSQL \"$QUERY\"")

if [ -z "$RESULT" ]; then
    echo "I could not find that element in the database."
else
    IFS='|' read -r atomic_number symbol name atomic_mass melting_point boiling_point type <<< "$RESULT"
    
    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi

#by fauzancodes, 2024