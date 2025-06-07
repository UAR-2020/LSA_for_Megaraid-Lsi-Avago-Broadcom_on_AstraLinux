echo " "
requireSetupType="1"
if [ $# -gt 0 ]
then
	case $1 in
		"-notrap")
			requireSetupType="1"
                        ;;
		"-ru") 
			requireSetupType="1"
                        ;;
		 *)
 			requireSetupType="0"
                        ;;
	esac

fi
if [ "$requireSetupType" -eq 1 ]
then

echo "STOP!  BEFORE YOU INSTALL OR USE THIS SOFTWARE"
echo " "
echo "Carefully read this Software License Agreement. Installing or using this Software indicates that you agree to abide by this Software License Agreement.  If you do not agree with it, promptly return the Software and we will refund the purchase price."
echo " "
echo " "
echo "          Software License Agreement"
echo " "
echo "PLEASE READ CAREFULLY BEFORE STARTING INSTALLATION OF THE SOFTWARE"
echo " "
echo "THE SOFTWARE AND DOCUMENTATION PROVIDED HEREIN IS PROPRIETARY TO Broadcom Inc AND ITS LICENSORS. Broadcom Inc IS WILLING TO LICENSE THE SOFTWARE AND DOCUMENTATION TO YOU ONLY UPON THE CONDITION THAT YOU ACCEPT ALL OF THE TERMS CONTAINED IN THIS SOFTWARE LICENSE AGREEMENT. BY USING THIS SOFTWARE, YOU, THE END-USER, AGREE TO THE LICENSE TERMS BELOW. IF YOU DO NOT AGREE TO THESE TERMS, YOU MAY NOT USE THE SOFTWARE."
echo " "
echo "1. Grant of License"
echo " "
echo "Conditioned upon compliance with the terms and conditions of this Software License Agreement ("Agreement"), Broadcom Inc ("LSI") grants you, the original licensee, a nonexclusive and nontransferable limited license to use (including installation on multiple computers) for your internal business purposes the "Software and the Documentation, "Permitted Use"""
echo " "
echo "2. License Conditions; Confidentiality"
echo " "
echo "The Software and Documentation are confidential information of LSI and its licensors. Except as expressly permitted herein, you may not disclose or give copies of the Software or Documentation to others and you may not let others gain access to the same. You may not post the Software or Documentation, or otherwise make available, in any form, on the Internet or in other public places or media. You may not modify, adapt, translate, rent, lease, loan, distribute or resell for profit, or create derivative works based upon, the Software or Documentation or any part of thereof, but you may transfer the original media containing the Software and Documentation on a one-time basis provided you retain no copies of the Software and Documentation and the recipient assumes all of the terms of this Agreement. You may not reverse engineer, decompile, disassemble or otherwise attempt to derive source code from the Software except to the extent allowed by law."
echo " "
echo "3. No Warranty"
echo " "
echo "YOU ACKNOWLEDGE THAT THE SOFTWARE AND DOCUMENTATION ARE LICENSED "AS IS," AND LSI MAKES NO REPRESENTATIONS OR WARRANTIES EXPRESS, IMPLIED, STATUTORY OR OTHERWISE REGARDING THE SOFTWARE AND DOCUMENTATION.  ANY IMPLIED WARRANTY OR CONDITION OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, NON-INFRINGEMENT, SATISFACTORY QUALITY, NON-INTERFERENCE, ACCURACY OF INFORMATIONAL CONTENT, OR ARISING FROM A COURSE OF DEALING, LAW, USAGE, OR TRADE PRACTICE, ARE HEREBY EXCLUDED TO THE EXTENT ALLOWED BY APPLICABLE LAW AND ARE EXPRESSLY DISCLAIMED BY LSI, ITS SUPPLIERS AND LICENSORS.  TO THE EXTENT AN IMPLIED WARRANTY CANNOT BE EXCLUDED, SUCH WARRANTY IS LIMITED IN DURATION TO A PERIOD OF THIRTY (30) DAYS FROM THE DATE OF RECEIPT BY THE ORIGINAL LICENSEE.  BECAUSE SOME STATES OR JURISDICTIONS DO NOT ALLOW LIMITATIONS ON HOW LONG AN IMPLIED WARRANTY LASTS, THE ABOVE LIMITATION MAY NOT APPLY. THIS WARRANTY GIVES YOU SPECIFIC LEGAL RIGHTS, AND YOU MAY ALSO HAVE OTHER RIGHTS WHICH VARY FROM JURISDICTION TO JURISDICTION."
echo " "
echo "4. LIMITATION OF LIABILITY AND REMEDIES"
echo " "
echo "IN NO EVENT SHALL LSI OR ITS LICENSORS BE LIABLE TO YOU FOR ANY INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL OR SPECIAL DAMAGES ARISING FROM THIS AGREEMENT OR THE USE OF THE SOFTWARE OR DOCUMENTATION (INCLUDING, WITHOUT LIMITATION, DAMAGE FOR LOSS OF BUSINESS PROFITS, BUSINESS INTERRUPTION, LOSS OF BUSINESS INFORMATION, LOSS OF GOODWILL, OR OTHER PECUNIARY LOSS), WHETHER RESULTING FROM LSI'S NEGLIGENCE OR OTHERWISE, EVEN IF LSI WAS ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. LSI'S MAXIMUM LIABILITY FOR ANY DAMAGES ARISING UNDER THIS AGREEMENT AND THE USE OF THE SOFTWARE AND DOCUMENTATION WILL NOT EXCEED AN AMOUNT EQUAL TO THE LICENSE FEES YOU PAID TO LSI FOR THE SOFTWARE AND DOCUMENTATION. THE LAWS OF SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR LIMITATION OF LIABILITY, AND THE ABOVE EXCLUSION MAY NOT APPLY TO YOU."
echo " "
echo "5. U.S. Government End User Purchasers"
echo " "
echo "The Software and Documentation qualify as "commercial items," as that term is defined at Federal Acquisition Regulation (.FAR.) (48 C.F.R.) 2.101, consisting of "commercial computer software" and "commercial computer software documentation" as such terms are used in FAR 12.212. Consistent with FAR 12.212 and DoD FAR Supp. 227.7202-1 through 227.7202-4, and notwithstanding any other FAR or other contractual clause to the contrary, you may provide to Government end user or, if this Agreement is direct, Government end user will acquire, the Software and Documentation with only those rights set forth in this Agreement. Use of either the Software or Documentation or both constitutes agreement by the Government that the Software and Documentation are "commercial computer software" and "commercial computer software documentation," and constitutes acceptance of the rights and restrictions herein."
echo " "
echo "6. Term And Termination"
echo " "
echo "You may terminate this Agreement at any time, and it will automatically terminate if you fail to comply with it. If terminated, you must immediately destroy the Documentation and the Software and all copies you have made."
echo " "
echo "7. Audit Rights"
echo " "
echo "LSI shall have the right on reasonable notice, at its own cost and no more than once per year, directly or through its independent auditors, to inspect, examine, take extracts, and make copies from, your records to the extent reasonably necessary to verify your compliance with the terms and conditions of this Agreement. This right shall apply during the term of this Agreement and for one (1) year thereafter."
echo " "
echo "8. Export"
echo " "
echo "You may not export this Software or Documentation, unless you have complied with applicable United States and foreign government laws."
echo " "
echo "9. General"
echo " "
echo "You assume full responsibility for the legal and responsible use of the Software and Documentation. You agree that this Agreement is the complete agreement between you and LSI (and that any verbal or written statements that are not reflected in this Agreement and any prior agreements, are superseded by this Agreement). To be effective, any amendment of this Agreement must be in writing and signed by both you and LSI. Should any provisions of this Agreement be held to be unenforceable, then such provision shall be separable from this Agreement and shall not affect the remainder of the Agreement. This Agreement shall be governed by California law, not including its choice of law provisions. The United Nations Convention on the International Sale of Goods shall not be applied to this Agreement. All rights in the Software and Documentation not specifically granted in this Agreement are reserved by LSI or its licensors. The English language version of this Agreement shall be the official version. The terms and conditions of this Software License Agreement shall be binding upon you and your respective heirs, successors and assigns."
echo " "
echo "10. Survival"
echo " "
echo "The provisions of Sections 2, 3, 4, 7, 8 and 9 shall survive any termination of this Agreement."
echo " "
echo " "
echo " "

