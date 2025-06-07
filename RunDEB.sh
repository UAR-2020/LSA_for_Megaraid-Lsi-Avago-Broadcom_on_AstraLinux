# This script is to install LSIStorageAuthority DEB's
#
vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

((setupstate))
{
SMTP_FILE="/opt/lsi/LSIStorageAuthority/bin/smtpServer"
KEY_FILE="/opt/lsi/LSIStorageAuthority/bin/key.store"
VALUE_FILE="/opt/lsi/LSIStorageAuthority/bin/value.store"

LSA_CONF="/opt/lsi/LSIStorageAuthority/conf/LSA.conf"
MONITOR_CONF="/opt/lsi/LSIStorageAuthority/conf/monitor/config-current.json"
MANAGED_SERVERS_DIR="/opt/lsi/LSIStorageAuthority/bin/managedservers"

lsa_temp="/opt/lsa_temp"

if [ -d "$lsa_temp" ];
then
	rm -rf "/opt/lsa_temp"
fi
	
# make new directory
mkdir "/opt/lsa_temp"

#

if [ -f "$SMTP_FILE" ];
then
	cp "$SMTP_FILE" "/opt/lsa_temp"
fi

#

if [ -f "$KEY_FILE" ];
then
	cp "$KEY_FILE" "/opt/lsa_temp"
fi

#

if [ -f "$VALUE_FILE" ];
then
	cp "$VALUE_FILE" "/opt/lsa_temp"
fi


#

if [ -f "$LSA_CONF" ];
then
	cp "$LSA_CONF" "/opt/lsa_temp"
fi


#

if [ -f "$MONITOR_CONF" ];
then
	cp "$MONITOR_CONF" "/opt/lsa_temp"
fi

#

if [ -d "$MANAGED_SERVERS_DIR" ];
then
	cp -rf "$MANAGED_SERVERS_DIR" "/opt/lsa_temp"
fi

./deleteOldVersion_deb.sh
retval=$?
if [ $retval == 1 ]; then
  if [ -d "$lsa_temp" ];
  then
	rm -rf "/opt/lsa_temp"
  fi
  exit
fi
}

if [ "$setuptype" = "" ]; then
	setuptype="g"
fi

IsPortAvailable()
{
    port=$1

    output=""

    if [[ -x "/bin/netstat" ]]
    then
        output=`netstat -na | grep LISTEN | grep :${port} | cut -d: -f2 | awk '{print $1}' | head -1`
    elif [[ -x "/usr/sbin/ss" ]]
    then
        output=`ss -l | grep LISTEN | grep ${port} | awk '{print $6}' | head -1`
    fi

    if [[ $output = "" ]]; then
        return 0
    fi

    if [ ${port} = ${output} ]; then
        return 1
    else
        return 0
    fi
}

IsStringContainingSpaces()
{
    string="$1"
    if [[ "$string" =~ \ + ]]; then
        return 1
    else
        return 0
    fi
}

IsPortInrange()
{
    port=$1

    validateStringLength $port 15
    if [ $? != 0 ]; then
        return 1
    fi
    if [ ${port} -lt 1 ] || [ ${port} -gt 65535 ]; then
        return 1
    else
        return 0
    fi
}

IsNumericValue()
{
    Value="$1"

    if [[ "$Value" =~ [^0-9]+ ]] ; then
        return 1
    else
        return 0
    fi
}

validateStringLength()
{
    string="$1"
    validLength=$2

    length=`echo "${string}" | awk '{ print length }'`
    if [ ${length} -gt ${validLength} ]; then
        return 1
    else
        return 0
    fi
}

