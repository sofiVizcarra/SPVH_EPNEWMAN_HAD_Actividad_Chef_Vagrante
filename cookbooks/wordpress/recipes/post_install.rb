# Instalar WP CLI
remote_file '/tmp/wp' do
  source 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Mover WP CLI a /bin
execute 'Move WP CLI' do
  command 'mv /tmp/wp /bin/wp'
  not_if { ::File.exist?('/bin/wp') }
end

# Hacer WP CLI ejecutable
file '/bin/wp' do
  mode '0755'
end

# Instalar Wordpress y configurar
# SPVH SOLO SE CAMBIA LA DESCRIPCION
# SE UTILIZA VARIABLE DE ENTORNO PARA url y admin_user
execute 'Finish Wordpress installation' do
  command 'sudo -u vagrant -i -- wp core install --path=/opt/wordpress/ --url="#{ENV["PROXY_IP"]}" --title="EPNEWMAN - Herramientas de automatización de despliegue - SPVH Se logro mostrar las imagenes y pagina en español :)" --admin_user="#{ENV["ADM_USR"]}" --admin_password="Epnewman123" --admin_email=admin@epnewman.edu.pe'
  not_if 'wp core is-installed', environment: { 'PATH' => '/bin:/usr/bin:/usr/local/bin' }
end

