#!/usr/bin/env bash
modules_dir=$(dirname $0)/../modules
cd ${modules_dir}/../..
project_dir=$(pwd)

if [ ! -e /usr/bin/puppet ]; then
    source /etc/lsb-release
    wget https://apt.puppetlabs.com/puppetlabs-release-$DISTRIB_CODENAME.deb
    sudo dpkg -i puppetlabs-release-$DISTRIB_CODENAME.deb
    rm puppetlabs-release-$DISTRIB_CODENAME.deb
    sudo apt-get update
    sudo apt-get install -y -f puppet git
    if [ ! -d "/etc/puppet/environments" ]; then
        sudo mkdir /etc/puppet/environments;
    fi
    sudo chgrp puppet /etc/puppet/environments
    sudo chmod 2775 /etc/puppet/environments
    echo '
    START=yes
    DAEMON_OPTS=""
    ' | sudo tee --append /etc/default/puppet
    sudo service puppet start
else
    #echo 1;
    sudo apt-get update
fi;

if [ ! -e /www ]; then
    sudo mkdir /www/
    sudo chmod 755 /www/
    sudo chown www-data:www-data /www/
    sudo mkdir -p /var/www/.ssh
    sudo chown -Rf www-data:www-data /var/www/
fi;

sudo puppet module install --force puppetlabs/stdlib --target-dir ${modules_dir}
sudo puppet module install --force puppetlabs/apt --target-dir ${modules_dir}
sudo puppet module install --force maestrodev/wget --target-dir ${modules_dir}
sudo puppet module install --force willdurand/composer --target-dir ${modules_dir}
sudo puppet module install --force jfryman-nginx --target-dir ${modules_dir}
sudo puppet module install --force saz-timezone --target-dir ${modules_dir}
sudo puppet module install --force saz-locales --target-dir ${modules_dir}

sudo FACTER_project_dir="${project_dir}" puppet apply --modulepath ${modules_dir} ${modules_dir}/../general/manifests/init.pp