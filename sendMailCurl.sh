#!/bin/bash
################ VARs #################
#######################################
SMTP_SRV="smtp.office365.com";
SMTP_PORT="587";
SMTP_USR="$(echo -ne "XXXX@office365.com" | base64 -d)";
SMTP_PASS="$(echo -ne "YYYYYYY" | base64 -d)"
MAIL_FROM="$(echo -ne "XXXX@office365.com" | base64 -d)";
MAIL_TO_1="123@gmail.com";
SUBJECT_SUCCESS="SUCCESS: SRM-SRV";
SUBJECT_FAILED="FAILED: SRM-SRV";
SUCCESS_NAME_FILE_EMAIL="body_mail_success.txt";
FAILED_NAME_FILE_EMAIL="body_mail_failed.txt";
DIR_TEMPLATE_BODY_EMAILS="templates_emails";
CURRENT_TIME_LOCAL="$(date +%H)";
#######################################
#######################################
cd $WORKDIR;
if [ $? == 0 ];
then
    if [ ! -e $DIR_TEMPLATE_BODY_EMAILS ];
    then
	mkdir $DIR_TEMPLATE_BODY_EMAILS;
    fi
else
    echo "Falha ao acessar o diretório raiz do projeto - WORKDIR.";
    exit 0;
fi
#######################################
#######################################
if [ "$CURRENT_TIME_LOCAL" -ge 0 ] && [ "$CURRENT_TIME_LOCAL" -lt 12 ];
then

    INITIAL_MESSAGE_BODY_MAIL="bom dia";

elif [ "$CURRENT_TIME_LOCAL" -ge 12 ] && [ "$CURRENT_TIME_LOCAL" -lt 18 ];
then

    INITIAL_MESSAGE_BODY_MAIL="boa tarde";

elif [ "$CURRENT_TIME_LOCAL" -ge 18 ] && [ "$CURRENT_TIME_LOCAL" -le 23 ];
then

    INITIAL_MESSAGE_BODY_MAIL="boa noite";

fi
#######################################
#######################################

BODY_MAIL_SUCCESS="
From: "$MAIL_FROM"
To: "$MAIL_TO_1"
Subject: "$SUBJECT_SUCCESS"-<GITLABRUNNER_NAME>
Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Espaço em disco liberado com sucesso no runner <GITLABRUNNER_NAME>. Segue Evidências.

Antes:
Filesystem                       			Size Used Avail Use% Mounted
/dev/mapper/ubuntu--vg-ubuntu--lv      <DISK_SIZE_OLD><DISK_USED_OLD><DISK_AVAIL_OLD> <DISK_PCENT_OLD>  	/
Depois:
Filesystem                                              Size Used Avail Use% Mounted
/dev/mapper/ubuntu--vg-ubuntu--lv      <DISK_SIZE_NEW><DISK_USED_NEW><DISK_AVAIL_NEW> <DISK_PCENT_NEW>          /
";

BODY_MAIL_FAILED="
From: "$MAIL_FROM"
To: "$MAIL_TO_1"
Subject: "$SUBJECT_FAILED"-<GITLABRUNNER_NAME>
Olá, "$INITIAL_MESSAGE_BODY_MAIL",
Falha ao tentar liberar espaço em disco no runner <GITLABRUNNER_NAME>.
Por favor, verificar.
";

#######################################
#######################################

function create_body_mail_success() {
	cd ~;
	CURRENT_LOCAL=$(pwd);
	echo "$BODY_MAIL_SUCCESS" | sed 1d > "$CURRENT_LOCAL"/"$SUCCESS_NAME_FILE_EMAIL";  

}

#create_body_mail_success;

function create_body_mail_failed() {
        cd ~;
        CURRENT_LOCAL=$(pwd);
        echo "$BODY_MAIL_FAILED" | sed 1d > "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL";

}

#create_body_mail_failed;

function send_email_success() {

  sed -i s/"<WORKER_NAME>"/"$WORKER_NAME"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_SIZE_OLD>"/"$DISK_SIZE_OLD"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_USED_OLD>"/"$DISK_USED_OLD"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_AVAIL_OLD>"/"$DISK_AVAIL_OLD"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_PCENT_OLD>"/"$DISK_PCENT_OLD"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_SIZE_NEW>"/"$DISK_SIZE_NEW"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_USED_NEW>"/"$DISK_USED_NEW"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_AVAIL_NEW>"/"$DISK_AVAIL_NEW"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_PCENT_NEW>"/"$DISK_PCENT_NEW"/g "$WORKDIR_FULL_PATH"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --upload-file "$CURRENT_LOCAL"/"$SUCCESS_NAME_FILE_EMAIL";

  if [ -e "$CURRENT_LOCAL"/"$SUCCESS_NAME_FILE_EMAIL" ]; 
  then
     rm -rf "$CURRENT_LOCAL"/"$SUCCESS_NAME_FILE_EMAIL";
  fi

}

#send_email_success;

function send_email_failed() {

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --upload-file "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL";

  if [ -e "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL" ];
  then
     rm -rf "$CURRENT_LOCAL"/"$FAILED_NAME_FILE_EMAIL";
  fi


}

#send_email_failed;

