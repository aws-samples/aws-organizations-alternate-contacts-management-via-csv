# AWS Organizations Alternate Contacts management via CSV

Nowadays, customers have several linked accounts in their [AWS Organizations](https://aws.amazon.com/organizations/). These linked accounts might require different alternate contacts for many reasons and keeping such contacts updated is fundamental. Unfortunately, populating such contacts might be a complex and time-consuming activity. Customers would like to fill in their AWS linked accounts alternate contacts in a simple and quick way, closer to their daily way of working, like exporting to a CSV file, modifying it keeping the original formatting, and importing the updated contacts from the management account.

This work has been inspired by the blog post [Programmatically managing alternate contacts on member accounts with AWS Organizations](https://aws.amazon.com/blogs/mt/programmatically-managing-alternate-contacts-on-member-accounts-with-aws-organizations/)

## Requirements

- The AWS Organizations must have all features enabled, please see [Enabling all features in your organization](https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_org_support-all-features.html).
- You need to enable trusted access with AWS Organizations for AWS Account Management, please see [Enabling trusted access for AWS Account Management](https://docs.aws.amazon.com/accounts/latest/reference/using-orgs-trusted-access.html).
- Only the AWS Organizations management account can export and import the linked accounts alternate contacts.

## Overview

The script leverages on AWS CLI 2.0 and AWS CloudShell to enable the AWS Organizations management account to easily export all the linked accounts alternate contacts to a regular CSV file. Then, the file can be integrated or updated, and uploaded again. *Please keep in mind that the CSV format has to be kept to make it works properly*, thus avoid additional comma and pay attention to special characters.

## Things to know 

1. Each account/contact type in the CSV file has to provide all the corresponding alternate contacts details, in case any of them will be missed that entry will be skipped. 
2. We recommend to limit the CSV file to only those rows that need to be updated. 
3. When you export it, feel free to create a copy for backup

## Usage

- From the AWS Organizations management account run AWS CloudShell
- Upload the script alternate-contacts-to-from-csv.sh into AWS CloudShell
- Run the script to export the alternate contacts, as follow

```bash
$ alternate-contacts-to-from-csv.sh -o aws-alternate-contacts.csv
```

- From AWS CloudShell you can download the resulting CSV file, keeping a copy as a backup. Review and integrate the CSV file: each account entry has to report all the corresponding alternate contacts details, otherwise it will not be imported. We recommend to limit the CSV file to only those rows that need to be updated
- (Optional) Review the differences between the original export the CSV to import, being sure of the changes made
- Finally, upload the CSV file into AWS CloudShell and run the import command, as follow

```bash
$ alternate-contacts-to-from-csv.sh -i aws-alternate-contacts.csv
```

Simple but powerful.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.


## License

This solution is licensed under the MIT-0 License. See the LICENSE file.
