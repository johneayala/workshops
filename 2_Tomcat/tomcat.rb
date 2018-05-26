#
# Install OpenJDK 7
package 'java-1.7.0-openjdk-devel'

# Create group & user for tomcat
group 'tomcat'

user 'tomcat_user' do
  manage_home false
  shell '/bin/nologin'
  gid 'tomcat'
  home '/opt/tomcat'
  username 'tomcat'
  action :create
end

# Download tomcat binaries to /tmp
remote_file '/tmp/apache-tomcat-8-latest.tar.gz' do
  source 'https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz'
end

# Extract tomcat binaries in /opt/tomcat
directory '/opt/tomcat'

execute 'extract_tomcat' do
  command '/bin/tar zxf /tmp/apache-tomcat-8-latest.tar.gz --strip-components=1'
  cwd '/opt/tomcat'
  not_if { File.exists?("/opt/tomcat/lib/catalina.jar") }
end

execute 'tomcat_dir_group' do
  command '/bin/chgrp -R tomcat /opt/tomcat'
  only_if { File.exists?("/opt/tomcat") }
end

execute 'tomcat_conf_read' do
  command '/bin/chmod -R g+r /opt/tomcat/conf'
  only_if { File.exists?("/opt/tomcat/conf/catalina.properties") }
end

execute 'tomcat_conf_dir' do
  command '/bin/chmod g+x /opt/tomcat/conf'
  only_if { File.exists?("/opt/tomcat/conf") }
end

%w{webapps work temp logs}.each do |subdir|
  sdname = "/opt/tomcat/#{subdir}"
  execute subdir do
    command "/bin/chown -R tomcat #{sdname}"
#    only_if { File.exists?("/opt/tomcat/conf") }
  end
end



