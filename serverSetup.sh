#! /bin/bash
# Description: a server manager that will create servers, set them up, and log their information
# Creator: Kayla Humphrey
# Date: 4/23/2024

# gather parameters from command line
strExternalIP=$1
strTicketID=$2

# jq is needed for this script to run
sudo apt-get install jq

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

    echo "" >> ${strTicketID}.log
    # loop through software packages, installing them and updating logs
    while [ ${intCurrentSP} -lt ${intLengthSP} ];
    do
       sudo apt-get install $(echo ${arrPResults} | jq -r .[${intCurrentSP}].install)
       strPackageName=$(echo ${arrPResults} | jq -r .[${intCurrentSP}].name)
       echo "SoftwarePackage - ${strPackageName} - "$(date +"%d-%b-%Y %H:%M:%S") >> ${strTicketID}.log
      ((intCurrentSP++))
    done

   # set up for a loop within additional config
    arrAResults=$(echo ${arrResults} | jq .[${intCurrent}].additionalConfigs)
    intLengthAC=$(echo ${arrAResults} | jq 'length')
    intCurrentAC=0
    # echo ${intLengthAC}

    # loop through additional configs, calling them and updating logs
    while [ ${intCurrentAC} -lt ${intLengthAC} ];
    do
       strConfig=$(echo ${arrAResults} | jq -r .[${intCurrentAC}].config)
       #Error, for a certain touch configuration, if directory doesn't exist we must make one
       if [[ $strConfig == touch* ]]; then
	  #the command contains touch so we need to create a directory
	  xpath=${strConfig%/*}
          xpath=${xpath:6}
         sudo mkdir -p ${xpath}

         #now that directory is created, the original config command should work
       fi
       sudo ${strConfig}
       strConfigName=$(echo ${arrAResults} | jq -r .[${intCurrentAC}].name)
       echo "additionalConfig - ${strConfigName} - "$(date +"%d-%b-%Y %H:%M:%S") >> ${strTicketID}.log
      ((intCurrentAC++))
    done

    echo "" >> ${strTicketID}.log
    # now we need to do version checks
    intCurrentSP=0
    intCurrentAC=0

    # loop through software packages, checking version and updating logs DOESNT WORK
    while [ ${intCurrentSP} -lt ${intLengthSP} ];
    do
       strInstall=$(echo ${arrPResults} | jq -r .[${intCurrentSP}].install)
       #echo "$strInstall"
       strVersion=$(apt show ${strInstall} | grep Version)
       #echo "$strVersion"
       strPackageName=$(echo ${arrPResults} | jq -r .[${intCurrentSP}].name)
       echo "Version Check - ${strPackageName} - ${strVersion} " >> ${strTicketID}.log
      ((intCurrentSP++))
    done

    # curl other webservice to close ticket
    echo "" >> ${strTicketID}.log
    echo $(curl https://www.swollenhippo.com/ServiceNow/systems/devTickets/completed.php?TicketID=${strTicketID} | jq -r .outcome) >> ${strTicketID}.log

    #print date finished :)
    echo "" >> ${strTicketID}.log
    echo "Completed: "$(date +"%d-%b-%Y %H:%M:%S") >> ${strTicketID}.log
  fi
  ((intCurrent++))
done

#if stopper was never turned on (1)
if [ ${intStopper} -lt 1 ]; then
    echo "Error: ticket ID ${strTicketID} not found."
    exit 1
fi