getUserInput()
{
	if [ "$setupmode" = "SILENT" ]; then
           
		IsNumericValue $setupstate
		if [ $? != 0 ]; then
                    echo "Please enter valid alert notification value."
                    echo " "
                    echo "Exiting installation."
		    exit	
		fi
        	if [[ $setupstate = "" ]]; then
            	   setupstate="1"
        	fi

           setup_state_comp=$((setupstate+1))
	   if [ $setupstate -lt 1 ] || [ $setupstate -gt 4 ]; then
                 echo "The given alert notification value is out of valid range."
		exit
	   fi
        	setup_state=$((setupstate-1))
	else
	   setup_state=$((setupstate-1))

	fi
###########################################################################################
################ Read Webserver Port ######################################################
###########################################################################################

    while (true)
    do
	if [ "$setupmode" = "SILENT" ]; then
        	nginxPort=$nginx_port
		IsNumericValue $nginxPort
		if [ $? != 0 ]; then
                    echo "Please enter valid Port Number."
                    echo " "
                    echo "Exiting installation."
		    exit	
		fi

        	if [[ $nginxPort = "" ]]; then
            	nginxPort="2463"
        	fi
	else
        	read -p 'Enter Web Server port [2463] : ' nginxPort
        	if [[ $nginxPort = "" ]]; then
            	nginxPort="2463"
        	fi
	fi

        IsNumericValue $nginxPort
        if [ $? != 0 ]; then
            echo "Invalid Port number, try another one."
             if [ $setupmode != "SILENT" ]; then
             continue
            else 
             exit
            fi
        fi

        IsPortInrange $nginxPort
        if [ $? != 0 ]; then
            echo "The given Port Number is out of valid range[1-65535], try another one."
             if [ $setupmode != "SILENT" ]; then
             continue
            else 
             exit
            fi
        fi


        IsPortAvailable $nginxPort
        if [ $? = 0 ]; then
            break
        else
            #echo "The given Port is in use, try another one."
            while(true)
            do
                nginxPort=$(( $nginxPort + 1 ))
                IsPortAvailable $nginxPort
                if [ $? = 0 ]; then
                    break
                fi
            done
            echo "The given port is in use, the next available port is $nginxPort"
            echo ""
            read -p 'Would you like to continue with this available port [y/n]: ' config
            if [ "${config}" = "y" ] || [ "${config}" = "Y" ]; then
                break
            fi
        fi
    done
	
###########################################################################################
################ Read LSIStorageAuthority Port ############################################
###########################################################################################
    while (true)
    do
	if [ "$setupmode" = "SILENT" ]; then
		LSAappPort=$LSA_port
               IsNumericValue $LSA_port
                if [ $? != 0 ]; then
                    echo "Please enter valid Port Number."
                    echo " "
                    echo "Exiting installation."
                    exit
                fi
        	if [[ $LSAappPort = "" ]]; then
            	LSAappPort="9000"
        	fi
  	else
	        read -p 'Enter LSA port [9000] : ' LSAappPort
        	if [[ $LSAappPort = "" ]]; then
            	LSAappPort="9000"
        	fi
	fi

        if [[ $LSAappPort = $nginxPort ]]; then
            echo "Ports used for webserver and LSI Storage Authority cannot be the same, try another one."
            if [ $setupmode != "SILENT" ]; then
             continue
            else 
             exit
            fi
        fi
        IsNumericValue $LSAappPort
        if [ $? != 0 ]; then
            echo "Invalid Port number, try another one."
            if [ $setupmode != "SILENT" ]; then
             continue
            else 
             exit
            fi
        fi

        IsPortInrange $LSAappPort
        if [ $? != 0 ]; then
            echo "The given Port Number is out of valid range[1-65535], try another one."
            if [ $setupmode != "SILENT" ]; then
             continue
            else 
             exit
            fi
        fi

        IsPortAvailable $LSAappPort
        if [ $? = 0 ]; then
            break
        else
            #echo "The given Port is in use, try another one."
            while(true)
            do
                LSAappPort=$(( $LSAappPort + 1 ))
                if [[ $LSAappPort != $nginxPort ]]; then
                  IsPortAvailable $LSAappPort
                  if [ $? = 0 ]; then
                      break
                  fi
                fi
            done
            echo "The given port is in use, the next available port is $LSAappPort"
            echo ""
            read -p 'Would you like to continue with this available port [y/n]: ' config
            if [ "${config}" = "y" ] || [ "${config}" = "Y" ]; then
                break
            fi
        fi
    done
}

