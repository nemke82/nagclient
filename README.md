# nagclient
Multi platform Nagios client Installer
<BR>
<BR>
NagClient is tool designed for anyone who wishes to easily deploy Nagios application, NRPE Daemon and some recommended plugins on different Linux platforms and Cloud/VZ systems. <BR>

For CentOS/RHEL application rely on EPEL. <BR>
EPEL (Extra Packages for Enterprise Linux) is open source and free community based repository project from Fedora team which provides 100% high quality add-on software packages for Linux distribution including RHEL (Red Hat Enterprise Linux), CentOS, and Scientific Linux. Epel project is not a part of RHEL/Cent OS but it is designed for major Linux distributions by providing lots of open source packages like networking, sys admin, programming, monitoring and so on. Most of the epel packages are maintained by Fedora repo.

Why we use EPEL repository?
Provides lots of open source packages to install via Yum.
Epel repo is 100% open source and free to use.
It does not provide any core duplicate packages and no compatibility issues.
All epel packages are maintained by Fedora repo.

Debian/Ubuntu Operating systems are using installed repositories who work just fine.

#How to use NagClient tool?

1) First clone it on your server by executing: <BR>
git clone https://github.com/nemke82/nagclient <BR>
make file executable: chmod a+rwx nagclient.sh <BR>
Next type: bash nagclient.sh <BR>

2) wget -c https://raw.githubusercontent.com/nemke82/nagclient/master/nagclient.sh
chmod a+rwx nagclient.sh
bash nagclient.sh <BR>

3) curl -s https://raw.githubusercontent.com/nemke82/nagclient/master/nagclient.sh | bash /dev/stdin

Hint: By default, application should recognize your Operating system and use auto_setup function.

You can use direct commands as :  

bash nagclient.sh centos
(For Installing on CentOS 6/7 RHEL OS)
<BR>

bash nagclient.sh ubuntu
(For Installing on Ubuntu/Debian OS)
