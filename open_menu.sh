#!/bin/bash

#    _   _                 ____                             ___           _        _ _   ____            _       _   
#   | \ | | _____      __ / ___|  ___ _ ____   _____ _ __  |_ _|_ __  ___| |_ __ _| | | / ___|  ___ _ __(_)_ __ | |_ 
#   |  \| |/ _ \ \ /\ / / \___ \ / _ \ '__\ \ / / _ \ '__|  | || '_ \/ __| __/ _` | | | \___ \ / __| '__| | '_ \| __|
#   | |\  |  __/\ V  V /   ___) |  __/ |   \ V /  __/ |     | || | | \__ \ || (_| | | |  ___) | (__| |  | | |_) | |_ 
#   |_| \_|\___| \_/\_/   |____/ \___|_|    \_/ \___|_|    |___|_| |_|___/\__\__,_|_|_| |____/ \___|_|  |_| .__/ \__|
#                                                                                                         |_|        
# Author @MMilesMM

#variables
# Set the color variable
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
bg_red='\033[0;41m'
bg_green='\033[0;42m'
bg_yellow='\033[0;43m'
bg_blue='\033[0;44m'
bg_magenta='\033[0;45m'
bg_cyan='\033[0;46m'
# Clear the color after that
clear='\033[0m'

#Options
command 1> /dev/null #Show console output
clear #clears screen
#Function
function pause(){
   read -p "$*"
}

function display_menu() {
    echo "Menu for Installing Programs"
    echo "1. Install Apache2, PHP with common modules and MySQL Server"
    echo "2. Install certbot with cloudflare addon"
    echo "3. Download pre-made default config for apache2 (vhost, ssl extra)"
    echo "4. Edit SSH config to allow root ssh"
    echo "5. Install Wordpress"
    echo "6. Configure MySQL"
    echo "7. Install and configure PhPMyAdmin"
    echo "0. Exit"
}

# Option 1
function option_1() {
    echo "Installaling Apache, PHP and MySQL..."
    # Installation commands
    sudo apt update && sudo apt upgrade -y
    sudo apt install apache2 wget curl -y
    sudo apt install php libapache2-mod-php php-mysql
    sudo apt install php-{zip,curl,bcmath,cli,common,imap,intl,json,xml,imagick,dom,fileinfo,mbstring} -y
    sudo apt install mysql-server -y
    clear
    echo -e "${green}Apache,PHP and MySQL sccessfully installed! Returning to menu...${clear}"
}

# Option 2
function option_2() {
    echo "Installing certbot and snap"
    # Installation commands
    sudo apt install snapd curl wget -y
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    sudo snap set certbot trust-plugin-with-root=ok
    sudo snap install certbot-dns-cloudflare
    echo -e -n "${bg_blue}Would you like to configure cloudlfare now? y/n"
        echo -e -n "${clear}"
        read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        sudo mkdir -p /root/.secrets/certbot
        sudo wget -P /root/.secrets/certbot https://raw.githubusercontent.com/MMilesMM/New-Server-Installation-Script/main/files/cloudflare.ini
        sudo chmod 600 /root/.secrets/certbot/cloudflare.ini
        sudo nano /root/.secrets/certbot/cloudflare.ini
        echo -e "${green}Certbot with cloudflare config and snap installed successfully!${clear}"
        echo -e -n "${bg_blue}Would you like to create the certificates now? y/n"
        echo -e -n "${clear}"
        read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                echo -e -n "${bg_blue}Please enter the domain you would like to add: "
                echo -e -n "${clear}"
                read domain
                sudo certbot certonly \
                --dns-cloudflare \
                --dns-cloudflare-credentials /root/.secrets/certbot/cloudflare.ini \
                --dns-cloudflare-propagation-seconds 15 \
                -d $domain \
                -d *.$domain
                clear
                echo -e "${green}Cloudflare certificate installed and configured!${clear}"
            fi
    else
        clear
        echo -e "${green}Certbot and snap installed successfully!${clear}"
    fi
    
    
}