install_rpms ()
{
#3rd party library installation
utils_pkg=`dpkg -l | grep -w lsa-lib-utils | wc -l`
if [ $utils_pkg = 0 ]; then
	echo "Installing  LSA_lib_utils-1.16-00"
        dpkg -i LSA_lib_utils-1.16-1_amd64.deb
else
        newlibutilsversion="1.09-1"
        oldlibutilsversion=`dpkg-query -W -f='${Version}\n' lsa-lib-utils`
	vercomp $newlibutilsversion $oldlibutilsversion
        if [ $? == 1 ]; then
	 echo "Installing  LSA_lib_utils-1.16-00"
         dpkg -i LSA_lib_utils-1.16-1_amd64.deb 
        else
        vercomp $newversion $oldversion
        if [ $? == 0 ]; then
         echo "lsa-lib-utils already installed"
        fi
        fi

fi

utils_pkg=`dpkg -l | grep -w lsa-lib-utils2 | wc -l`
if [ $utils_pkg = 0 ]; then
	slpFound=0

        if [ -x /usr/sbin/slpd ]; then
		slpFound=1
                echo "openSLP server RPM is installed"
        
        elif [ -x /usr/local/sbin/slpd ]; then
                slpFound=1
                echo "openSLP server RPM is installed from source"
        
        else
                echo "openSLP server RPM is not installed"
                slpFound=0
        fi

	if [ $slpFound = 0 ]; then
             while (true)
             do
        	echo "Installing the above packages from your installation source is highly recommended"
        	echo "However proceeding further installs SLP package bundled with LSA from openslp.org."
        	echo "Continue "Y/N"? "
        	read proceed

                if [[ $proceed = "" ]]; then
                        echo "Input not provided, try again. "
                        echo ""
                        continue
                elif [ ${proceed} = "y" ] || [ ${proceed} = "Y" ]; then
			if ! [ -d /usr/local/var/log ]; then
                             mkdir -p /usr/local/var/log
                        fi
			echo "Installing  LSA_lib_utils2-9.00-00"
                	dpkg -i LSA_lib_utils2-9.00-1_amd64.deb
			if ! [ $? = 0 ]; then
				echo "SLP Installation failed due to unresolved dependencies ! Proceeding with LSA installation now. Please try install SLP from installation source before starting LSA to have functionalities work as expected..."
                                break
			fi
                     break
        	else
			echo "Installation exited...Please install SLP from installation source and return to install LSA. See you soon with the SLP installation..."
			exit
		fi
              done
	fi
else
        newlibutils2version="9.00-1"
        oldlibutils2version=`dpkg-query -W -f='${Version}\n' lsa-lib-utils2`
	vercomp $newlibutils2version $oldlibutils2version
        if [ $? == 1 ]; then
			slpFound=0

                        if [ -x /usr/sbin/slpd ]; then
                            slpFound=1
                            echo "openSLP server RPM is installed"

                        elif [ -x /usr/local/sbin/slpd ]; then
                            slpFound=1
                            echo "openSLP server RPM is installed from source"

                        else
                            echo "openSLP server RPM is not installed"
                            slpFound=0
                        fi

			if [ $slpFound = 0 ]; then
                            while (true)
                            do
        			echo "Installing the above package(s) from your installation source is highly recommended"
        			echo "However proceeding further installs SLP package bundled with LSA from openslp.org."
        			echo "Continue (Y/N)? "
        			read proceed

                                if [[ $proceed = "" ]]; then
                                   echo "Input not provided, try again. "
                                   echo ""
                                   continue
        			elif [ ${proceed} = "y" ] || [ ${proceed} = "Y" ]; then
					if ! [ -d /usr/local/var/log ]; then
                                            mkdir -p /usr/local/var/log
                                        fi
					echo "Installing  LSA_lib_utils2-9.00-00"
                			dpkg -i LSA_lib_utils2-9.00-1_amd64.deb
					if [ $? = 0 ]; then
                                		echo "SLP Installation failed due to unresolved dependencies ! Proceeding with LSA installation now. Please try install SLP from installation source before starting LSA to have functionalities work as expected..."
                                                break
                        		fi
                                     break
        			else
                			echo "Installation exited...Please install SLP from installation source and return to install LSA. See you soon with the SLP installation..."
					exit
        			fi
                            done
			fi
               
        else
        vercomp $newversion $oldversion
        if [ $? == 0 ]; then
         echo "lsa-lib-utils2 already installed"
        fi
        fi
fi


# Complete Installation
   dpkg -i LSIStorageAuthority*_amd64.deb

uninst="/opt/lsi/LSIStorageAuthority/.__uninst.sh"
echo "oldversion=`dpkg-query -W -f='\${Version}\n' lsistorageauthority`" >> $uninst
echo "oldversion1=\${oldversion%??}" >> $uninst
echo "echo \"Uninstalling LSIStorageAuthority-\$oldversion1\"" >> $uninst
echo "service LsiSASH stop > /tmp/LSIStorageAuthority_uninstall.txt 2>&1" >> $uninst
echo "dpkg -r lsistorageauthority > /tmp/LSIStorageAuthority_uninstall.txt 2>&1" >> $uninst
echo "dpkg -P lsistorageauthority > /tmp/LSIStorageAuthority_uninstall.txt 2>&1" >> $uninst
echo "status=\$?" >>$uninst
echo "if [ \$status -ne 0 ]; then" >> $uninst
echo "     echo" >> $uninst
echo "     echo \"LSA uninstallation failed!\"" >> $uninst
echo "     echo" >> $uninst
echo "     exit 1" >> $uninst
echo "fi" >> $uninst
if [ -d "/opt/lsi/LSA/libs2" ]; then
echo "echo \"Uninstalling LSA_lib_utils2-9.00-00\"" >> $uninst
echo "dpkg -r lsa-lib-utils2 > /tmp/LSIStorageAuthority_uninstall.txt 2>&1" >> $uninst
echo "dpkg -P lsa-lib-utils2 > /tmp/LSIStorageAuthority_uninstall.txt 2>&1" >> $uninst
echo "status=\$?" >>$uninst
echo "if [ \$status -ne 0 ]; then" >> $uninst
echo "     echo" >> $uninst
echo "     echo \"LSA uninstallation failed!\"" >> $uninst
echo "     echo" >> $uninst
echo "     exit 1" >> $uninst
echo "else" >> $uninst
echo " if [ \"\$(pidof ./slpd)\" ] || [ \"\$(pidof /opt/lsi/LSA/libs2/./slpd)\" ]; then" >> $uninst
echo "    pid=\`ps -ef | grep "./slpd" | grep -v grep | awk  '{print \$2}'\`" >> $uninst
echo "    kill -s 9 $pid > /tmp/LSIStorageAuthority_uninstall.txt 2>&1" >> $uninst
echo " fi" >> $uninst
echo "fi" >> $uninst
fi
echo "echo \"Uninstalling LSA_lib_utils-1.16-00\"" >> $uninst
echo "dpkg -r lsa-lib-utils > /tmp/LSIStorageAuthority_uninstall.txt 2>&1" >> $uninst
echo "dpkg -P lsa-lib-utils > /tmp/LSIStorageAuthority_uninstall.txt 2>&1" >> $uninst
echo "status=\$?" >>$uninst
echo "if [ \$status -ne 0 ]; then" >> $uninst
echo "     echo" >> $uninst
echo "     echo \"LSA uninstallation failed!\"" >> $uninst
echo "     echo" >> $uninst
echo "     exit 1" >> $uninst
echo "fi" >> $uninst
echo "rm -rf /opt/lsi/LSIStorageAuthority/bin/libstorelib* 2>|/dev/null" >> $uninst
echo "rm -rf /opt/lsi/LSIStorageAuthority 2>|/dev/null" >> $uninst
echo "if [ -d "/opt/lsi" ]; then" >> $uninst
echo "     rmdir /opt/lsi 2>|/dev/null" >> $uninst
echo "fi" >> $uninst
echo "rm -rf /etc/init.d/LsiSASH 2>|/dev/null" >> $uninst
echo "update-rc.d -f LsiSASH remove 2>|/dev/null" >> $uninst

echo "echo" >> $uninst
echo "echo \"LSA uninstallation successful!\"" >> $uninst
echo "echo" >> $uninst

chmod +x $uninst

update-rc.d LsiSASH defaults 2>|/dev/null
}

