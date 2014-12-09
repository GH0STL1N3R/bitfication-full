<VirtualHost *:80>

        ServerAdmin webmaster@bitfication.com

        ServerName bitfication.com
        ServerAlias www.bitfication.com bitfication.com.br www.bitfication.com.br

        # Redirect http to https
        RewriteEngine On
        RewriteCond %{HTTPS} off
        RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI}

        ErrorLog ${APACHE_LOG_DIR}/bitfication.com-error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog ${APACHE_LOG_DIR}/bitfication.com-access.log combined

</VirtualHost>
