#!/bin/bash
################ VARs #################
#######################################
SMTP_SRV="smtp.office365.com";
SMTP_PORT="587";
SMTP_USR="$(echo -ne "xxxxxxxxxxxxx==" | base64 -d)";
SMTP_PASS="$(echo -ne "yyyyyyyyyyyyy==" | base64 -d)"
MAIL_FROM="$(echo -ne "zzzzzzzzzzzzzzzz==" | base64 -d)";
MAIL_TO_1="vinicius.redes2020@gmail.com";
SUBJECT_SUCCESS="SUCCESS: SRM-SRV";
SUBJECT_FAILED="FAILED: SRM-SRV";
SUCCESS_NAME_FILE_EMAIL="body_mail_success.txt";
FAILED_NAME_FILE_EMAIL_CODE_1="body_mail_failed1.txt";
FAILED_NAME_FILE_EMAIL_CODE_2="body_mail_failed2.txt";
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
/dev/mapper/ubuntu--vg-ubuntu--lv      <DISK_SIZE_BEFORE><DISK_USED_BEFORE><DISK_AVAIL_BEFORE> <DISK_PCENT_BEFORE>    /

Depois:
Filesystem                                              Size Used Avail Use% Mounted
/dev/mapper/ubuntu--vg-ubuntu--lv      <DISK_SIZE_AFTER><DISK_USED_AFTER><DISK_AVAIL_AFTER> <DISK_PCENT_AFTER>    /
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
	echo "$BODY_MAIL_SUCCESS" | sed 1d > "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";  
}

#create_body_mail_success;

function create_body_mail_failed_code_1() {
        echo "$BODY_MAIL_FAILED" | sed 1d > "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1";
}

#create_body_mail_failed_code_1;

function create_body_mail_failed_code_2() {
        echo "$BODY_MAIL_FAILED" | sed 1d > "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2";
}

#create_body_mail_failed_code_2;

function send_email_success() {

  sed -i s/"<GITLABRUNNER_NAME>"/"$HOSTNAME_RUNNER"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_SIZE_BEFORE>"/"$DISK_SIZE_BEFORE"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_USED_BEFORE>"/"$DISK_USED_BEFORE"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_AVAIL_BEFORE>"/"$DISK_AVAIL_BEFORE"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_PCENT_BEFORE>"/"$DISK_PCENT_BEFORE"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_SIZE_AFTER>"/"$DISK_SIZE_AFTER"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_USED_AFTER>"/"$DISK_USED_AFTER"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_AVAIL_AFTER>"/"$DISK_AVAIL_AFTER"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  sed -i s/"<DISK_PCENT_AFTER>"/"$DISK_PCENT_AFTER"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --upload-file "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";

  if [ -e "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL" ]; 
  then
     rm -rf "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$SUCCESS_NAME_FILE_EMAIL";
  fi

}

#send_email_success;

function send_email_failed_code_1() {
 
  sed -i s/"<GITLABRUNNER_NAME>"/"$HOSTNAME_RUNNER"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1";
	
  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --upload-file "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1";

  if [ -e "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1" ];
  then
     rm -rf "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_1";
  fi

}

#send_email_failed_code_1;

function send_email_failed_code_2() {

  sed -i s/"<GITLABRUNNER_NAME>"/"$HOSTNAME_RUNNER"/g "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2";

  curl --ssl-reqd \
    --url "$SMTP_SRV":"$SMTP_PORT" \
    --user "$SMTP_USR":"$SMTP_PASS" \
    --mail-from "$MAIL_FROM" \
    --mail-rcpt "$MAIL_TO_1" \
    --upload-file "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2";

  if [ -e "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2" ];
  then
     rm -rf "$WORKDIR"/"$DIR_TEMPLATE_BODY_EMAILS"/"$FAILED_NAME_FILE_EMAIL_CODE_2";
  fi

}

#send_email_failed_code_2;

