# Ejecución de las pruebas

## Pruebas unitarias

Las pruebas unitarias se pueden ejecutar tanto en un VM como en Docker, esto se debe a que el proceso es sólo validar que los comandos vana  producir una salida esperada.

Por ejemplo, en la receta de la base de datos tenemos el siguiente bloque:

```ruby
# Ejecutar comando para crear la base de datos
execute 'create_mysql_database' do
    command 'mysql -e "CREATE DATABASE wordpress;"'
    action :run
    not_if 'mysql -e "SHOW DATABASES;" | grep wordpress'
end

# Ejecutar comando para crear el usuario y otorgar permisos
execute 'create_mysql_user' do
    command "mysql -e \"CREATE USER '#{db_user}'@'#{wp_ip}' IDENTIFIED BY '#{db_pswd}'; GRANT ALL PRIVILEGES ON wordpress.* TO '#{db_user}'@'#{wp_ip}'; FLUSH PRIVILEGES;\""
    action :run
    not_if "mysql -e \"SELECT User, Host FROM mysql.user WHERE User = '#{db_user}' AND Host = '#{wp_ip}'\" | grep #{db_user}"
end
```

Entonces en el Spec escribiremos lo siguiente:

```ruby
describe 'database::default' do
    describe 'creates the wordpress database' do
        it { is_expected.to run_execute('create_mysql_database') }
    end

    describe 'creates the mysql user and grants privileges' do
        it { is_expected.to run_execute('create_mysql_user') }
    end
end
```

Lo que la prueba de Spec hará será verificar que la receta se pueda ejecutar, pero no va a instalar MySQL, por lo tanto esta prueba va a fallar pues no existirá una instancia de MySQl para crear una base de datos ni un usuario.

Entonces para que esta prueba pueda pasar vamos a simular la ejecución de esos comandos de la siguiente forma:

```ruby
    before do
        stub_command('mysql -e "SHOW DATABASES;" | grep wordpress').and_return(false)
        stub_command("mysql -e \"SELECT User, Host FROM mysql.user WHERE User = 'wordpress' AND Host = '127.0.0.1'\" | grep wordpress").and_return(false)
    end
```

En este caso debemos regresar `false` cuando se ejecuten estos comandos, la razón de esto es porque en la receta hay una instrucción `not_if`.
Es decir, el comando para crear la base de datos se va a ejecutar sólo cuando el comando `mysql -e "SHOW DATABASES;" | grep wordpress` regrese falso, o sea, sólo cuando no existe la base de datos.

La ejecución completa de las pruebas unitarias la podemos ver en la siguiente sección.

### Pruebas unitarias usando una VM

[![asciicast](https://asciinema.org/a/rqXjO2OeiBCV12044iJl0XBxg.svg)](https://asciinema.org/a/rqXjO2OeiBCV12044iJl0XBxg)

### Pruebas unitarias usando un contenedor

[![asciicast](https://asciinema.org/a/MjrEDuWIRFB9dXZkzF684621F.svg)](https://asciinema.org/a/MjrEDuWIRFB9dXZkzF684621F)

## Pruebas de integración e infraestructura

En este caso el proceso de pruebas sí va a levantar una máquina virtual e instalará las recetas.

Este proceso lo va a hacer varias veces, cuando ejecute las pruebas de integración y cuando ejecute las pruebas de infraestructura, es decir dos veces, una para cada prueba. Además lo hará por cada sistema operativo, es decir dos veces más.

Por eso estas pruebas son tardadas cuando se ejecutan en conjunto, y en especial en casos como este, donde tenemos varias máquinas virtuales para la solución completa.

El proceso completo de ejecución de estas pruebas se puede ver a continuación.

[![asciicast](https://asciinema.org/a/fLCVUL31ehyjkvRlQiFbZE7LE.svg)](https://asciinema.org/a/fLCVUL31ehyjkvRlQiFbZE7LE)
