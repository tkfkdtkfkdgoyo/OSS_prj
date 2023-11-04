#!/bin/bash
choice=0
count=0
	#display menu
	echo "--------------------------------------"
	echo "User Name: jomakeum"
	echo "Student Number: 12213598"
	echo "[MENU]"
	echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
	echo "2. Get the data of action genre movies from 'u.item'"
	echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
	echo "4. Delete the 'IMDb URL' from 'u.item'"
	echo "5. Get the data about user from 'u.user'"
	echo "6. Modify the format of 'release data' in 'u.item'"
	echo "7. Get the data of movies rated by specific 'user id' from 'u.data'"
	echo "8. Get the average 'rating' of movies rated by user with 'age' between 20 and 29 'occupation as 'programmer"
	echo "9. Exit"
	echo "--------------------------------------"

until [ $choice -eq 9 ]
do
	#case-choice1) get input from user
	read -p "Enter your choice: [1-9]:" choice

	case $choice in 
	1) 
    read -p "Please enter the 'movie id' (1~1682):" movieId
	awk -v movieId="$movieId" -F '|' '$1 == movieId {print}' u.item
	;;
	
	2) 
	read -p "Do you want to get the data of 'action' genere moives from 'u.item'? (y/n):" reply
	if [ "$reply" = "y" ]; then
	awk -F '|' '$7 == 1 {print $1, $2; count++} count == 10 {exit}' u.item
	else continue
	fi
	;;
	
	3)
	read -p "Please enter the 'movie id' (1~1682):" movieId
	awk -v movieId="$movieId" -F ' ' '$2 == movieId {sum += $3; count++} END {print "average rating of %d %.6f", movieId, sum/count}' u.data
	;;

	4)
	read -p "Do you want to delete the 'IMOb URL' from 'u.item? (y/n):" reply
	if [ "$reply" = "y" ]; then
	cat u.item | sed -E 's/http:[^|]*\)//' | head -n 10
	else continue	
	fi
	;;

	5)
	read -p "Do you want to get the data about users from 'u.user'? (y/n):" reply
	if [ "$reply" = "y" ]; then
	awk -F '|' '{print "user " $1 " is " $2 " years old " $3, $4}' u.user | sed 's/F/Female/g; s/M/Male/g' | head -n 10
	else continue
	fi
	;;

	6)
	read -p "Do you Modify the format of 'release date' in 'u.item' (y/n):" reply
	if [ "$reply" = "y" ]; then
    	while IFS='|' read -r col1 col2 date col4
    	do
        new_date=$(date -d "$date" "+%Y%m%d")
        echo "$col1|$col2|$new_date|$col4"
    	done < u.item | tail -n 10
	else continue
	fi
	;;

	7)
	read -p "Please enter the 'user id' (1~943): " userId
	movieIds=$(awk -v userId="$userId" '$1 == userId {print $2}' u.data | sort -n | tr '\n' '|') # Sort -n (ascending sort)
	echo "$movieIds"
	echo ""

	IFS="|" read -ra idArray <<< "${movieIds}"
	for id in "${idArray[@]}"; do # @ is every argumetnt
	awk -F '|' -v id="$id" '$1 == id {print $1"|"$2}' u.item
	done | head -n 10
	;;

	8)
	read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation as 'programmer'? (y/n):" reply
	if [ "$reply" = "y" ]; then
    	awk -F '|' '$4 == "programmer" && $2 >= 20 && $2 <= 29 {print $1}' u.user > user_ids.txt
	cat user_ids.txt

    	while IFS= read -r userId; do
        awk -F ' ' -v id="$userId" '$1 == id {sum+=$3; count++} END {if (count > 0) print id, sum/count}' u.data
    	done < user_ids.txt

    	rm user_ids.txt
	else continue
	fi
	;;
	
	9)
	echo "bye!"
	;;
	
	esac
done



