#! /bin/bash
# Description: a server manager that will create servers, set them up, and log their information
# Creator: Kayla Humphrey
# Date: 4/23/2024

# gather parameters from command line
strExternalIP=$1
strTicketID=$2

#create a directory for the logs, or just go into it if it exists and create log file
mkdir -p configurationLogs && cd configurationLogs
touch ${strTicketID}.log

# debugstatements
# echo ${strExternalIP} ${strTicketID}

# Now, we have to use the webservice to get ticket info

