During operation, when our service was ignored to manage the resources of a highly loaded I/O controller, situations with 100% of its load on processors/ cores often began to arise.

    Stop the service: 

        sudo systemctl stop LsiSASH.service

    Deactivating the autorun of the service: 

        sudo systemctl disable LsiSASH.service

The nature of what is happening has yet to be studied. It was found that the impact of 100% CPU utilization of our service does not occur immediately, but after a certain long period of time. It turns out that it is possible to view the status, replace the disk, rebuild the RAID, i.e. transfer the necessary commands to the controller and disconnect after the right time, but the service cannot be left running on an ongoing basis, so as not to load the processor at 100%.

# Let's create a snap-in to automatically start our service, manage arrays, and stop the service on servers from the operator's workplace via a pseudographic GUI interface in bash

To do this, install the necessary packages.:

    sudo apt install dialog sshpass firefox

    where:
    dialog is a utility for building console interfaces; 
    sshpass is a utility for running ssh using password authentication mode in non—interactive mode.;
    firefox is a web browser.

# Create a bash script "lsacontrol.sh ", in which:

     We check whether the necessary auxiliary utilities are installed.

     We provide a list of servers with descriptions (change the context to your IP address and comments)

     We specify the password and username (it's not safe, rewrite this place)

     Let's create a function for checking the status of the LSA service

     We are preparing the menu for dialog (# Server selection dialog - play with the parameters "15 60 6" to make everything fit in)

     Initiating the server selection dialog

     Checking the server selection

     Next, we check the availability of the server

     When it is available, we run the LSA service on it.

     We are waiting for the launch of the LSA service (it needs to be made a separate function, I wrote earlier about the long launch of the service)

     Upon successful launch of the LSA service on the selected server, we launch Firefox with the IP address of the selected server and port :2464

     Tracking the pid of the previously launched Firefox window 

     After completing work with the controllers/arrays and closing the Firefox window, we send a command to the server to stop the service.

# Start management via ”lsacontrol.sh ”:

    admin@astra1$  sh ./lsacontrol.sh

![alt text](https://github.com/UAR-2020/LSA_for_Megaraid-Lsi-Avago-Broadcom_on_AstraLinux/blob/main/pseudogaraphics_GUI_dialog.png?raw=true)

**You should pay special attention to port 9000. It is used for internal exchange of LsiSASH service. We had a high-performance MinIO distributed object data warehouse (S3 compatibility) running on our servers on this port. The ss utility helped, which shows not only the ports, but also the process that occupied them. Reconfigured the MinIO to a different port. Other processes may also use it, take action. Read the file LSA_Linux_64_readme.txt - it specifies the installation modes and the ability to change the default ports (section "Installation Instructions").

#Zoom to display the dialog box.
Sometimes the dialog menu is duplicated and displayed below. To display correctly, you need to use a mouse-type manipulator to resize the window or scroll to change the font size in the window, in both cases individually increase or decrease them.

In any case, before using it, it is necessary to finalize all of the above according to the safety requirements of the environment where it will function.

Create a shortcut to easily launch our project.

    nano /home/admin/Desktop/LSA.desktop

    [Desktop Entry]
    Name=LSA_control
    Comment=cortrol raids
    GenericName=Megaraid, Lsi, Avago, Broadcom, LSA, RAID
    Keywords=raids
    Exec=sh /home/admin/LSA/lsacontrol.sh
    Terminal=true
    Type=Application
    Icon=/usr/share/icons/fly-astra/256x256/devices/raid.png
    Path=
    Categories=
    NoDisplay=false

![alt text](https://github.com/UAR-2020/LSA_for_Megaraid-Lsi-Avago-Broadcom_on_AstraLinux/blob/main/start_control.png?raw=true)

# For all emergency situations and malfunctions, it is necessary to return to the initial position of the "deactivated" and "stopped" service on the selected server:

    sudo systemctl disable LsiSASH.service
    sudo systemctl stop LsiSASH.service

Next, run the control via ”lsacontrol.sh ” (it is necessary to have sudo rights for individual commands):

    admin@astra1$ sh ./lsacontrol.sh

The need to assemble LSA packages from source, as the second method of solving the problem, will now be only in case of unsolvable malfunctions during operation. By coincidence, this solution, as a unified software, was tested and applied on the AstraLinux OS on versions 1.6, 1.7, 1.8 with a variety of cores.

To deploy LSA in the AstraLinux OS, a file with installation instructions is posted ”howtoinst.txt ” and prepared repackaged files.

# This solution can be applied to newer versions of LSA (https://www.broadcom.com/site-search?page=7&per_page=10&q=lsa ). 

Successful integration and operation