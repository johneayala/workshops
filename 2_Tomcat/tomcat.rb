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

# Extract tomcat binaries in /top/tomcat
directory '/opt/tomcat'

execute 'extract_tomcat' do
  command '/bin/tar zxf /tmp/apache-tomcat-8-latest.tar.gz --strip-components=1'
  cwd '/opt/tomcat'
  not_if { File.exists?("/opt/tomcat/lib/catalina.jar") }
end

#directory 'tomcat_dir_group' do
#  group 'tomcat'
#  recursive true
#  path '/opt/tomcat'
#end

#directory 'tomcat_conf_mode' do
#  mode '0640'
#  recursive true
#  path '/opt/tomcat/conf'
#end

#directory 'tomcat_conf_dir' do
#  mode '0750'
#  path '/opt/tomcat/conf'
#end

#%w[ /opt/tomcat/webapps /opt/tomcat/work /opt/tomcat/temp /opt/tomcat/logs ].each do |tompath|
#  directory 'tompath' do
#    owner 'tomcat'
#    recursive true
#  end
#end


