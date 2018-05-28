#
# Install OpenJDK 7
case node['platform_family']
when 'rhel'
  package %w(java-1.7.0-openjdk-devel curl) do
  end

when 'debian'
  apt_repository 'openjdk_all' do
    uri 'ppa:openjdk-r/ppa'
    components ['main']
end
  apt_package %w(openjdk-7-jdk curl) do
  end
end

# Create group & user for tomcat
group 'tomcat' do
end

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
directory '/opt/tomcat' do
end

# Extract tomcat binaries into /opt/tomcat
execute 'extract_tomcat' do
  command '/bin/tar zxf /tmp/apache-tomcat-8-latest.tar.gz --strip-components=1'
  cwd '/opt/tomcat'
  not_if { File.exists?("/opt/tomcat/lib/catalina.jar") }
end

# Set permissions & ownership for tomcat user/group in tomcat binaries dirs/files
execute 'tomcat_dir_group' do
  command '/bin/chgrp -R tomcat /opt/tomcat'
  only_if { Dir.exists?("/opt/tomcat") }
end

execute 'tomcat_conf_read' do
  command '/bin/chmod -R g+r /opt/tomcat/conf'
  only_if { Dir.exists?("/opt/tomcat/conf") }
  notifies :run, 'execute[tomcat_conf_dir]', :immediately 
end

execute 'tomcat_conf_dir' do
  command '/bin/chmod g+x /opt/tomcat/conf'
  action :nothing
end

%w{webapps work temp logs}.each do |subdir|
  sdname = "/opt/tomcat/#{subdir}"
  execute subdir do
    command "/bin/chown -R tomcat #{sdname}"
    only_if { Dir.exists?("#{sdname}") }
  end
end

# Install Systemd unit file & trigger reload of systemd-daemon
case node['platform_family']
when 'rhel'
  systemd_unit 'tomcat.service' do
    content <<-EOU.gsub(/^\s+\|/, '')
    |[Unit]
    |Description=Apache Tomcat Web Application Container
    |After=syslog.target network.target
    |
    |[Service]
    |Type=forking
    |
    |Environment=JAVA_HOME=/usr/lib/jvm/jre
    |Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
    |Environment=CATALINA_HOME=/opt/tomcat
    |Environment=CATALINA_BASE=/opt/tomcat
    |Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
    |Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
    |
    |ExecStart=/opt/tomcat/bin/startup.sh
    |ExecStop=/bin/kill -15 $MAINPID
    | 
    |User=tomcat
    |Group=tomcat
    |UMask=0007
    |RestartSec=10
    |Restart=always
    |
    |[Install]
    |WantedBy=multi-user.target
    |
    EOU
    action :create
    triggers_reload true
  end

when 'debian'
  systemd_unit 'tomcat.service' do
    content <<-EOU.gsub(/^\s+\|/, '')
    |[Unit]
    |Description=Apache Tomcat Web Application Container
    |After=syslog.target network.target
    |
    |[Service]
    |Type=forking
    |
    |Environment=JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre
    |Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
    |Environment=CATALINA_HOME=/opt/tomcat
    |Environment=CATALINA_BASE=/opt/tomcat
    |Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
    |Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'
    |
    |ExecStart=/opt/tomcat/bin/startup.sh
    |ExecStop=/bin/kill -15 $MAINPID
    | 
    |User=tomcat
    |Group=tomcat
    |UMask=0007
    |RestartSec=10
    |Restart=always
    |
    |[Install]
    |WantedBy=multi-user.target
    |
    EOU
    action :create
    triggers_reload true
  end
end


# Start and enable tomcat service
service 'tomcat' do
  action [ :enable, :start ]
  notifies :run, 'execute[startup_sleep]', :immediately
end

# Adding sleep for tomcat service startup time
execute 'startup_sleep' do
  command '/bin/sleep 3'
  action :nothing
end

# Run curl to verify tomcat is running
execute 'check_tomcat' do
  command '/usr/bin/curl http://localhost:8080'
end

