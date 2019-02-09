#!/bin/bash
#
# Hddtemp Monitor
#
# Data: 	15/06/2018 17:17:54
# Autore: 	Lorenzo Saibal Forti <saibal@lorenzone.it>
#
# Copyleft:	2010 - Tutti i diritti riservati
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#=====================================================================

#=====================================================================
# CONFIGURAZIONE
#=====================================================================

# a space separated list of HD to monitor. (e.g. /dev/sda /dev/sdb etc etc)
# hard disk da monitorare (separati da spazio)
HDDS='/dev/sda'

# your username. needed if you use cron to call the script. can be empty if you don't use cron job.
# il tuo nome utente (serve per abilitare le notifiche se usate da cron. lascia vuoto se non vuoi usarle)
USERNAME_XAUTHORITY='saibal'

# temperatura max limit (in celsius)
# limite temperatura (in gradi centigradi)
TEMPERATURE_LIMIT='48'

# shutdown the server when max limit reached (y or n)
# spegnere il server automaticamente (y oppure n)
SERVER_SDOWN='y'

# number of loop before shutdown the server (how many times cron job call the script)
# dopo quanti avvisi spegnere il server
SERVER_SDOWN_LOOP='3'

# directory where to store log files. check r/w permissions for the user
# directory dove salvare i LOG (senza slash finale). controllare i permessi di scrittura sulla cartella
LOGS_DIR='/home/saibal/log'

# log filename
# nome del file di LOG
LOGS_FILENAME='s_hddtemp-monitor.log'

# max size of the log file (in KB)
# dimensione massima del file di log (in KB)
LOGS_MAXSIZE='900'

# notification type: 0 = no notification, 1 = video (need libnotify-bin installed), 2 = email, 3 = both video and email
# tipo di notifica. (0 = nessuna notifica, 1 = video con libnotify-bin installato, 2 = email, 3 = sia video che email)
NOTIFY_TYPE='3'

# email service for notification type 2 or 3. usually I use "ssmtp". try with "smtp" or another service but I don't guarantee
# se impostato il tipo di notifica 2 o 3 selezionare il programma da utilizzare (valori possibili: 'sendmail' o 'ssmtp')
EMAIL_SERVICE='ssmtp'

# email recipient
# destinatario email
EMAIL_RECIVER='myemail@email.com'

########################################
# NOTHING TO EDIT
# NIENTE DA MODIFICARE
########################################

# per usare zenity e/o libnotify da cron è necessario esportare la variabile DISPLAY e XAUTHORITY (dalla versione 14.04)
export XAUTHORITY="/home/$USERNAME_XAUTHORITY/.Xauthority"
export DISPLAY=:0

# path principali del sistema
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin

# programma per il rilevamento della temperatura
HDDTEMP='hddtemp'

# comando hddtemp
HDT="/usr/sbin/$HDDTEMP"

# comando per shutdown pc
DOWN='/sbin/shutdown'

TODAY_DATE=$(date +%d/%m/%Y)
TODAY_TIME=$(date +%H:%M)

MSG_SDOWN_PLUS=''
COUNT_NOTIFY_ERROR=0
COUNT_TODAY_ALERT=0
Z_MSG_TIMEOUT=10
Z_MSG_TITLE="Hard Disk Alarm"

# funzione per inviare email | eliminato il campo From: per problemi con google come proxy. anche il campo To va tolto
# $1 $EMAIL_SERVICE | $2 $EMAIL_RECIVER | $3 SOGGETTO | $4 $EMAIL_MSG
send_mail() {

	# alternativa
	echo -e "From: sh-script\nSubject: $3\n\n$4" | $1 "$2"
}

#=========================================
# FUNZIONI LOG
#=========================================
# creo la dir se non esiste
if [ ! -d  "$LOGS_DIR" ]
then

	mkdir "$LOGS_DIR"
fi

# creo il file di log
if [ ! -f  "$LOGS_DIR/$LOGS_FILENAME" ]
then

	echo -ne > "$LOGS_DIR/$LOGS_FILENAME"
fi

