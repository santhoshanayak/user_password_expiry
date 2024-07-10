#!/bin/bash
#Author: Santhosha Nayak
#Scope: To get users password expiring in next seven days
#Additinol steps : Add cron as "0 7 * * mon" which will run on monday morning 7 AM


#get username
username=$(cat /etc/passwd | awk -F ':' '{ if ($3 > 1000) print $1 }')

#temp file
MESSAGE="/tmp/user-expiry.txt"

#email address
TO="admin@example.com"

#email subject
SUBJECT="Password expiring for below mentiond users with in 7 days"

for usern in $username
do
    #present time in epoc 
    today=$(date +%s)

    #get password expiry date
    userexpdate=$(chage -l $usern | grep 'Password expires' |cut -d: -f2)

    #for some user expiry date set as never, to avoid such cases
    if [ "$userexpdate" != " never" ]
    then
        #convert user expiry date to epoc value
        passexp=$(date -d "$userexpdate" "+%s")

        #get the remainder of password expiry date minus epoc value of 7 days  
        exp=$(expr \( $passexp - $today \))
            if [ "$exp" -le "604800" ]
            then
                #convert value to day
                num=$(expr $exp / 60 / 60 / 24)
                    if [ "$num" -gt "1" ]
                    then
                        newnum="$num days"
                    else
                        newnum="$num day"
                    fi
                
                echo "-------------------------------------------------" >> $MESSAGE
                echo "Password expiring for username $usern, in $newnum the password expires" >> $MESSAGE
                echo "-------------------------------------------------" >> $MESSAGE
            fi
    fi
done


#send consolidated email
if [ -f "$MESSAGE" ]  
then  
    #mail -r "$TO" -s "$SUBJECT" "$TO" < $MESSAGE
    cat $MESSAGE
fi
