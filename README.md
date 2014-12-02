# **Bitfication**

**Bitfication** is a fully functional, Open Source, Bitcoin Exchange. It powers the Exchange `bitfication.com`, a CryptoCurrency Trading Platform.

Features:

- Written in Ruby on Rails

- Powered by Ubuntu

- Fully localizable

- Multi-currency (under development)

## Installation on top of Ubuntu 14.04.1 LTS

You must have, at least, one Ubuntu 14.04.1 Server, fresh installed. Can be the `Minimum Virtual Machine` flavor, option `F4` at Ubuntu's ISO Boot Menu.

For a Production Environment, you might want to split the services, each one deployed on its own Ubuntu Instance. Like for example:

- Public Apache (forbid /admin and cronjobs);

- Private Apache (allow /admin + cronjobs);

- Bitcoin Daemon;

- MySQL.

The following commands must be executed as `root` user, change to another user only when required.

* Install the following packages:

        apt-get install git acpid tmux ruby rails bundler capistrano ruby-mysql2 ruby-addressable ruby-coffee-rails ruby-will-paginate ruby-mocha ruby-execjs ruby-factory-girl-rails ruby-recaptcha ruby-sprockets ruby-uglifier ruby-bcrypt imagemagick memcached curl vim postfix apache2 libapache2-mod-passenger mysql-client mysql-server build-essential apache2-dev libqrencode-dev libcurl4-gnutls-dev libmysqlclient-dev software-properties-common

## Install Bitcoin Daemon

Complete procedure to install Bitfication's Bitcoin Hot Wallet.

* Add Bitcoin's Ubuntu Oficial PPA Repository:

        add-apt-repository ppa:bitcoin/bitcoin

* Updating Ubuntu:

        apt-get update

* Install Bitcoin Daemon:

        apt-get install bitcoind

* Create the Bitcoin Deamon Runtime User:

        adduser bitcoin

* Now, run the `bitcoind` logged as user `bitcoin`, like this:

        su - bitcoin

        bitcoind

There is a Bitcoin Daemon configuration example located at the file: `bitfication/misc/bitcoin.conf`. You'll need to copy it to: `~bitcoin/.bitcoin/bitcoin.conf`.

### Preparing your environment

### Create a regular user to host/run Bitfication

We'll use the `webapp` user and it'll be added to `sudo` group temporarily, this way, all the required packages to run **Bitfication**, will get installed on your Ubuntu, then, you can remove it from `sudo` group.

* Add `webuser` runtime user:

        adduser webapp

        adduser webapp sudo

### Become 'webapp' and get the code

* From `root` user, become `webapp` runtime user:

        su - webapp

* Clone **Bitficaion's** source code anonymously with git:

        git clone https://github.com/tmartinx/bitfication.git

* Or, if you have a Github account (and if you forked the code):

        git clone https://tmartinx@github.com/tmartinx/bitfication.git

* Enter **Bitfication's** directory:

        cd ~/bitfication

