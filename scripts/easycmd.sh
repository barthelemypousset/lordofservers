#! /bin/bash

# To add:
# * Retreive info about multiple hosts (like: ip a, date)
# * Format beautifull results
# * Add hosts to a database
# * OK: use a file of hosts
# * fill the help menu
# * Later, Huge editons: Management interface
# * send scripts in addition to commands
# * send command to multiple host at the same time (&)
# *

### Catch arguments

if [ $# -eq 0 ]
then echo "Missing arguments. See easycmd.sh -h for syntax."
else
  while getopts u:s:p:f:c:vVh option
  do
   case "${option}"
   in
   u) SSHUSER=${OPTARG};;
   s) SSHSERVER=${OPTARG};;
   p) SSHPORT=${OPTARG};;
   f) SERVERLIST=${OPTARG};;
   c) USERCMD=${OPTARG};;
   v) MODEVERBOSE="true";;
   V) UNSECURELYVERBOSE="true";;
   h) HELPMENU="true";;
   esac
  done
fi

### FUNCTIONS

function helpmenu {
echo "Usage: easycmd.sh -u \"user\" {-s \"server\" | -f \"file\"} [-p \"port\"] -c \"command\"" [-v -V -h]
exit
}

function checkargs {
if [ -z $SSHUSER ] || [ -z "$USERCMD" ] || ([ -z $SSHSERVER ] && [ -z $SERVERLIST ])
then
  echo "You're supposed to use at least the options -u; -c and -s OR -f Use easycmd.sh -h for help."
  exit
elif [ $SSHSERVER ] && [ $SERVERLIST ]
then
  echo "you're not supposed to use -s and -f arguments at the same time !"
  exit
elif [ $SERVERLIST ]
then READFILE="true"
  echo "using file $SERVERLIST"
fi
}

function encPass {
echo "enter your domain password"
read -s USERPASSWORD
USERPASSWORDENCODED=$(echo -n $USERPASSWORD | openssl enc -base64)
USERPASSWORD=""
}

function verbose {
echo ""
echo "#############"
echo "user: $SSHUSER"
echo "server: $SSHSERVER"
echo "file: $SERVERLIST"
echo "cmd: $USERCMD"
echo "cyPass: $1"
echo "decPass: $(echo $1 | openssl enc -base64 -d)"
echo "#############"
echo ""
}

function readfile {
if [ -f $SERVERLIST ]
then
  for SSHSERVER in $(cat $SERVERLIST)
  do
          echo ""
          echo "server in use: $SSHSERVER"
	  echo "---"
          sendcommand
  done
fi
exit
}

function sendcommand {
sshpass -p $(echo $USERPASSWORDENCODED | openssl enc -base64 -d) ssh -o "StrictHostKeyChecking=no" $SSHUSER@$SSHSERVER "$USERCMD"
if [ $? -eq 0 ]
then echo ""
else echo "SSH connexion failed. Check User, Password and Port."
fi
}

### MAIN

if [ $HELPMENU ]
then helpmenu
fi

checkargs

if [ $MODEVERBOSE ]
  then verbose
elif [ $UNSECURELYVERBOSE ]
  then verbose $USERPASSWORDENCODED
fi

encPass

if [ $READFILE ]
then readfile
else
sendcommand
fi
