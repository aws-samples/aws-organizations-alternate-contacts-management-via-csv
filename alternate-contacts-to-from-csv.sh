#
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this
# software and associated documentation files (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use, copy, modify,
# merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

#!/bin/bash

output_file=""
source_file=""
max_retry=4
exit_code=0
loaded=0
skipped=0

usage() 
{ 
  echo "$0: missing operand"
  echo "Usage is: $0 [-i|-o] <alternate-contacts-file.csv>" 
  echo "-i to import the alternate contact from the given csv file"
  echo "-o to export the actual alternate contacts into a csv file"
  exit 1;
}

while getopts "i:o:" options; do
case "${options}" in
i)
	source_file=${OPTARG}
	;;     
o)
	output_file=${OPTARG}
	;;     
*)
	usage
	;;
esac
done
shift $((OPTIND-1))

if [ -z "$source_file" -a -z "$output_file" ]; then 
	usage
fi

#if [ ! -z "${source_file}" -a ! -f "${source_file}" ]; then
#	echo "File \"$source_file\" does not exist...exit" 
#	exit 1
#fi

management_account=`aws organizations describe-organization --query Organization.MasterAccountId --output text` 2>&1 1>$0.log
if [ $? -ne "0" ]; then
	echo "Error in fetching master account id"
	exit 1
fi
#echo "Management account is \"$management_account\""
	
 
if [ ! -z "$output_file" ]; then
	output_file="$PWD/$output_file"
	echo "Listing all accounts in \"$output_file\""
	[ -f "$output_file" ] && echo "File \"$output_file\" exists, please rename/backup/remove it before proceeding" && exit 2
	touch $output_file
	for account_id in $(aws organizations list-accounts --query 'Accounts[].Id' --output text); 
	do 
		echo -n "Account $account_id: "
		for type in OPERATIONS SECURITY BILLING;
		do
			counter=0
			exit_code=0
			echo -n "$type..."
			echo -n "$account_id," >>$output_file
			while [ $counter -lt $max_retry ]
			do
			  contact=$(aws account get-alternate-contact --account-id ${account_id} --alternate-contact-type $type --output text 2>/dev/null)
			  exit_code=$?
			  if [ $exit_code -eq "0" ]; then
				echo "$contact" | tr "\t" "," >>$output_file 
				break;
  			  elif [ $exit_code -eq 254 ]; then
				echo "ALTERNATECONTACT,$type,,,," >> $output_file
				break;
			  fi
  	 		  echo "Error with exit code=$exit_code while executing ($counter/$max_retry):" >>$0.log
			  echo -e "\taws account get-alternate-contact --account-id ${account_id} --alternate-contact-type $type --output text" >>$0.log
			  ((counter++))
			  sleep .2
			done
			if [ $counter -eq $max_retry ]; then
				echo "Error with exit code=$exit_code while executing:" >>$0.log
				echo -e "\taws account get-alternate-contact --account-id ${account_id} --alternate-contact-type $type --output text" >>$0.log
				exit 1
			fi
		done
		echo "done"
	done
else
	source_file=$PWD/$source_file
	[ ! -f "$source_file" ] && echo "File \"$source_file\" does not exist, please populate it before proceeding using it" && usage
	comma_check=$(grep -o "," $source_file|wc -m)
	comma_check=$(expr $comma_check % 6 ) # no more than six comma per row
	[ $comma_check -ne "0" ] && echo "There are too commas in \"$source_file\" which should be multiple of six: check and fix it." && exit 1
	# echo "Loading accounts and alternate contacts from \"$source_file\""
	IFS=','
        while read -r account_id other type account_email account_name account_phone account_title; do
		number='^[0-9]+$'
		echo -n "Working on account \"$account_id\": "
		if ! [[ $account_id =~ $number ]] ; then
			echo  "Skipping invalid account id."
			continue
		fi
		if [ "$management_account" -eq "$account_id" ]; then
			echo "This is the management account and will be skipped."
			continue
		fi
		if [ -z "$account_email" -o -z "$account_name" -o -z "$account_phone" -o -z "$account_title" ]; then
			echo "Skipped - some data is missed, check $0.log" # All contacts details have to be provided
			echo "Missed data for account \"$account_id\" for \"$type\" is missed and it will be skipped: account_email=\"$account_email\" account_name=\"$account_name\" account_phone=\"$account_phone\" account_title=\"${account_title}\"">>$0.log
			((skipped++))
			continue
		fi
		counter=0
		exit_code=0
		while [ $counter -lt $max_retry ]
		do
			# Name, phone, email, and title must be provided for BILLING, OPERATIONS, SECURITY
			account_id=$(printf "%012d" $account_id)
			aws account put-alternate-contact --account-id ${account_id} --alternate-contact-type ${type} --email-address ${account_email} --name ${account_name} --phone-number ${account_phone} --title ${account_title}
			exit_code=$?
      			if [ $exit_code -ne "0" ]; then
				echo "Error with exit code=$exit_code while executing ($counter/$max_retry):" >>$0.log
				echo -e "\taws account put-alternate-contact --account-id ${account_id} --alternate-contact-type ${type} --email-address ${account_email} --name ${account_name} --phone-number ${account_phone} --title ${account_title}">>$0.log
				((counter++))
	      			sleep .2
			else
				echo "$type done"
				((loaded++))
				break
			fi
		done
		if [ $counter -eq $max_retry ]; then
			echo "Error with exit code=$exit_code while executing:" >>$0.log
			echo -e "\taws account get-alternate-contact --account-id ${account_id} --alternate-contact-type $type --output text" >>$0.log
			exit 1
		fi
	done < $source_file
	echo "Contacts loaded:$loaded, skipped:$skipped ."
fi
