execute "get wordpress" do
    #command "curl -o /tmp/wordpress.zip https://wordpress.org/latest.zip"
    # SPVH DESCARGAMOS LA ULTIMA VERSION DE WORDPRESS EN ESPAÑOL
    command "curl -o /tmp/wordpress.zip https://es.wordpress.org/latest-es_ES.zip"
    action :run
    not_if { ::File.exist?('/tmp/wordpress.zip') }
end

execute "extract_wordpress" do
    command "unzip -q /tmp/wordpress.zip -d /opt/"
    action :run
    notifies :run, 'execute[set_wordpress_permissions]', :immediately
    not_if { ::File.exist?('/opt/wordpress') }
end

execute "set_wordpress_permissions" do
    command "chown -R www-data:www-data /opt/wordpress"
    action :nothing
end

template '/opt/wordpress/wp-config.php' do
    source 'wp-config.php.erb'
    owner 'www-data'
    group 'www-data'
    mode '0644'
    not_if { ::File.exist?('/opt/wordpress/wp-config.php') }
end

template '/etc/apache2/sites-enabled/wordpress.conf' do
    source 'wordpress.conf.erb'
    not_if { ::File.exist?('/etc/apache2/sites-enabled/wordpress.conf') }
end

service "apache2" do
    action :restart
end