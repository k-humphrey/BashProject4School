#! /bin/bash
# Description: Copies and runs automation script on a gcp remote server
# Author: Ben Burchfield (edited by Kayla Humphrey)
# Date: 25 April 2024

# gather command line parameters, IP, TicketID, and username
strIP=$1
strTicketID=$2
strUsername=$3

echo ${strIP}
echo ${strTicketID}
echo ${strUsername}
