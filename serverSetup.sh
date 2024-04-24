#! /bin/bash
# Description: a server manager that will create servers, set them up, and log their information
# Creator: Kayla Humphrey
# Date: 4/23/2024

# gather parameters from command line
strExternalIP=$1
strTicketID=$2

#create a directory for the logs, or just go into it if it exists
mkdir -p configurationLogs && cd configurationLogs

# debugstatements
# echo ${strExternalIP} ${strTicketID}

# Now, we have to use the webservice to get ticket info
arrResults=$(curl https://www.swollenhippo.com/ServiceNow/systems/devTickets.php | jq)
intLength=$(echo ${arrResults} | jq 'length')
intCurrent=0
intStopper=0
# echo "$arrResults"
# echo $intLength
# echo $intStopper

while [ ${intCurrent} -lt ${intLength} ];
do
  # parse curl for each index (ticket) and compare the ticketID to the one requested
  strCurrentTicket=$(echo ${arrResults} | jq .[${intCurrent}].ticketID)
  if [ ${strCurrentTicket} == ${strTicketID} ]; then
    ((intStopper++)) #just means key was found

    # adding top information to file
    touch ${strTicketID}.log
    echo "TicketID: ${strTicketID}" >> ${strTicketID}.log
    echo "Start DateTime: "$(date +"%d-%b-%Y %H:%M") >> ${strTicketID}.log
    echo "Requestor: "$(echo ${arrResults} | jq -r .[${intCurrent}].requestor) >> ${strTicketID}.log
    echo "External IP Address: ${strExternalIP}" >> ${strTicketID}.log
    echo "Hostname: "$(hostname -s) >> ${strTicketID}.log
    echo "Standard Configuration: "$(echo ${arrResults} | jq -r .[${intCurrent}].standardConfig) >> ${strTicketID}.log

    # Time for server configuration
    # set up for a loop within software Packages
    arrPResults=$(echo ${arrResults} | jq .[${intCurrent}].softwarePackages)
    intLengthSP=$(echo ${arrPResults} | jq 'length')
    intCurrentSP=0
    # echo ${intLengthSP}
    # loop through software packages, installing them and updating logs
    while [ ${intCurrentSP} -lt ${intLengthSP} ];
    do
       sudo apt-get install $(echo ${arrPResults} | jq -r .[${intCurrentSP}].install)
       echo "" >> ${strTicketID}.log
       strPackageName=$(echo ${arrPResults} | jq -r .[${intCurrentSP}].name)
       echo "Software Package - ${strPackageName} - "$(date +"%d-%b-%Y %H:%M:%S") >> ${strTicketID}.log

      ((intCurrentSP++))
    done
  fi
  ((intCurrent++))
done

#if stopper was never turned on (1)
if [ ${intStopper} -lt 1 ]; then
    echo "Error: ticket ID ${strTicketID} not found."
    exit 1
fi
