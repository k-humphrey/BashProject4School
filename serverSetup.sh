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
arrResults=$(curl https://www.swollenhippo.com/ServiceNow/systems/devTickets.php | jq)
intLength=$(echo ${arrResults} | jq 'length')
intCurrent=0
intStopper=$((intLength - 1))
# echo "$arrResults"
# echo $intLength

while [ ${intCurrent} -lt ${intLength} ];
do
  # parse curl for each index (ticket) and compare the ticketID to the one requested
  if [ $(echo ${arrResults} | jq .[${intCurrent}].ticketID) == ${strTicketID} ]; then
    echo found it
  elif [ ${intCurrent} -eq ${intStopper} ]; then
    echo "Error: ticket ID ${strTicketID} not found. exiting."
    exit 1
  fi
  
  ((intCurrent++))
done