read -p "Press Y to accept the License Agreement :" EULA
if [ "$EULA" != "y" ]
then
if [ "$EULA" != "Y" ]
then
  echo "EULA declined by User. Exiting installation..."
  exit;
fi
fi
fi
firstArgDone="0"
nginx_port="0"
LSA_port="0"
setupstate="1"
if [ "$requireSetupType" -eq 1 ]
then
clear

echo
echo "Please make a selection to configure LSA range of events used to generate alert notifications if LSA cannot find Last Processed Sequence Number"
echo "Press 0 to exit from installation State"
echo "Choose[1-4]:"
echo "            1. - Since Last Shutdown"
echo "                  LSI Storage Authority will generate alerts from events since last clean shutdown"
echo "            2. - Since Log Clear"
echo "                  LSI Storage Authority will generate alerts from events since last log clear"
echo "            3. - Since Last Reboot"
echo "                  LSI Storage Authority will generate alerts from events since last reboot"
echo "            4. - Start from Now"
echo "                  LSI Storage Authority will generate alerts from events now onwards"

read -p "Setup State :" setupstate
echo $setupstate
if [ "$setupstate" -lt 0 -o  "$setupstate" -gt 4 ]
then
        echo "Incorrect option selected..."
        echo "Choose[1-4]:"
        echo "            1. - Since Last Shutdown"
        echo "                  LSI Storage Authority will generate alerts from events since last clean shutdown"
        echo "            2. - Since Log Clear"
        echo "                  LSI Storage Authority will generate alerts from events since last log clear"
        echo "            3. - Since Last Reboot"
        echo "                  LSI Storage Authority will generate alerts from events since last reboot"
        echo "            4. - Start from Now"
        echo "                  LSI Storage Authority will generate alerts from events now onwards"

        read -p "" setupstate
