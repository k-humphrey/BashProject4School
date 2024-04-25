#! /bin/bash
# Description: Copies and runs automation script on a gcp remote server
# Author: Ben Burchfield (edited by Kayla Humphrey)
# Date: 25 April 2024

# gather command line parameters, IP, TicketID, and username
strIP=$1
strTicketID=$2
strUsername=$3

#echo ${strIP}
#echo ${strTicketID}
#echo ${strUsername}

#Given ssh stored in this directory and named this way
ssh-add .ssh/gcpserver

#Using scp, copy serverSetup.sh from current directory to home directory on remote server
scp -i .ssh/gcpserver serverSetup.sh "${strUsername}"@"${strIP}":/home/"${strUsername}"

#give serverSetup.sh execution rights and run it on the remote server
ssh ${strUsername}@${strIP} "chmod 755 serverSetup.sh"
ssh ${strUsername}@${strIP} "./serverSetup.sh ${strIP} ${strUsername}"
