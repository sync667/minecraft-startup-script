#! /bin/bash
#Okre?lenie ilo?ci pami?ci ram dla serwera 
#np. Xmx=1024M i Xms=1024M
Xmx=2000M
Xms=1000M
#################################
#Nazwa procesu screen i wirtualnego terminala
#np. scrname=nazwa procesu i vtermname=nazwa wirtualnego
#terminala
#UWAGA nie u?ywaj spacji w nazwach procesu i terminala
scrname=minecraftsk
vtermname=bukkit
#################################
#Okre?lenie ilo?ci czasu w sekundach do
#restartu (r) i zatrzymania (s) serwera
#np. r=10 s=15 czyli restart nast?pi po 10 sekundach
#a zatrzymanie po 15 sekundach
r=15
s=15
#################################
#Ustalenie w?asnj informacji wy?wietlanej
#na serwerze podczas jego restartowania, 
#wy??czania i tworzenia kopii zapasowej
#np. info_restart='tre??' i info_stop='tre??'
#info_backup='tre??'
info_restart='Restart serwera za'
info_stop='Restart serwera za'
info_backup='Kopia zapasowa map wygenerowana'
#################################
#########################################
#	Konfiguracja kopii zapasowej	#
#########################################
#Wyb車r wersii serwera
#np. serwer=0 wersja normalna, serwer=1 bukkit
serwer=1
#########################################
#Okre?lenie w?asnego katalogu kopii zapasowej
#np. /home/minecraft/backup
#UWAGA u?ytkownik systemowy obs?uguj?cy serwer
#minecraft musi mie? uprawnienia zapisu w tym katalogu
backupdir='/home/backupk'
#########################################
#Ustaw tutaj nazw? katalogu ?wiata jaki
#jest ustawiony w konfiguracji serwera
#np. ns='world'
sn='Stolica2'
#########################################
#Dodatkowe opcje kopii zapasowej dla bukkita
#ustaw tutaj nazwy katalog車w, ?wiat車w jakie
#s? ustawione w konfiguracji serwera
#np. s1='world' s2='world_nether' s3='world_the_end'
s1=''
s2='Projekty'
s3='RPG'
#########################################
#Ustawienia usuwania starych kopii zapasowych
#np.:
#usun='tak' (stara kopia zostanie usuni?ta
#usun='nie' (stara kopia zostanie tylko z archiwizowana)
#UWAGA przy w??czonym wysy?aniu na zdalny serwer
#zaleca sie ustawienie tej opcji na usun='tak'
usun='nie'
#########################################
#Opcje wysy?ania kopii zapasowej na zdalny serwer
#poprzez protoko?y FTP lub SFTP
#np.:
#zdalny='ftp' (czyli kopia zostanie wyslana przez FTP)
#zdalny='wyl' (czyli kopia niezostanie wys?ana i pozostanie tylko
#na dysku serwera) 
zdalny='wyl'
#########################################
#Konfiguracja FTP
#np.:
#adres='adres serwera ftp (domena b?d? IP)'
#port=numer portu serwera ftp (domy?lnie jest to numer 21)
#ftpdir='?cie?ka do katalogu na zdalnym serwerze ftp'
#ftpuser='nazwa u?ytkownika do konta ftp'
#ftppas='has?o u?ytkownika do konta ftp'
adres=''
port=21
ftpdir=''
ftpuser=''
ftppas=''
#################################
#	Koniec konfiguracji	#
#################################
Dir=$(readlink -f $0)&&jarpath=$(dirname $Dir)&&cd $jarpath #Ustalenie ?cie?ki skryptu
function wer
 {
  if [ "$serwer" = "0" ];then
	backup
  elif [ "$serwer" = "1" ];then
	backup-bukkit
  fi
 }
function pd #funkcja sprawdzaj?ca i usuwaj?ca niedza?ajace procesy screen
 {
  procd=$(screen -ls | grep $scrname | awk '{print $4}')
  if [ "${procd#(}" = "Dead" ];then
  	screen -wipe 1> /dev/null
  fi
  rm mc.pid
 }
function restart # funkcja zatrzymuj?ca serwer na potrzeby restartu
 {
  if [ -e mc.pid ];then
  	if ( kill -0 $(cat mc.pid) 2> /dev/null );then
  	while [ $r -ge 1 ];do
  		sleep 1
  		t=$((r--))
  		screen -S $scrname -p $vtermname -X stuff "say $info_restart $t"`echo -ne '\015'`
  		echo $info_restart $t
  	done
	sleep 1
  	echo -e "\\033[1mSerwer Minecraft zostal zatrzymany\\033[0m"
  	kill -KILL $(cat mc.pid)
  	fi
  	pd
  else
  	echo -e "\\033[1;31mSerwer nie dzia?a (brakuje pliku z numerem procesu \"mc.pid\")\\033[0m"
  	exit 5
  fi	
 }
