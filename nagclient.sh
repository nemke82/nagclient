#!/bin/bash
#Author: Nemanja Djuric

#Function defs
# Check for root, quit if not present with a warning.
	if [ "$(id -u)" != "0" ];
	then
		echo "\nScript needs to be run as root. Please elevate and run again!"
		exit 1
	else
		echo "\nScript running as root. Starting..."
	fi

function setup_centos(){

#Begin of Epel-repo install block. Version check and if exist.
echo "Welcome to the Nagios Client installer. First, lets check if installation exist and remove it."
yum -y remove nagios-plugins-all
yum -y remove nrpe
yum -y remove lm_sensors

echo "Installing fresh installation"
osversion=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+'|cut -d"." -f1)
echo ${osversion}

if [ ${osversion} -eq 5 ];then
echo "Checking/Installing Epel repository, Nagios Plugins, Nrpe, Lmsensors and Hdd temperateure module."
echo "Starting nrpe daemon and adding it to the chkconfig for autoboot functionality."
cd /root
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-5.noarch.rpm
rpm -Uvh epel-release-latest-5*.rpm
yum -y --enablerepo="epel" install nagios-plugins-all nrpe lm_sensors hddtemp
service nrpe restart
chkconfig nrpe on
fi

if [ ${osversion} -eq 6 ];then
echo "Checking/Installing Epel repository, Nagios Plugins, Nrpe, Lmsensors and Hdd temperateure module."
echo "Starting nrpe daemon and adding it to the chkconfig for autoboot functionality."
cd /root
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
rpm -Uvh epel-release-latest-6*.rpm
yum -y --enablerepo="epel" install nagios-plugins-all nrpe lm_sensors hddtemp
service nrpe restart
chkconfig nrpe on
fi

if [ ${osversion} -eq 7 ];then
echo "Checking/Installing Epel repository CentOS 7, Nagios Plugins, Nrpe, Lmsensors and Hdd temperateure module."
echo "Starting nrpe daemon and adding it to the chkconfig for autoboot functionality."
cd /root
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh epel-release-latest-7*.rpm
yum -y --enablerepo="epel" install nagios-plugins-all nrpe lm_sensors hddtemp
systemctl restart nrpe
systemctl enable nrpe
echo "NOTE: On few CentOS 7 version's I've noticed that PID in nrpe.cfg needs to be changed from /var/run/nrpe.pid to /var/run/nrpe/nrpe.pid"
echo "      Make sure to check systemctl status nrpe when this is installed to check if daemon is started properly."
else
echo "ERROR: Unknown OS Version detected. Aborting Install "
fi

if [ ${osversion} -eq 8 ];then
echo "Checking/Installing Epel repository CentOS 8, Nagios Plugins, Nrpe, Lmsensors and Hdd temperateure module."
echo "Starting nrpe daemon and adding it to the chkconfig for autoboot functionality."
cd /root
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
rpm -Uvh epel-release-latest-8*.rpm
yum install dnf-plugins-core
yum config-manager --set-enabled powertools
dnf install perl-Import-Into
yum install perl-utf8-all
yum -y --enablerepo="epel" install nagios-plugins-all nrpe lm_sensors hddtemp
systemctl restart nrpe
systemctl enable nrpe
echo "NOTE: On few CentOS 8 version's I've noticed that PID in nrpe.cfg needs to be changed from /var/run/nrpe.pid to /var/run/nrpe/nrpe.pid"
echo "      Make sure to check systemctl status nrpe when this is installed to check if daemon is started properly."
else
echo "ERROR: Unknown OS Version detected. Aborting Install "
fi

#Configuration block
echo "NOTE: What type of server is this? KVM/XEN, OpenVZ or Dedicated?"
echo "Please enter type as (1 - cloud, 2 - vz or 3 - dedi):"
read stype

if [ ${stype} -eq 1 ];then
rm -f /etc/nagios/nrpe.cfg ;
echo "Getting nrpe.cfg file with installed commands.."
wget -O /etc/nagios/nrpe.cfg http://repo.nemanja.io/nrpe.cfg
echo "Complete!"
fi
if [ ${stype} -eq 2 ];then
rm -f /etc/nagios/nrpe.cfg ;
echo "Getting nrpe.cfg file with installed commands.."
wget -O /etc/nagios/nrpe.cfg http://repo.nemanja.io/nrpe-vz.cfg
echo "Complete!"
fi
if [ ${stype} -eq 3 ];then
rm -f /etc/nagios/nrpe.cfg ;
echo "Getting nrpe.cfg file with installed commands.."
wget -O /etc/nagios/nrpe.cfg http://repo.nemanja.io/nrpe-dedi.cfg &&
echo "Complete!"
fi

echo "Adding Nagios username to /etc/sudoers file with limited access only to /usr/lib64/nagios/plugins/ folder."
sed -i '$ a nagios ALL=(ALL) NOPASSWD: /usr/lib64/nagios/plugins/' /etc/sudoers ;
sed -i '$ a nrpe ALL=(ALL) NOPASSWD: /usr/lib64/nagios/plugins/' /etc/sudoers ;
echo "Complete!"

echo "Removing requiretty from /etc/sudoers.. Sudo and Nagios cannot work with this together."
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
echo "Complete!"

echo "Removing current plugins installed in /usr/lib64/nagios/plugins folder and installing ours."
rm -f /usr/lib64/nagios/plugins/* ;
wget -O /etc/nagios/plugins.tar http://repo.nemanja.io/plugins.tar ;
tar -xvf /etc/nagios/plugins.tar -C /usr/lib64/nagios/plugins
echo "Complete!"

echo "Restarting Nrpe Daemon..."
service nrpe stop || systemctl stop nrpe
service nrpe start || systemctl start nrpe
echo "Mission completed! You can review what commands are enabled in /etc/nagios/nrpe.cfg file."
echo "Thank you for using Nagios Client installer for CentOS/RHEL."

}

setup_ubuntu(){
echo "Welcome to the Nagios Client installer (for Debian/Ubuntu). First, lets check if installation exist and remove it."
if [ ! -d /etc/nagios ];then
apt-get -y remove nagios-nrpe-server ;
apt-get -y remove nagios-plugins ;
apt-get -y remove lm-sensors
else
echo "Checking/Installing Nagios Plugins, Nrpe, Lmsensors and Hdd temperateure module."
echo "Starting nrpe daemon."
apt-get -y install nagios-nrpe-server nagios-plugins lm-sensors unzip vim hddtemp ;
echo "Starting nrpe daemon."

fi

#Configuration block
echo "NOTE: What type of server is this? KVM/XEN, OpenVZ or Dedicated?"
echo "Please enter type as (1 - cloud, 2 - vz or 3 - dedi):"
read stype

if [ ${stype} -eq 1 ];then
rm -f /etc/nagios/nrpe.cfg ;
echo "Getting nrpe.cfg file with installed commands.."
wget -O /etc/nagios/nrpe.cfg http://repo.nemanja.io/nrpe.cfg
echo "Complete!"
fi
if [ ${stype} -eq 2 ];then
rm -f /etc/nagios/nrpe.cfg ;
echo "Getting nrpe.cfg file with installed commands.."
wget -O /etc/nagios/nrpe.cfg http://repo.nemanja.io/nrpe-vz.cfg
echo "Complete!"
fi
if [ ${stype} -eq 3 ];then
rm -f /etc/nagios/nrpe.cfg &&
echo "Getting nrpe.cfg file with installed commands.."
wget -O /etc/nagios/nrpe.cfg http://repo.nemanja.io/nrpe-dedi.cfg ;
echo "Complete!"
fi

echo "Adding Nagios username to /etc/sudoers file with limited access only to /usr/lib64/nagios/plugins/ folder."
sed -i '$ a nagios ALL=(ALL) NOPASSWD: /usr/lib64/nagios/plugins/' /etc/sudoers ;
echo "Complete!"

echo "Removing requiretty from /etc/sudoers.. Sudo and Nagios cannot work with this together."
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
echo "Complete!"

echo "Removing current plugins installed in /usr/lib64/nagios/plugins folder and installing ours."
rm -f /usr/lib64/nagios/plugins/* &&
wget -O /etc/nagios/plugins.tar http://repo.nemanja.io/plugins.tar ;
tar -xvf /etc/nagios/plugins.tar -C /usr/lib64/nagios/plugins
echo "Complete!"

echo "Restarting Nrpe Daemon..."
/etc/init.d/nagios-nrpe-server restart
echo "Complete!"

echo "Adding port 5666 to firewall"
ufw allow 5666/tcp
echo "Complete!"

echo "Mission completed! You can review what commands are enabled in /etc/nagios/nrpe.cfg file."
echo "Thank you for using Nagios Client installer for CentOS/RHEL."

}

auto_setup(){
read -p "Are you sure you want to continue? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
if [ -f /etc/redhat-release ]; then
setup_centos
fi

if [ -f /etc/lsb-release ]; then
setup_ubuntu
fi

else
  exit 0
fi
}

#End Function defs

if [ ! -z $1 ];then
	case $1 in
		centos)
			setup_centos
			;;
		ubuntu)
			setup_ubuntu
			;;
		*)
			auto_setup
			;;
	esac
else
	auto_setup
fi