* Compile and install the required dependencies (You'll need `webapp's` password):

        bundle install

* Listing installed gem packages:

        gem list --all

* Remove `webapp` from `sudo` group (return to `root` user):

        logout

        deluser webapp sudo

### Development environment

#### Create your MySQL Database

* Log-in to MySQL console:

        mysql -u root -p
 
* and run the following commands:

        CREATE DATABASE bitficdevdb;
        GRANT ALL PRIVILEGES ON bitficdevdb.* TO 'bitficdevusr'@'localhost' IDENTIFIED BY 'bitficpass';
        FLUSH PRIVILEGES;
        QUIT;

#### Populate the database

You'll need to run a rake task to populate the database.

* From `root` user, become `webapp` runtime user:

        su - webapp

* Enter **Bitfication's** directory again:

        cd ~/bitfication

* and run:

        RAILS_ENV=development rake db:setup
        
*NOTE: You can omit the `RAILS_ENV` option if you're setting up a development environment, Rails will grab the database configuration from the `config/database.yml` file under the right section (development, test, or production.*
        
#### Configure access to the Bitcoin Hot Wallet

If you have used the Bitcoin Daemon configuration example (`bitcoin.conf`), then, you're ready to go. Just starts up `bitcoind`. Otherwise, edit the `config/bitcoin.yml` file and configure it according, so, **Bitfication** can have access to its Bitcoin Hot Wallet.

#### Start Up Bitfication!

* You're ready to go! Run the rails server:

        RAILS_ENV=development rails s

Your `Bitcoin Exchange` should now be running at: `http://localhost:3000/`!

### Production environment

#### Create your MySQL Database

* Log-in to MySQL console:

        mysql -u root -p
 
* and run the following commands:

        CREATE DATABASE bitficproddb;
        GRANT ALL PRIVILEGES ON bitficproddb.* TO 'bitficprodusr'@'localhost' IDENTIFIED BY 'bitficpass';
        FLUSH PRIVILEGES;
        QUIT;

#### Populate the database

Run the following rake task to populate the database.

* From `root` user, become `webapp` runtime user:

        su - webapp

* Enter **Bitfication's** directory:

        cd ~/bitfication

* Compile and install the required dependencies (You'll need `webapp's` password):

        bundle install

* and run:

        RAILS_ENV=production rake db:setup

#### Precompile assets

* Still within ~/bitfication directory, run:

        RAILS_ENV=production bundle exec rake assets:precompile

#### Configure access to the Bitcoin Hot Wallet

If you have used the Bitcoin Daemon configuration example (`bitcoin.conf`), then, you're ready to go. Just starts up `bitcoind`. Otherwise, edit the `config/bitcoin.yml` file and configure it according, so, **Bitfication** can have access to its Bitcoin Hot Wallet.

#### Start Up Bitfication!

* You're ready to go! Run the rails server:

        RAILS_ENV=production rails s

Your `Bitcoin Exchange` should now be running at: `http://localhost:3000/`!

*Note 1: To run Bitficaion in a production environment, we recommend running it under Apache2 with Passenger.*

*NOTE 2: If you don't want Apache2 for running your Production Environment, you might want to disable SSL, by editting `bitfication/config/environments/production.rb` and set `config.force_ssl` to `false`.*

#### Configure the Apache2 Virtual Host for you Bitcoin Exchange

* Enable the following Apache modules:

        a2enmod passender

        a2enmod ssl

        a2enmod rewrite

* Download Apache's files:

        cd /etc/apache2/sites-available
    
        wget https://github.com/tmartinx/bitfication/misc/apache2/sites-available/bitfication.com
    
        wget https://github.com/tmartinx/bitfication/misc/apache2/sites-available/bitfication.com-ssl

* Activate Virtual Hosts:

        a2ensite bitfication.com

        a2ensite bitfication.com-ssl

*NOTE: You'might want to disable the Ubuntu's Default Apache2 Test Page, if yes, just remove the file: `/etc/apache2/sites-enabled/000-default` and you're done.*

##### Creating your Self-Signed SSL Certificate

Here are some instructions to create the required SSL Certificates for running your Exchange more safely.

* Self-signing your SSL Certificate:

        mkdir /etc/apache2/ssl

        openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/apache2/ssl/apache.key -out /etc/apache2/ssl/apache.crt

* Then, restart Apache:

        service apache2 restart

That's it! Your `Bitcoin Exchange` should now be running at: `http://bitfication.com`! Or at your own domain, of course...

#### Configure the cronjobs

From time to time, you'll need to run a few tasks.

Those tasks does:

- Syncronization of User's Bitcoin Transactions;
- Update the Navbar's Status;
- User's E-Mail notifications.

* To use it, as `webapp` user, do the following:

        cd ~ ; mkdir bin ; cd ~/bin

        wget https://github.com/tmartinx/bitfication/misc/cronjobs/bitcoin-synchronize-transactions.sh

        wget https://github.com/tmartinx/bitfication/misc/cronjobs/bitfication-stats.sh

        wget https://github.com/tmartinx/bitfication/misc/cronjobs/notification-trades.sh

* Then, configure `webapp's` cronjobs by running `crontab -e` and then, copy and paste this:

        */7 * * * * /home/webapp/bin/bitcoin-synchronize-transactions.sh
        */5 * * * * /home/webapp/bin/bitfication-stats.sh
        */3 * * * * /home/webapp/bin/notification-trades.sh

*NOTE: You might want to test each cronjob before enabling it.*

#### Configure Postfix

The Ubuntu Instance that will run the cronjobs, will also need to send e-mails, so, just configure your Postfix, probably, you might want to make use of an external SMTP, to send e-mails to the Internet (i.e., this will be just a "satellite" SMTP).

* Reconfiguring Postfix

        sudo dpkg-reconfigure postfix

*NOTE: If you don't know the answers, you might just hit "enter" to accept the defaults.*

# Production deployment (obsolete/unused/optional procedure)

Usually, Rails applications are deployed in production using nginx or Apache, I'll introduce the Apache option.

The `capistrano` tool is used to automate pretty much every deployment step. Deploying a new version is as easy as typing `cap deploy` in your local command prompt.

To use the `cap` sweetness a couple of extra steps are required : 

* You'll need to fork the project since all your deployment configuration is stored in `config/deploy.rb`, these configs are pulled directly from GitHub when deploying, so go for it, change them to suit your needs.

* Set the remote machine up by typing `cap deploy:setup`

* Log in to the remote machine and create the production configuration files in `{APP PATH}/shared/config/*.yml`, they will be used in production (you don't want your production passwords hanging around on GitHub do you ?)

* Create the remote DB

* Now you can run locally `cap deploy:migrations`, this will update the remote sources and run the migrations on the remote database

* Now you just need to install the `passenger` gem on the remote server which will install an apache module

* Create an apache virtual host and you're good to go.

You'll just need to issue a `cap deploy` locally for any subsequent deployment.

# Contributions

All are welcome, improvements, fixes and translations (the string extraction bounty has been paid).

 * The use of the `Numeric#to_f` method is big no-no, every single numeric that passes through the code should be typed as `BigDecimal`,

 * Bugfixes should include a failing test,

 * Pull requests should apply cleanly on top of `master`, rebase if necessary

# Updates since the fork

First, we worked to update the code to make it work with the latest Ruby on Rails versions, including gem packages (i.e., by upgrading Gemfile packages version and the code itself).

We started working privately on BitBucket but, it is time to go back to Github. No reason to keep it private for any longer.

# License

AGPLv3 License - Copyright 2013-2014 Thiago Martins

Original Author - David FRANCOIS