function usuwanie
 {
  if [ "$usun" = "tak" ];then
  	rm -R $backupdir/$name_directory_backup$data_u
  elif [ "$usun" = "nie" ];then
  	zip -r -9 $name_directory_backup$data_u.zip $name_directory_backup$data_u 1> /dev/null
	
  fi
 }
function data
 {
  data_u=`date '+%d-%m-%Y' -d '-1 day'`
  data=`date '+%d-%m-%Y_%H:%M:%S'`
  data_k=`date '+%d-%m-%Y'`
 }
function zftp
 {
  if [ -e /usr/bin/ncftpput ];then
	echo ''
  elif [ -e /usr/local/bin/ncftpput ];then
	echo ''
  else
	echo -e "\\033[1mNa tym serwerze nie zainstalowano klienta FTP\\033[0m \\033[1;31m\"ncftp\" \\033[0m"
	echo -e "\\033[1mAby przeprowadzi? tworzenie kopii zapasowej z opcja wysy?ania na zdalny serwer ftp, musisz zainstalowa? na serwerze program\\033[0m \\033[1;31m\"ncftp\"\\033[0m\\033[1m, lub ustawi? opcje zdalny='wyl' w sekcji konfiguracyjnej tego skryptu.\\033[0m"
	exit 1
  fi
  data
  cd $backupdir
  zip -r -9 $name_directory_backup$data_u.zip $name_directory_backup$data_u 1> /dev/null
  ncftpput -mzvDD -u $ftpuser -p $ftppas -P $port $adres $ftpdir $backupdir/$name_directory_backup$data_u.zip
  echo -e "\\033[1mKopia zapasowa zosta?a przes?ana na serwer ftp $adres:$port\\033[0m"
 }
function backup
 {
  data
  name_directory_backup="kopia_zapasowa_z_dnia_"
  name_file_backup='Kopia_zapasowa_z_'
	mkdir -p $backupdir/$name_directory_backup$data_k/$name_file_backup$data
	mkdir "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pliki_konfiguracyjne"
	mkdir "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/logi"
	mkdir "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/swiaty"
	cp *.txt "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pliki_konfiguracyjne"&&cp *.log "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/logi"&&cp server.properties "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pliki_konfiguracyjne"&&cp -R "$sn" "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/swiaty"
	cd $backupdir/$name_directory_backup$data_k
	zip -r -9 $name_file_backup$data.zip $name_file_backup$data 1> /dev/null&&rm -R $name_file_backup$data
  if [ -e $backupdir/$name_directory_backup$data_u ];then
	if [ "$zdalny" = "ftp" ];then
		zftp
		usuwanie
	elif [ "$zdalny" = "wyl" ];then
		usuwanie
	fi
  else
	echo -e "\\033[1;31mStara kopia zapasowa zosta?a ju? usuni?ta lub jej w og車le nie by?o\\033[0m"
  fi
 }
function backup-bukkit
 {
  data
  name_directory_backup="kopia_zapasowa_z_dnia_"
  name_file_backup='Kopia_zapasowa_z_'
	mkdir -p $backupdir/$name_directory_backup$data_k/$name_file_backup$data
	mkdir "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pliki_konfiguracyjne"
	mkdir "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/logi"
	mkdir "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/swiaty"
	mkdir "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pluginy"

	cp *.txt "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pliki_konfiguracyjne"&&cp *.log "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/logi"&&cp server.properties "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pliki_konfiguracyjne"&&cp *.yml "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pliki_konfiguracyjne"&&cp -R "$s1" "$s2" "$s3" "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/swiaty"&&cp -R 'plugins' "$backupdir/$name_directory_backup$data_k/$name_file_backup$data/pluginy"

	cd $backupdir/$name_directory_backup$data_k
	zip -r -9 $name_file_backup$data.zip $name_file_backup$data 1> /dev/null&&rm -R $name_file_backup$data
       
       
  if [ -e $backupdir/$name_directory_backup$data_u ];then
	if [ "$zdalny" = "ftp" ];then
		zftp
		usuwanie
	elif [ "$zdalny" = "wyl" ];then
		usuwanie
	fi
  else
	echo -e "\\033[1;31Stara kopia zapasowa zosta?a ju? usuni?ta lub jej w og車le nie by?o\\033[0m"
  fi
 }
case $1 in
	start) #Instrukcje kontroli i startu serwera
		if [ -e mc.pid ];then
			if ( kill -0 $(cat mc.pid) 2> /dev/null );then
				echo -e "\\033[1mSerwer jest uruchomiony, je?li chcesz mo?esz zresetowa? b?d? zatrzyma? go\\033[0m"
				exit 1
			else
				echo -e "\\033[1mPlik z numerem procesu\\033[0m \\033[1;31mmc.pid\\033[0m \\033[1mistnieje, ale serwer nie dzia?a. 
