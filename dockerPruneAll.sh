#!/bin/bash
#### ARRAYs ####
#GITLAB_RUNNER[0]="10.50.4.66";
#GITLAB_RUNNER[1]="10.50.4.104";
#GITLAB_RUNNER[2]="10.50.4.73";
#GITLAB_RUNNER[3]="10.50.4.171";
#GITLAB_RUNNER[4]="10.50.4.79";

GITLAB_RUNNER[0]="10.1.203.21";
GITLAB_RUNNER[1]="10.1.203.198";
GITLAB_RUNNER[2]="10.1.203.4";
GITLAB_RUNNER[3]="10.1.203.210";

##############
#### VARs ####
USER="vinicius";
HOME_USER="$(cd ~ && pwd)";
WORKDIR="$(echo "$HOME_USER"/cleandiskgitrunners)";
SENDMAIL_SCRIPT="sendMailCurl.sh";
PATH_SENDMAIL_SCRIPT="$(echo "$WORKDIR"/"$SENDMAIL_SCRIPT")";
DISK_USAGE_THRESHOLD_ALERT=85;
CONDITION_VALUE="$(echo "${#GITLAB_RUNNER[@]}"-1 | bc)";
##############

#### IMPORTS | INCLUDES ####
source "$PATH_SENDMAIL_SCRIPT";
############################

for ((i=0; i<=$CONDITION_VALUE; i++));
do

  DISK_USAGE_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=pcent | tail -n1 | sed 's/ //g' | sed 's/%//');
  DISK_SIZE_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=size | tail -n1);
  DISK_USED_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=used | tail -n1);
  DISK_AVAIL_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=avail | tail -n1);
  DISK_PCENT_BEFORE=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=pcent | tail -n1);

  if [ "$DISK_USAGE_BEFORE" -ge "$DISK_USAGE_THRESHOLD_ALERT" 2> /dev/null ];
  then
       HOSTNAME_RUNNER="$(host "${GITLAB_RUNNER[$i]}" | cut -d " " -f5 | sed 's/\.//' | sed 's/ //g')";	  
       ssh "$USER"@"${GITLAB_RUNNER[$i]}" sudo docker system prune -af;
       if [ $? == 0 ];
       then
       	   ssh "$USER"@"${GITLAB_RUNNER[$i]}" sudo docker volume prune -f;
	   if [ $? == 0 ];
	   then
	       DISK_SIZE_AFTER=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=size | tail -n1);
	       DISK_USED_AFTER=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=used | tail -n1);
               DISK_AVAIL_AFTER=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=avail | tail -n1);
               DISK_PCENT_AFTER=$(ssh "$USER"@"${GITLAB_RUNNER[$i]}" df -h / --output=pcent | tail -n1);
	       
	       function sendMailSuccess(){
	           create_body_mail_success;
		   send_email_success;
	       }
       		sendMailSuccess;
	   else
	       function sendMailFail2(){
		   create_body_mail_failed_code_2;
		   send_email_failed_code_2;
               }
                sendMailFail2;
           fi
       else
	   function sendMailFail1(){
	       create_body_mail_failed_code_2;
               send_email_failed_code_2;
           }
            sendMailFail1;
       fi
  fi
done
exit 0