fi

case "$setupstate" in
	"1")
		echo -n "LSA will generate alerts from events since last clean shutdown"
		set setupstate="1"
		;;
	"2")
		echo -n "LSA will generate alerts from events since last log clear"
		set setupstate="2"
		;;
	"3")
		echo -n "LSA will generate alerts from events since last reboot"
		set setupstate="3"
		;;
	"4")
		echo -n "LSA will generate alerts from events now onwards"
		set setupstate="4"
		;;
	"0")
                echo -n "Exiting Installation"
                echo
                exit
                ;;
	*)
        echo "Incorrect option selected."
		echo "Choose[1-4]:"
		echo "    1. - Since Last Shutdown"
		echo "                  LSI Storage Authority will generate alerts from events since last clean shutdown"
		echo "    2. - Since Log Clear"
		echo "                  LSI Storage Authority will generate alerts from events since last log clear"
		echo "    3. - Since Last Reboot"
		echo "                  LSI Storage Authority will generate alerts from events since last reboot"
		echo "    4. - Start from Now"
		echo "                  LSI Storage Authority will generate alerts from events now onwards"
                exit
		;;
esac

echo " "
echo "Press 0 to exit from installation"
echo "Choose[1-4]:"
echo "            1. - Gateway"
echo "                  All program features will be installed. 'Requires the most disk space.'"
echo "            2. - StandAlone"
echo "                  This option will install components required for Local Server Management"
echo "            3. - DirectAgent"
echo "                  This option will install components required for Remote Server Management"
echo "            4. - Light Weight Monitor"
echo "                  Light Weight Monitor program features will be installed."
echo "Note : Installer can also be run in a command line mode"
echo "Usage : install.sh [-option]"
echo "The options are :"
echo "              g"
echo "                Gateway Installation of LSIStorageAuthority "
echo "              s"
echo "                StandAlone Installation of LSIStorageAuthority"
echo "              d"
echo "                DirectAgent Installation of LSIStorageAuthority "
echo "              l"
echo "                Light Weight Monitor Installation of LSIStorageAuthority"
read -p "Setup Type :" setuptype

