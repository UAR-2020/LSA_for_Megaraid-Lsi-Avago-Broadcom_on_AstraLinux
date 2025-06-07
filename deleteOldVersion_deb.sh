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


clear
echo "Checking for any Old Version"
searchcont=1
if [ $searchcont = 1 ]; then
 linecount=`dpkg -l | grep -w lsistorageauthority | wc -l`
 if [ $linecount = 0 ]; then
  status=1
 else
  if [ $linecount = 1 ]; then
     status=0
  else
    echo "More than one copy of LSIStorageAuthority has been installed. Exiting installation."
    exit 1
  fi
 fi

#echo "setuptype is $setuptype";
#echo "upgradesetuptype is $upgradesetuptype";
																
 if [ $status = 0 ]; then
  newversion="008.004.010.000"
  oldversion=`dpkg-query -W -f='${Version}\n' lsistorageauthority`
  oldversion=${oldversion::-2}
  vercomp $newversion $oldversion
  if [ $? == 1 ]; then


      if [ "$setupmode" = "SILENT" ]; then
			ELU="y"
        	else
        		echo " LSIStorageAuthority application is already installed"
        		echo " Would you like to continue with the upgrade [y/n]:"
        		echo " y, uninstall previous version and install latest version"
        		echo " n, No changes made to the system, exit the installation"
			read ELU
      fi
#	echo "$ELU"
	if [ "$ELU" != "y" -a "$ELU" != "Y" ]; then
	echo "Exiting Installation " 
	exit 1
	fi
  	#. /etc/init.d/slim_profile
	LSA_HOME=/opt/lsi/LSIStorageAuthority
  	"$LSA_HOME/.__uninst.sh"
	status=$?
	if [ $status = 0 ]; then
		if [ -f "$LSA_HOME/.__uninst.sh" ]; then	
			echo "Uninstall Failed. Exiting installation."
			exit 1
		fi
		echo "Uninstall Completed Successfully"
	else
		echo "Uninstall Failed. Exiting installation."
		exit 1
	fi
         
  else
        vercomp $newversion $oldversion
        if [ $? == 0 ]; then
         echo "The version is already installed."
	 echo "Exiting installation."
         exit 1
        else
	 a=$oldversion
	 b=$newversion
	 
	 a1=`echo $a | sed 's/^0*//g' | awk -F  "." '{print $1}'`
	 a2=`echo $a | sed 's/^0*//g' | awk -F  "." '{print $2}'`
	 a3=`echo $a | sed 's/^0*//g' | awk -F  "." '{print $3}'`
	 a4=`echo $a | sed 's/^0*//g' | awk -F  "." '{print $4}'`

	 b1=`echo $b | sed 's/^0*//g' | awk -F  "." '{print $1}'`
	 b2=`echo $b | sed 's/^0*//g' | awk -F  "." '{print $2}'`
	 b3=`echo $b | sed 's/^0*//g' | awk -F  "." '{print $3}'`
	 b4=`echo $b | sed 's/^0*//g' | awk -F  "." '{print $4}'`

	 (( a1 += 0 )) 2>|/dev/null
	 (( a2 += 0 )) 2>|/dev/null
	 (( a3 += 0 )) 2>|/dev/null
	 (( a4 += 0 )) 2>|/dev/null

	 (( b1 += 0 )) 2>|/dev/null
	 (( b2 += 0 )) 2>|/dev/null
	 (( b3 += 0 )) 2>|/dev/null
	 (( b4 += 0 )) 2>|/dev/null

	 isGreater=0

	 if [ $a1 -gt $b1 ] ; then
        	isGreater=1
	 elif [ $a2 -gt $b2 ] ; then
        	isGreater=1
	 elif [ $a3 -gt $b3 ] ; then
	        isGreater=1
	 elif [ $a4 -gt $b4 ] ; then
	        isGreater=1
	fi
	 
	 if [ $isGreater -eq 1 ] ; then
          echo "Installed version is newer"
	  echo "Exiting installation."
	  exit 1
	 else
          if [ "$setupmode" = "SILENT" ]; then
                        ELU="y"
                else
                        echo " LSIStorageAuthority application is already installed"
                        echo " Would you like to continue with the upgrade [y/n]:"
                        echo " y, uninstall previous version and install latest version"
                        echo " n, No changes made to the system, exit the installation"
                        read ELU
      fi
#       echo "$ELU"
        if [ "$ELU" != "y" -a "$ELU" != "Y" ]; then
        echo "Exiting Installation "
        exit 1
        fi
        #. /etc/init.d/slim_profile
        LSA_HOME=/opt/lsi/LSIStorageAuthority
        "$LSA_HOME/.__uninst.sh"
         status=$?
         if [ $status = 0 ]; then
                if [ -f "$LSA_HOME/.__uninst.sh" ]; then
                        echo "Uninstall Failed. Exiting installation."
                        exit 1
                fi
                echo "Uninstall Completed Successfully"
         else
                echo "Uninstall Failed. Exiting installation."
                exit 1
         fi
	fi
       fi
  fi
 else
  echo "No Old Version Found"
 fi
fi
echo "Continuing with installation"
exit 0