update_conf ()
{
		# replace with old sensitive data
	SMTP_FILE="/opt/lsa_temp/smtpServer"
	KEY_FILE="/opt/lsa_temp/key.store"
	VALUE_FILE="/opt/lsa_temp/value.store"

	LSA_CONF="/opt/lsa_temp/LSA.conf"
	MONITOR_CONF="/opt/lsa_temp/config-current.json"
	MANAGED_SERVERS_DIR="/opt/lsa_temp/managedservers"
	
	LSA_home="/opt/lsi/LSIStorageAuthority"

	#

	if [ -f "$SMTP_FILE" ];
	then
		rm -f "$LSA_home/bin/smtpServer"
		cp "$SMTP_FILE" "$LSA_home/bin"
	fi

	#

	if [ -f "$KEY_FILE" ];
	then
		rm -f "$LSA_home/bin/key.store"
		cp "$KEY_FILE" "$LSA_home/bin"
	fi

	#

	if [ -f "$VALUE_FILE" ];
	then
		rm -f "$LSA_home/bin/value.store"
		cp "$VALUE_FILE" "$LSA_home/bin"
	fi

	#

	#if [ -f "$LSA_CONF" ];
	#then
	#	rm -f "$LSA_home/conf/LSA.conf"
	#	cp "$LSA_CONF" "$LSA_home/conf"
	#fi


	#

	if [ -f "$MONITOR_CONF" ];
	then
		rm -f "$LSA_home/conf/monitor/config-current.json"
		cp "$MONITOR_CONF" "$LSA_home/conf/monitor"
	fi

	#

	if [ -d "$MANAGED_SERVERS_DIR" ];
	then
		rm -rf "$LSA_home/bin/managedservers"
		cp -rf "$MANAGED_SERVERS_DIR" "$LSA_home/bin"
	fi
	
	rm -rf "/opt/lsa_temp"

        new_nginx_port=$nginxPort
	new_LSA_port=$LSAappPort
	install_type="installation_type = "
	#echo $old_nginx_port
	#echo $old_LSA_port
	#echo $new_nginx_port
	#echo $new_LSA_port

	var=`cat /opt/lsi/LSIStorageAuthority/installtype`
	act_str="retrieve_range_of_events_since = 0"
	rep_str="retrieve_range_of_events_since = $setup_state"

	if [ "$var" == "gateway" ]; then
	new_installation_type="0"
	old_nginx_port=`grep "default_server" $LSA_home/server/conf/nginx.conf | cut -b 22-34 | head -n 1`
	old_LSA_port=`grep "listening_port = " $LSA_home/conf/LSA.conf |  cut -b 18-28 | head -n 1`
	temp=`echo $old_LSA_port | sed 's/[^0-9]*//g'`
	sed -e s/"$old_LSA_port"/"$new_LSA_port"/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
    rm -rf "$LSA_home/conf/LSA.conf_new"
    old_LSA_port="LSA_Default"
	old_installation_type=`grep "installation_type = " $LSA_home/conf/LSA.conf |  cut -b 21-23`
	old_LSA_client_port=`grep "client_listening_port" $LSA_home//conf/LSA.conf | cut -b 25-28 | head -n 1`
	sed -e s/"$install_type$old_installation_type"/"$install_type$new_installation_type"/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
	rm -rf "$LSA_home/conf/LSA.conf_new"	
	sed -e s/$old_nginx_port/$new_nginx_port/g "$LSA_home/server/conf/nginx.conf" > "$LSA_home/server/conf/nginx.conf_new"
	cp "$LSA_home/server/conf/nginx.conf_new" "$LSA_home/server/conf/nginx.conf"
	rm -rf "$LSA_home/server/conf/nginx.conf_new"
        #sed -e s/$old_nginx_port/$new_nginx_port/g "$LSA_home/server/conf/Sample_SSL_https/nginx.conf" > "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
        #cp "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new" "$LSA_home/server/conf/Sample_SSL_https/nginx.conf"
        #rm -rf "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
	sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
	rm -rf "$LSA_home/conf/LSA.conf_new"
        sed -i "s/\(client_listening_port = \)\(.*\)/client_listening_port = $new_nginx_port/" "$LSA_home/conf/LSA.conf"
	sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/server/conf/nginx.conf" > "$LSA_home/server/conf/nginx.conf_new"
	cp "$LSA_home/server/conf/nginx.conf_new" "$LSA_home/server/conf/nginx.conf"
	rm -rf "$LSA_home/server/conf/nginx.conf_new"
	#sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/server/conf/Sample_SSL_https/nginx.conf" > "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
	#cp "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new" "$LSA_home/server/conf/Sample_SSL_https/nginx.conf"
	#rm -rf "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"

	elif [ "$var" == "standalone" ]; then
	new_installation_type="1"
	old_nginx_port=`grep "default_server" $LSA_home/server/conf/nginx.conf | cut -b 22-34 | head -n 1`
	old_LSA_port=`grep "listening_port = " $LSA_home/conf/LSA.conf |  cut -b 18-28 | head -n 1`
	sed -e s/"$old_LSA_port"/"$new_LSA_port"/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
    rm -rf "$LSA_home/conf/LSA.conf_new"
        temp=`echo $old_LSA_port | sed 's/[^0-9]*//g'`    
        old_LSA_port="LSA_Default"
	old_installation_type=`grep "installation_type = " $LSA_home/conf/LSA.conf |  cut -b 21-23`
	old_LSA_client_port=`grep "client_listening_port" $LSA_home/conf/LSA.conf | cut -b 25-28 | head -n 1`
	sed -e s/$old_nginx_port/$new_nginx_port/g "$LSA_home/server/conf/nginx.conf" > "$LSA_home/server/conf/nginx.conf_new"
	cp "$LSA_home/server/conf/nginx.conf_new" "$LSA_home/server/conf/nginx.conf"
	rm -rf "$LSA_home/server/conf/nginx.conf_new"
        #sed -e s/$old_nginx_port/$new_nginx_port/g "$LSA_home/server/conf/Sample_SSL_https/nginx.conf" > "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
        #cp "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new" "$LSA_home/server/conf/Sample_SSL_https/nginx.conf"
        #rm -rf "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
	sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
	rm -rf "$LSA_home/conf/LSA.conf_new"
	sed -e s/"$install_type$old_installation_type"/"$install_type$new_installation_type"/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
	rm -rf "$LSA_home/conf/LSA.conf_new"
        sed -i "s/\(client_listening_port = \)\(.*\)/client_listening_port = $new_nginx_port/" "$LSA_home/conf/LSA.conf"
	sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/server/conf/nginx.conf" > "$LSA_home/server/conf/nginx.conf_new"
	cp "$LSA_home/server/conf/nginx.conf_new" "$LSA_home/server/conf/nginx.conf"
	rm -rf "$LSA_home/server/conf/nginx.conf_new"
	#sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/server/conf/Sample_SSL_https/nginx.conf" > "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
	#cp "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new" "$LSA_home/server/conf/Sample_SSL_https/nginx.conf"
	#rm -rf "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
	
	elif [ "$var" == "directagent" ]; then
	new_installation_type="2"
	old_nginx_port=`grep "default_server" $LSA_home/server/conf/nginx.conf | cut -b 22-34 | head -n 1`
	old_LSA_port=`grep "listening_port = " $LSA_home/conf/LSA.conf |  cut -b 18-28 | head -n 1`
        temp=`echo $old_LSA_port | sed 's/[^0-9]*//g'`    
	sed -e s/"$old_LSA_port"/"$new_LSA_port"/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
    rm -rf "$LSA_home/conf/LSA.conf_new"
        old_LSA_port="LSA_Default"
	old_installation_type=`grep "installation_type = " $LSA_home/conf/LSA.conf |  cut -b 21-23`
	old_LSA_client_port=`grep "client_listening_port" $LSA_home/conf/LSA.conf | cut -b 25-28 | head -n 1`
	sed -e s/$old_nginx_port/$new_nginx_port/g "$LSA_home/server/conf/nginx.conf" > "$LSA_home/server/conf/nginx.conf_new"
	cp "$LSA_home/server/conf/nginx.conf_new" "$LSA_home/server/conf/nginx.conf"
	rm -rf "$LSA_home/server/conf/nginx.conf_new"
        #sed -e s/$old_nginx_port/$new_nginx_port/g "$LSA_home/server/conf/Sample_SSL_https/nginx.conf" > "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
        #cp "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new" "$LSA_home/server/conf/Sample_SSL_https/nginx.conf"
        #rm -rf "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
	sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
	rm -rf "$LSA_home/conf/LSA.conf_new"
	sed -e s/"$install_type$old_installation_type"/"$install_type$new_installation_type"/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
	rm -rf "$LSA_home/conf/LSA.conf_new"
        sed -i "s/\(client_listening_port = \)\(.*\)/client_listening_port = $new_nginx_port/" "$LSA_home/conf/LSA.conf"
	sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/server/conf/nginx.conf" > "$LSA_home/server/conf/nginx.conf_new"
	cp "$LSA_home/server/conf/nginx.conf_new" "$LSA_home/server/conf/nginx.conf"
	rm -rf "$LSA_home/server/conf/nginx.conf_new"
	#sed -e s/$old_LSA_port/$new_LSA_port/g "$LSA_home/server/conf/Sample_SSL_https/nginx.conf" > "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"
	#cp "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new" "$LSA_home/server/conf/Sample_SSL_https/nginx.conf"
	#rm -rf "$LSA_home/server/conf/Sample_SSL_https/nginx.conf_new"

	elif [ "$var" == "localagent" ]; then
	new_installation_type="129"
	old_installation_type=`grep "installation_type = " $LSA_home/conf/LSA.conf |  cut -b 21-23`
	sed -e s/"$install_type$old_installation_type"/"$install_type$new_installation_type"/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	cp "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"
	rm -rf "$LSA_home/conf/LSA.conf_new"	
	fi

	sed -e s/"$act_str"/"$rep_str"/g "$LSA_home/conf/LSA.conf" > "$LSA_home/conf/LSA.conf_new"
	mv "$LSA_home/conf/LSA.conf_new" "$LSA_home/conf/LSA.conf"

        #var0="[Desktop Entry]"
        #var1="Name=LaunchLSA"
        #var2="Comment=Launch LSA from shortcut"
        #var3="Exec=/opt/lsi/LSIStorageAuthority/startupLSAUI.sh"
        #var4="Terminal=false"
        #var5="Type=Application"

        #echo -e "$var0\n$var1\n$var2\n$var3\n$var4\n$var5\n" >> /$USER/Desktop/LaunchLSA.desktop

        #ln -sf /opt/lsi/LSIStorageAuthority/startupLSAUI.sh /$USER/Desktop/LaunchLSA
        #chmod +x /$USER/Desktop/LaunchLSA.desktop
}