if [ "$setuptype" -lt 0 -o  "$setuptype" -gt 4 ]
then
        echo "Incorrect option selected..."
        echo "Choose[1-4]:"
        echo "            1. - Gateway"
        echo "                  All program features will be installed. 'Requires the most disk space.'"
        echo "            2. - StandAlone"
        echo "                  This option will install components required for Local Server Management"
        echo "            3. - DirectAgent"
        echo "                  This option will install components required for Remote Server Management"
        echo "            4. - Light Weight Monitor"
        echo "                  Light Weight Monitor program features will be installed."

        read -p "" setuptype
fi

case $setuptype in
	"1")
		echo -n "Starting Gateway installation of LSIStorageAuthority"
                echo " "
		setuptype="g"
		setupmode="INTERACTIVE"
		;;
	"2")
		echo -n "Starting StandAlone installation of LSIStorageAuthority"
                echo " "
		setuptype="s"
		setupmode="INTERACTIVE"
		;;
	"3")
		echo -n "Starting DirectAgent installation of LSIStorageAuthority"
                echo " "
		setuptype="d"
		setupmode="INTERACTIVE"
		;;
	"4")
		echo -n "Starting Light Weight Monitor installation of LSIStorageAuthority"
                echo " "
		setuptype="l"
		setupmode="INTERACTIVE"
		;;
	"0")
		echo -n "Exiting Installation"
		echo " "
		exit
		;;
	*)
                echo "Incorrect option selected..."
		echo "Choose[1-4]:"
		echo "            1. - Gateway"
		echo "                  All program features will be installed. 'Requires the most disk space.'"
		echo "            2. - StandAlone"
		echo "                  This option will install components required for Local Server Management"
		echo "            3. - DirectAgent"
		echo "                  This option will install components required for Remote Server Management"
		echo "            4. - Light Weight Monitor"
		echo "                  Light Weight Monitor program features will be installed."
                exit
		;;
esac

else
case $1 in
	"-g")
		setuptype="1"
		firstArgDone="1"
		setuptype="g"
		setupmode="SILENT"
		setupstate=1
		;;
	"-s")
		setuptype="2"
		firstArgDone="1"
		setuptype="s"
		setupmode="SILENT"
		setupstate=1
		;;
	"-d")
		setuptype="3"
		firstArgDone="1"
		setuptype="d"
		setupmode="SILENT"
		setupstate=1
		;;
	"-l")
		setuptype="4"
		firstArgDone="1"
		setuptype="l"
		setupmode="SILENT"
		setupstate=1
		;;
	 *)
		echo "Incorrect option selected..."
		echo "Usage : install.sh [-option]"
		echo "The options are :"
		echo "              g"
		echo "                GatewayInstallation of LSIStorageAuthority"
		echo "              s"
		echo "                StandAlone Installation of LSIStorageAuthority"
		echo "              d"
		echo "                DirectAgent Installation of LSIStorageAuthority"
		echo "              l"
		echo "                Light Weight Monitor Installation of LSIStorageAuthority"
		echo " "
	        echo "Exiting installation."	
		exit
esac
nginx_port="$2"
LSA_port="$3"
setupstate="$4"

fi

export setuptype=$setuptype
export setupmode=$setupmode
export nginx_port=$nginx_port
export LSA_port=$LSA_port
export setupstate=$setupstate

./RunDEB.sh
