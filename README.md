# AWS Organizations Alternate Contacts management via CSV

Nowadays, customers have several linked accounts in their [AWS Organizations](https://aws.amazon.com/organizations/). These linked accounts might require different alternate contacts for many reasons and keeping such contacts updated is fundamental. Unfortunately, populating such contacts might be a complex and time-consuming activity. Customers would like to fill in their AWS linked accounts alternate contacts in a simple and quick way, closer to their daily way of working, like exporting to a CSV file, modifying it keeping the original formatting, and importing the updated contacts from the management account.
This is what the script does.

This work has been inspired by the blog post [Programmatically managing alternate contacts on member accounts with AWS Organizations](https://aws.amazon.com/blogs/mt/programmatically-managing-alternate-contacts-on-member-accounts-with-aws-organizations/)

## Requirements

- The AWS Organizations must have all features enabled, please see [Enabling all features in your organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org_support-all-features.html).
- You need to enable trusted access with AWS Organizations for AWS Account Management, please see [Enabling trusted access for AWS Account Management](https://docs.aws.amazon.com/accounts/latest/reference/using-orgs-trusted-access.html).
- Only the AWS Organizations management account can export and import the linked accounts alternate contacts.

## Overview

The script leverages on AWS CLI 2.0 and AWS CloudShell to enable the AWS Organizations management account to easily export all the linked accounts alternate contacts to a regular CSV file. Then, the file can be integrated or updated, and uploaded again. 
**The CSV format has to be kept to make it works properly**: account ids has to be formatted as a plain number without demical or 1000 separator, same for phone number, avoid additional comma like in the name or tile, and pay attention to special characters.

## Things to know

1. Each account/contact type in the CSV file has to provide all the corresponding alternate contact details: Name, email, Title, Phone Number. In case any of them is missed, the corresponding entry will be skipped.
2. When modifying the file with spredsheet tools, the accounts id and phone number might be formatted as exponentional formula, e.g., 123456789 as 1.23+E8, while a plain number is needed. Thus, format the entire column as "Number" without decimal and 1000 separator.
3. We recommend to limit the CSV file to only those rows that need to be updated. 
4. When you export the alternate contacts, feel free to create a copy for backup. Such a copy can be used to either roll-back or to compare against the file that will be imported, double checking the changes.
5. Management account alternat contacts will not be imported/changed.

## Usage

- From the AWS Organizations management account run AWS CloudShell

- Upload the script alternate-contacts-to-from-csv.sh into AWS CloudShell

![image](https://user-images.githubusercontent.com/4224797/203337896-14b70fc1-0c51-4165-8c89-e6ad889639df.png)

- Run the script to export the alternate contacts on a CSV file, as follow
```bash
$ alternate-contacts-to-from-csv.sh -o aws-alternate-contacts.csv
```
![image](https://user-images.githubusercontent.com/4224797/203345967-10096e9a-b28f-4038-9522-c2f8613bb52c.png)


- From AWS CloudShell you can download the resulting CSV file: **keep a copy as a backup**. 
![image](https://user-images.githubusercontent.com/4224797/203339756-8c08e3b6-8fe3-4cb5-949d-719799e90d3d.png)

- Review and integrate the CSV file: each account entry has to report all the corresponding alternate contacts details, otherwise it will not be imported. 
- We recommend to limit the CSV file to only those rows that need to be updated

- (Optional) Review the differences between the original CSV and the one to import, being sure about the changes made

- Finally, upload the CSV file into AWS CloudShell and run the import command, as follow
```bash
$ alternate-contacts-to-from-csv.sh -i aws-alternate-contacts.csv
```
![image](https://user-images.githubusercontent.com/4224797/203340677-170d7a6c-dd0e-49c8-8d88-b7bb3ca127b9.png)

- Check the alternate contacts in the AWS Organizations.

Simple but powerful.

## Experiencing errors

First, check the CSV formatting, as explained in the "Things to know" section. Format both account id and phone number as "Number" without decimal and 1000 separator and try again.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This solution is licensed under the MIT-0 License. See the LICENSE file.