# Option 3
function option_3() {
    echo "Installing custom Apache2 config with SSL options"
   # Installation commands
   DIR=/etc/letsencrypt
if [ -d "$DIR" ];
then
    echo "$DIR directory exists."
    sudo apt install wget curl -y
    sudo a2enmod headers ssl rewrite actions
    sudo systemctl restart apache2
    sudo wget -O /etc/ssl/dhparams.pem https://raw.githubusercontent.com/MMilesMM/New-Server-Installation-Script/main/files/dhparams.pem
    sudo wget -O /etc/letsencrypt/options-ssl-apache.conf https://raw.githubusercontent.com/MMilesMM/New-Server-Installation-Script/main/files/options-ssl-apache.conf
    sudo wget -O /etc/apache2/conf-available/security.conf https://raw.githubusercontent.com/MMilesMM/New-Server-Installation-Script/main/files/security.conf
    sudo wget -O /etc/apache2/sites-available/default_vhost.conf https://raw.githubusercontent.com/MMilesMM/New-Server-Installation-Script/main/files/default_vhost.conf
    sudo a2enconf security.conf
    sudo systemctl restart apache2
    clear
    echo -e "${green}Apache config installed!${clear}"
    echo -e -n "${bg_blue}Would you like to edit the default config? y/n"
        echo -e -n "${clear}"
        read -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]
            then
                echo -e -n "${bg_blue}Please enter the name of the domain you'll add: "
                echo -e -n "${clear}"
                read apachedomain
                sudo mkdir -p /var/www/$apachedomain
                sudo chown -R www-data:www-data /var/www
                sudo cp /etc/apache2/sites-available/default_vhost.conf /etc/apache2/sites-available/$apachedomain.conf
                sudo nano /etc/apache2/sites-available/$apachedomain.conf
                echo -e "${bg_blue}Please edit the apache2 config and AllowOverride All for the /var/www directory${clear}"
                pause 'Press [Enter] key to continue...'
                sudo nano /etc/apache2/apache2.conf
                sudo a2ensite $apachedomain
                sudo systemctl reload apache2
                echo -e "${green}Domain added and apache reloaded!${clear}"
                echo -e -n "${bg_blue}Would you like to download the newest Wordpress install? y/n"
                echo -e -n "${clear}"
                read -n 1 -r
                echo
            fi
                    if [[ $REPLY =~ ^[Yy]$ ]]
                    then
                        WP=/var/www/$apachedomain
                        if [ -d "$WP" ];
                            then
                                echo -e -n "${bg_blue}Folder $WP already exists! Please remove the folder! Returning to main menu${clear}"
                                pause 'Press [Enter] key to continue...'
                            else
                                sudo apt install unzip -y
                                sudo wget -P /var/www/$apachedomain https://de.wordpress.org/latest-de_DE.zip
                                sudo unzip /var/www/$apachedomain/latest-de_DE.zip -d /var/www/$apachedomain
                                sudo mv /var/www/$apachedomain/wordpress/* /var/www/$apachedomain
                                sudo rm /var/www/$apachedomain/latest-de_DE.zip
                                sudo rm -r /var/www/$apachedomain/wordpress
                                sudo chown -R www-data:www-data /var/www
                                clear
                                echo -e -n "${bg_blue}Wordpress successfully installed!, returning to main menu...${clear}"
                            fi
                    else
                            clear
                            echo -e -n "${bg_blue}Wordpress not installed!, returning to main menu...${clear}"
                        
                fi

else
    clear
    echo -e "${red}$DIR directory does not exist! Please finish the installation of certbot!${clear}"
    echo -e "${magenta}returning to main menu...${clear}"
fi
   
    
}

# Option 4
function option_4() {
    echo "Opening SSH config..."
    # Installation commands
    sudo nano /etc/ssh/sshd_config
    sudo systemctl restart ssh sshd
    clear
    echo -e "${green}SSH config sucessfully configured${clear}"
}

#Option 5
function option_5() {
    echo -e "${magenta}Installing Wordpress...${clear}"
# Installtion commands
    echo -e -n "${bg_blue}Please enter the name of the domain you'll add: "
    echo -e -n "${clear}"
    read wordpress
    word=/var/www/$wordpress
    if [ -d "$word" ];
    then
        echo -e -n "${bg_blue}Folder $word already exists! Please remove the folder! Returning to main menu${clear}"
        echo
        echo -e "${magenta}Returning to main menu...${clear}"
        echo
        pause 'Press [Enter] key to continue...'
    else
        sudo apt install unzip -y
        sudo wget -P /var/www/$wordpress https://de.wordpress.org/latest-de_DE.zip
        sudo unzip -q /var/www/$wordpress/latest-de_DE.zip -d /var/www/$wordpress
        sudo mv /var/www/$wordpress/wordpress/* /var/www/$wordpress
        sudo rm /var/www/$wordpress/latest-de_DE.zip
        sudo rm -r /var/www/$wordpress/wordpress
        sudo chown -R www-data:www-data /var/www
        clear
        echo -e -n "${bg_blue}Wordpress successfully installed!, returning to main menu...${clear}"
    fi
}

# Option 6
function option_6() {
    echo "Editing MySQL config..."
    # Installation commands
    echo -e -n "${bg_blue}Please enter in the MySQL prompt the following command:${clear}"
    echo
    echo -e -n "${yellow}ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY '<change me>';${clear}"
    echo
    pause 'Press [Enter] key to continue...'
    sudo mysql
    echo -e -n "${yellow}Running MySQL secure installation script now...${clear}"
    echo
    pause 'Press [Enter] key to continue...'
    sudo mysql_secure_installation
    clear
    echo -e "${green}MySQl successfully configured${clear}"
}

# Option 7
function option_7() {
    echo "Installing and configuring PhpMyAdmin"
    # Installation commands
    sudo apt update && sudo apt upgrade -y
    sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
    sudo phpenmod mbstring
    sudo systemctl restart apache2
    echo -e -n "${bg_blue}Please add an ${yellow}AllowOverride All${clear}${bg_blue}directive at ${yellow}<Directory /usr/share/phpmyadmin>${clear}"
    echo
    pause 'Press [Enter] key to continue...'
    sudo nano /etc/apache2/conf-available/phpmyadmin.conf
    sudo systemctl restart apache2
    sudo wget -O /usr/share/phpmyadmin/.htaccess https://raw.githubusercontent.com/MMilesMM/New-Server-Installation-Script/main/files/.htaccess
    echo -e -n "${bg_blue}Please enter username you want to add: "
    echo -e -n "${clear}"
    read htuser
    sudo htpasswd -c /etc/phpmyadmin/.htpasswd $htuser
    sudo systemctl restart apache2
    clear
    echo -e "${green}PhPMyAdmin installed! Returning to menu...${clear}"
}


# Main function
function main() {
    while true; do
        display_menu
        read -p "Enter your choice (0-7): " choice
        case $choice in
            1)
                option_1
                ;;
            2)
                option_2
                ;;
            3)
                option_3
                ;;
            4)
                option_4
                ;;
            5)
                option_5
                ;;
            6)
                option_6
                ;;
            7)
                option_7
                ;;          
            0)
                echo -e "${red}Exiting...${clear}"
                break
                ;;
            *)
                clear
                echo -e "${red}Invalid choice. Please try again.${clear}"
                ;;
        esac
        echo
    done
}

# Call the main function
main
