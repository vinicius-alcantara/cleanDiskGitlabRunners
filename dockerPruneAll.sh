#!/bin/bash
#### ARRAYs ####
GITLAB_RUNNER[0]="10.50.4.66";
GITLAB_RUNNER[1]="10.50.4.104";
GITLAB_RUNNER[2]="10.50.4.73";
GITLAB_RUNNER[3]="10.50.4.171";
GITLAB_RUNNER[4]="10.50.4.79";
##############
#### VARs ####
USER="agility";
WORKDIR=$(echo "$USER"/"cleandiskgitrunners");
SENDMAIL_SCRIPT="sendMailCurl.sh";
PATH_SENDMAIL_SCRIPT=$(echo "$WORKDIR"/"$SENDMAIL_SCRIPT");
DISK_USAGE_THRESHOLD_ALERT=85;
##############
#### IMPORTS | INCLUDES ####
source "$PATH_SENDMAIL_SCRIPT";
############################

for ((i=0; i<=4; i++));
do

  DISK_USAGE_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=pcent | tail -n1 | sed 's/ //g' | sed 's/%//');
  DISK_SIZE_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=size | tail -n1);
  DISK_USED_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=used | tail -n1);
  DISK_AVAIL_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=avail | tail -n1);
  DISK_PCENT_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=pcent | tail -n1);

  if [ "$DISK_USAGE_BEFORE" -ge "$DISK_USAGE_THRESHOLD_ALERT" 2> /dev/null ];
  then
       ssh "$USER"@"${GITLAB_RUNNER[$i]}" docker system prune -af && docker volume prune -f 1> /dev/null;
       if [ $? == 0 ];
       then
	       function sendMailSuccess(){
	       
	       }   
       else
	       function sendMailFail(){
	       
	       }
       fi
  fi
done
exit 0