# converto i KB in BYTES dopo aver controllato che la VAR non sia vuota
if [ -n "$LOGS_MAXSIZE" ]
then

	LOGS_MAXBYTES=$(( $LOGS_MAXSIZE*1000 ))

else

	LOGS_MAXBYTES=$(( 1000*1000 ))
fi

# dimensione del file per vedere quando troncarlo
LOG_SIZE=$( stat -c %s "$LOGS_DIR/$LOGS_FILENAME")

# se la misura attuale è più grande di quella massima tronco il file e ricomincio
if [ "$LOG_SIZE" -gt $LOGS_MAXBYTES ]
then

	# con il parametro -n non metto una riga vuota nel file
	echo -ne > "$LOGS_DIR/$LOGS_FILENAME"
fi

#=========================================
# START CODE!!!
#=========================================

# controllo che i programmi richiesti siano disponibili
case "$NOTIFY_TYPE" in

	0)
        COUNT_NOTIFY_ERROR=0
	;;

    1)
        command -v notify-send > /dev/null;

		if [ $? -gt 0 ]
		then

			(( COUNT_NOTIFY_ERROR++ ))

			MESSG_NOTIFY_ERROR="\"notify-send\": il programma per le notifiche non risulta installato sul sistema"
			echo "$TODAY_DATE | $TODAY_TIME | $MESSG_NOTIFY_ERROR" >> "$LOGS_DIR/$LOGS_FILENAME"

		fi
	;;

    2)
		command -v $EMAIL_SERVICE > /dev/null;

        if [ $? -gt 0 ]
		then

			(( COUNT_NOTIFY_ERROR++ ))

			MESSG_NOTIFY_ERROR="\"$EMAIL_SERVICE\": il programma per l'invio delle email non risulta installato sul sistema"
			echo "$TODAY_DATE | $TODAY_TIME | $MESSG_NOTIFY_ERROR" >> "$LOGS_DIR/$LOGS_FILENAME"

		fi
	;;

	3)
		command -v $EMAIL_SERVICE > /dev/null;

        if [ $? -gt 0 ]
		then

			(( COUNT_NOTIFY_ERROR++ ))

			MESSG_NOTIFY_ERROR="\"$EMAIL_SERVICE\": il programma per l'invio delle email non risulta installato sul sistema"
			echo "$TODAY_DATE | $TODAY_TIME | $MESSG_NOTIFY_ERROR" >> "$LOGS_DIR/$LOGS_FILENAME"

		fi

		command -v notify-send > /dev/null;

		if [ $? -gt 0 ]
		then

			(( COUNT_NOTIFY_ERROR++ ))

			MESSG_NOTIFY_ERROR="\"notify-send\": il programma per le notifiche non risulta installato sul sistema"
			echo "$TODAY_DATE | $TODAY_TIME | $MESSG_NOTIFY_ERROR" >> "$LOGS_DIR/$LOGS_FILENAME"

		fi
	;;

    *)
        COUNT_NOTIFY_ERROR=1

        MESSG_NOTIFY_ERROR="Errore impostazioni per il tipo di notifica. Possibili valori: 0, 1, 2 o 3"
        echo "$TODAY_DATE $TODAY_TIME | $MESSG_NOTIFY_ERROR" >> "$LOGS_DIR/$LOGS_FILENAME"

	;;
esac