service_restart ()
{
        ln -sf /opt/lsi/LSA/libs/libcrypto.so.1.1 /opt/lsi/LSIStorageAuthority/bin/libcrypto.so.1.1
        ln -sf /opt/lsi/LSA/libs/libssl.so.1.1 /opt/lsi/LSIStorageAuthority/bin/libssl.so.1.1

	if [ -d /opt/lsi/LSA/libs2 ]; then
		ln -sf /opt/lsi/LSA/libs2/libslp.so.1.0.0 /opt/lsi/LSIStorageAuthority/plugins/libslp.so.1
	fi

        LDAP_LIB="libldap-2.4.so.2"
        LDAPR_LIB="libldap_r-2.4.so.2"

        test_ldap_lib=`ldconfig -p | grep libldap`
        test_ldap_lib_count=`echo $test_ldap_lib | wc -m`

        if [ $test_ldap_lib_count -gt 1 ] ; then         
            target=`echo $test_ldap_lib | awk '{print $4}' | head -1`
            ln -s $target /opt/lsi/LSIStorageAuthority/bin/$LDAP_LIB 2>|/dev/null
            test_ldapr_lib_count=`echo $test_ldapr_lib | wc -m`
        elif [ $test_ldap_lib_count -eq 1 ] ; then
            test_ldapr_lib=`ldconfig -p | grep $LDAPR_LIB`
            test_ldapr_lib_count=`echo $test_ldapr_lib | wc -m`
            if [ $test_ldapr_lib_count -gt 1 ] ; then
                target=`echo $test_ldapr_lib | awk '{print $4}' | head -1`
                #echo "Creating symbolic link to LDAP re-entrant library $target for LSA to work..."
                ln -s $target /opt/lsi/LSIStorageAuthority/bin/$LDAP_LIB 2>|/dev/null
            fi
        fi
	
	service LsiSASH start
	service LsiSASH restart

	echo
        echo "LSA installation successful!"
        echo
}

#######################################
############ Main #####################
#######################################
	getUserInput
	install_rpms
	update_conf
	service_restart
