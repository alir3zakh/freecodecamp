# !/bin/sh

PSQL="psql -qt -U freecodecamp -d periodic_table -c"

if [ $# -eq 0 ] 
then
  echo "Please provide an element as an argument."
elif [ $# -eq 1 ] 
then
  atomic_num=$($PSQL "select atomic_number from elements 
  where '$1' in (atomic_number::text, symbol, name) ") 

  if [ -z $atomic_num ]
  then
    echo "I could not find that element in the database."
  else
    properties=$($PSQL "select atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type, symbol, name
      from properties NATURAL JOIN elements NATURAL JOIN types 
      where atomic_number=$atomic_num")

    IFS=" | "
    read -r atomic_num mass melt_point boil_point type symbol name <<< $properties

    echo "The element with atomic number $atomic_num is $name ($symbol). It's a $type, with a mass of $mass amu. $name has a melting point of $melt_point celsius and a boiling point of $boil_point celsius.";
  fi
else
  echo "Invalid number of arguments. enter only 1 argument containing elements name/symbol/atomic number."s
fi