# se tutti i controlli sono ok vado avanti
if [ $COUNT_NOTIFY_ERROR -eq 0 ]
then

	if command -v $HDDTEMP > /dev/null
	then

		for DISK in $HDDS
		do

			if [ -b $DISK ]
			then

				# eseguo il comando hddtemp per rilevare la temperatura
				#HDTEMP=$($HDT $DISK | awk '{ print $3}' | awk -F '°' '{ print $1}')
				HDTEMP=$($HDT $DISK | cut -d':' -f3 | tr -d '[A-Za-z°]' | tr -d '[:space:]')

				# se la temperatura dell'hd è un numero intero ed è uguale o superiore al limite
				if [[ $HDTEMP =~ ^[-+]?[0-9]+$ ]] && [ $HDTEMP -ge $TEMPERATURE_LIMIT ]
				then

					# aumento il contatore per scrivere un solo incremento per ogni ciclo
					(( COUNT_TODAY_ALERT++ ))

					# messaggio aggiuntivo in caso di auto shutdown
					if [ "$SERVER_SDOWN" = 'y' ]
					then

						MSG_SDOWN_PLUS="Il sistema verrà spento dopo $SERVER_SDOWN_LOOP avvisi"
					fi

					EMAIL_SUB="Avviso temperatura $DISK su $HOSTNAME"
					EMAIL_MSG="Attenzione! Alle $TODAY_TIME è stata rilevata una temperatura di $HDTEMP° sul $DISK. $MSG_SDOWN_PLUS"
					Z_MSG="ATTENZIONE!\n\nLa temperatura di $DISK è di $HDTEMP°\n$MSG_SDOWN_PLUS"

					case "$NOTIFY_TYPE" in

						1)
							#echo "message:$Z_MSG" | zenity --notification --listen --window-icon="error"
							#zenity --warning --title="$Z_MSG_TITLE" --timeout=$Z_MSG_TIMEOUT --width=$Z_MSG_WIDTH--height=$Z_MSG_HEIGHT --text="$Z_MSG" --no-wrap
							notify-send --icon=error -t $(( $Z_MSG_TIMEOUT*1000 )) "$Z_MSG_TITLE" "\n$Z_MSG"


						;;

						2)
							send_mail "$EMAIL_SERVICE" "$EMAIL_RECIVER" "$EMAIL_SUB" "$EMAIL_MSG"
						;;

						3)
							#echo "message:$Z_MSG" | zenity --notification --listen --window-icon="error"
							#zenity --warning --title="$Z_MSG_TITLE" --timeout=$Z_MSG_TIMEOUT --width=$Z_MSG_WIDTH--height=$Z_MSG_HEIGHT --text="$Z_MSG" --no-wrap
							notify-send --icon=error -t $(( $Z_MSG_TIMEOUT*1000 )) "$Z_MSG_TITLE" "\n$Z_MSG"

							send_mail "$EMAIL_SERVICE" "$EMAIL_RECIVER" "$EMAIL_SUB" "$EMAIL_MSG"
						;;

					esac

					echo "$TODAY_DATE | $TODAY_TIME | $DISK: la temperatura rilevata è di $HDTEMP°" >> "$LOGS_DIR/$LOGS_FILENAME"
					echo "Attenzione! La temperatura di $DISK è di $HDTEMP°"

				fi
			fi

		done

		#=========================================
		# CONTATORE E SHUTDOWN
		#=========================================

		if [ $COUNT_TODAY_ALERT -gt 0 ]
		then

			# se esiste già il contatore di oggi lo incremento altrimenti lo scrivo per la prima volta
			if grep -qa "$TODAY_DATE | count |" "$LOGS_DIR/$LOGS_FILENAME"
			then

				# sostituzione di lettere per lasciare solo numeri: tr -d '[a-z]'
				NALERT=$( grep "$TODAY_DATE | count |" "$LOGS_DIR/$LOGS_FILENAME" | tail -1 | cut -d'|' -f3 )

				(( NALERT++ ))

			else

				NALERT=1
			fi

			echo "$TODAY_DATE | count | $NALERT" >> "$LOGS_DIR/$LOGS_FILENAME"

			# spegnere il server automaticamente
			if [ "$SERVER_SDOWN" = 'y' ] && [ $NALERT -ge $SERVER_SDOWN_LOOP ]
			then

				echo "$TODAY_DATE | $TODAY_TIME | shutdown del sistema" >> "$LOGS_DIR/$LOGS_FILENAME"
				# azzero il contatore
				echo "$TODAY_DATE | count | 0" >> "$LOGS_DIR/$LOGS_FILENAME"

				sleep 5

				$DOWN -h 0
			fi

		fi

	else

		echo "\"$HDDTEMP\": programma non installato sul sistema. prova con \"sudo apt-get install $HDDTEMP\""
		echo "$TODAY_DATE | $TODAY_TIME | \"$HDDTEMP\": programma non installato sul sistema" >> "$LOGS_DIR/$LOGS_FILENAME"

	fi

else

	echo "$MESSG_NOTIFY_ERROR"

fi

exit 0