By? mo?e proces serwera zosta? awaryjnie wy??czony\\033[0m"
				pd
			fi
		fi
		if [ "$UID" = "999" ];then
			echo -e "\\033[1;31;40mUWAGA! Ze wzgl?d車w bezpiecze里stwa: Nie uruchamiaj serwera jako root\\033[0m"
			c=1
			while [ $c -le 9 ];do
				echo -en "\\033[1;31m!\\033[0m"
				sleep 1
				c=$((++c))
			done
			echo -e "\\033[1;31m!\\033[0m"
			exit 1
		fi
		if [ -e $jarname ];then
			screen -S $scrname -t $vtermname -md java -d64 -server -Xms$Xms -Xmx$Xmx -XX:SurvivorRatio=15 -XX:TargetSurvivorRatio=90 -XX:MaxGCPauseMillis=500 -XX:+UseAdaptiveGCBoundary -XX:+AggressiveOpts -XX:+UseFastAccessorMethods -XX:PermSize=256m -XX:MaxPermSize=512m -XX:ParallelGCThreads=8 -jar spigot.jar nogui
			echo -e "\\033[1mSerwer Minecraft zostal uruchomiony\\033[0m"
			proc=$(screen -ls | grep $scrname | awk '{print $1}')
			echo ${proc%%.*} > mc.pid
		else
			echo -e "\\033[1;31mNie mo?na odnale?? pliku jar serwera, przerwanie procesu uruchomienia serwera\\033[0m"
			exit 7
		fi
	;;
	stop) #Instrukcje kontroli i zatrzymania serwera
		if [ -e mc.pid ];then
			if ( kill -0 $(cat mc.pid) 2> /dev/null );then
				while [ $s -ge 1 ];do
					sleep 1
					t=$((s--))
					screen -S $scrname -p $vtermname -X stuff "say $info_stop $t"`echo -ne '\015'`
					echo $info_stop $t
				done
				sleep 1
				echo -e "\\033[1mSerwer Minecraft zostal zatrzymany\\033[0m"
				kill -KILL $(cat mc.pid)
			fi
			pd
		else
			echo -e "\\033[1;31mSerwer nie dzia?a (brakuje pliku z numerem procesu \"mc.pid\")\\033[0m"
			pd
			exit 5
		fi	
	;;
	restart) #Instrukcje restartu serwera
			restart&&$0 start || exit 1	
	;;
	status) #Instrukcje kontroli i sprawdzania statusu serwera
		if [ -e mc.pid ];then
			if (kill -0 $(cat mc.pid) 2> /dev/null );then
				echo -e "\\033[1mSerwer dziala\\033[0m"
			else
				echo -e "\\033[1mSerwer nie dziala\\033[0m"
				$0 start || exit 1
			fi
		else
			echo -e "\\033[1;31mSerwer nie dzia?a (brakuje pliku z numerem procesu \"mc.pid\")\\033[0m"
		fi
	;;
	debug) #Instrukcje trybu debugowania serwera
		if [ -e mc.pid ];then
			if (kill -0 $(cat mc.pid) 2> /dev/null );then
				echo -e "\\033[1;31mSerwer dzia?a. Aby uruchomi? tryb debugowania, najpierw zatrzymaj serwer.\\033[0m"
				exit 1
			fi
		else
		echo -e "\\033[1mUWAGA! Zosta? uruchomiony tryb debugowania, aby wyj?? z tego trybu i wy??czy? serwer, w celu normalnego jego uruchomienia w tle po przez parametr start,\\033[0m"
		echo -e "\\033[1;31m naci?nij \"Ctrl+c\"\\033[0m"
			c=1
			while [ $c -le 9 ];do
				echo -en "\\033[1m!\\033[0m"
				sleep 1
				c=$((++c))
			done
			echo -e "\\033[1m!\\033[0m"
			if [ -e $jarname ];then
				java -Xmx$Xmx -Xms$Xms -jar $jarname nogui
			else
				echo -e "\\033[1;31mNie mo?na odnale?? pliku jar serwera, przerwanie procesu uruchomienia serwera\\033[0m"
				exit 7
			fi
		fi
	;;
	kopia)
		if [ -e $backupdir ];then
			wer
			screen -S $scrname -p $vtermname -X stuff "say $info_backup"`echo -ne '\015'`
			echo -e "\\033[1m$info_backup\\033[0m"
		else
			mkdir -p $backupdir
			wer
			screen -S $scrname -p $vtermname -X stuff "say $info_backup"`echo -ne '\015'`
			echo -e "\\033[1m$info_backup\\033[0m"
		fi
	;;
	*)
		echo -e "\\033[1mUzyj $0\\033[0m \\033[1;34m{start|stop|restart|status|debug|kopia}\\033[0m"
		exit 2
esac
exit 0 #Koniec skryptu
