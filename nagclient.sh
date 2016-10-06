#!/bin/bash
#Author: Nemanja Djuric

#Function defs
setup_centos(){

echo "Welcome to the Nagios Client installer. First, lets check if installation exist and remove it."
if [ ! -d /etc/nagios ];then
yum -y remove nagios-plugins-all nrpe lm_sensors ;
else

#Begin of Epel-repo install block. Version check and if exist.
echo "Installing fresh installation"
osversion=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+'|cut -d"." -f1)
echo ${osversion}
if [ ${osversion} -eq 6 ];then
echo "Checking/Installing Epel repository, Nagios Plugins, Nrpe, Lmsensors and Hdd temperateure module."
echo "Starting nrpe daemon and adding it to the chkconfig for autoboot functionality."
yum -y install http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
yum -y --enablerepo="epel" install nagios-plugins-all nrpe lm_sensors hddtemp &&
service nrpe restart &&
chkconfig nrpe on &&
done
elif [ ${osversion} -eq 7 ];then
echo "Checking/Installing Epel repository CentOS 7, Nagios Plugins, Nrpe, Lmsensors and Hdd temperateure module."
echo "Starting nrpe daemon and adding it to the chkconfig for autoboot functionality."
yum -y install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
yum -y --enablerepo="epel" install nagios-plugins-all nrpe lm_sensors hddtemp &&
systemctl restart nrpe
systemctl enable nrpe
echo "NOTE: On few CentOS 7 version's I've noticed that PID in nrpe.cfg needs to be changed from /var/run/nrpe.pid to /var/run/nrpe/nrpe.pid"
echo "      Make sure to check systemctl status nrpe when this is installed to check if daemon is started properly."
done
else
echo "ERROR: Unknown OS Version detected. Aborting Install "
fi

#Configuration block
echo "NOTE: What type of server is this? KVM/XEN, OpenVZ or Dedicated?"
echo "Please enter type as (cloud, vz or dedi):"
read stype

if [ ${stype} -eq cloud ];then
rm -f /etc/nagios/nrpe.cfg &&
echo "Getting nrpe.cfg file with installed commands.."
wget -c http://repo.nemanja.io/nrpe.cfg /etc/nagios/nrpe.cfg &&
echo "Complete!"
done
elif [ ${stype} -eq vz ];then
rm -f /etc/nagios/nrpe.cfg &&
echo "Getting nrpe.cfg file with installed commands.."
wget -c http://repo.nemanja.io/nrpe-vz.cfg /etc/nagios/nrpe.cfg &&
echo "Complete!"
done
if [ ${stype} -eq dedi ];then
rm -f /etc/nagios/nrpe.cfg &&
echo "Getting nrpe.cfg file with installed commands.."
wget -c http://repo.nemanja.io/nrpe-dedi.cfg /etc/nagios/nrpe.cfg &&
echo "Complete!"
done

else
echo "Adding Nagios username to /etc/sudoers file with limited access only to /usr/lib64/nagios/plugins/ folder."
sed -i '$ a nagios ALL=(ALL) NOPASSWD: /usr/lib64/nagios/plugins/' /etc/sudoers &&
echo "Complete!"

echo "Removing requiretty from /etc/sudoers.. Sudo and Nagios cannot work with this together."
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
echo "Complete!"

service nrpe stop || systemctl stop nrpe &&
service nrpe start || systemctl start nrpe &&
		done
	}

setup_ubuntu(){
echo "Welcome to the Nagios Client installer (for Debian/Ubuntu). First, lets check if installation exist and remove it."
if [ ! -d /etc/nagios ];then
apt-get -y remove nagios-nrpe-server nagios-plugins lm-sensors ;
else
echo "Checking/Installing Nagios Plugins, Nrpe, Lmsensors and Hdd temperateure module."
echo "Starting nrpe daemon."
apt-get -y install nagios-nrpe-server nagios-plugins lm-sensors unzip vim hddtemp &&
echo "Starting nrpe daemon."
done

fi

#Configuration block
echo "NOTE: What type of server is this? KVM/XEN, OpenVZ or Dedicated?"
echo "Please enter type as (cloud, vz or dedi):"
read stype

if [ ${stype} -eq cloud ];then
rm -f /etc/nagios/nrpe.cfg &&
echo "Getting nrpe.cfg file with installed commands.."
wget -c http://repo.nemanja.io/nrpe.cfg /etc/nagios/nrpe.cfg &&
echo "Complete!"

echo "Adding Nagios username to /etc/sudoers file with limited access only to /usr/lib64/nagios/plugins/ folder."
sed -i '$ a nagios ALL=(ALL) NOPASSWD: /usr/lib64/nagios/plugins/' /etc/sudoers &&
echo "Complete!"

echo "Removing requiretty from /etc/sudoers.. Sudo and Nagios cannot work with this together."
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
echo "Complete!"

echo "Restarting nrpe daemon"
/etc/init.d/nagios-nrpe-server restart
echo "Complete!"

echo "Adding port 5666 to firewall"
ufw allow 5666/tcp
echo "Complete!"
		done
	}

auto_setup(){
if [ -f /etc/redhat-release ]; then
setup_centos
fi

if [ -f /etc/lsb-release ]; then
setup_ubuntu
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
