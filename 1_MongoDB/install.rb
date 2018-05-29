##########################################################################
# Cookbook Name:: mongodb
# Recipe:: install
#
# Not sure how to get started?
#
# You could:
# 1.  copy the relevant commands from http://docs.mongodb.org/manual/tutorial/install-mongodb-on-red-hat-centos-or-fedora-linux/
# 2.  comment out everything
# 3.  add the Chef resources and other Chef code necessary
#
# This file is an example of steps 1 and 2 above.
##########################################################################
#

# Create a /etc/yum.repos.d/mongodb.repo file to hold the following configuration information for the MongoDB repository:
#
# If you are running a 64-bit system, use the following configuration:
#
# [mongodb]
# name=MongoDB Repository
# baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/
# gpgcheck=0
# enabled=1
# If you are running a 32-bit system, which is not recommended for production deployments, use the following configuration:
#
# [mongodb]
# name=MongoDB Repository
# baseurl=http://downloads-distro.mongodb.org/repo/redhat/os/i686/
# gpgcheck=0
# enabled=1
#
# Install the MongoDB packages and associated tools.
#
# sudo yum install mongodb-org
#
#
# Start MongoDB.
#
# sudo service mongod start
#
# ensure that MongoDB will start following a system reboot by issuing the following command:
#
# sudo chkconfig mongod on#

case node['platform']
when 'redhat', 'centos'
  yum_repository 'mongodb' do
    description "MongoDB Repository"
    baseurl "http://downloads-distro.mongodb.org/repo/redhat/os/x86_64/"
    gpgcheck false
    enabled true
    action :create
  end

  package 'mongodb-org' do
  end

when 'ubuntu'
  execute 'repo_key' do
    command '/usr/bin/apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5'
  end
  
  file '/etc/apt/sources.list.d/mongodb_repo.list' do
    content 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse'
    mode '0644'
    owner 'root'
    group 'root'
    notifies :run, 'execute[apt_update]', :immediately
  end

  execute 'apt_update' do
    command 'apt update'
    action :nothing
  end

  apt_package 'mongodb-org' do
  end
end

service 'mongodb_service' do
  service_name 'mongod'
  action [:enable, :start]
end

