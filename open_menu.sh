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

function display_menu() {
    echo "Menu for Installing Programs"
    echo "1. Install Apache2, PHP with common modules and MySQL Server"
    echo "2. Install certbot with cloudflare addon"
    echo "3. Download pre-made default config for apache2 (vhost, ssl extra)"
    echo "4. Edit SSH config to allow root ssh"
    echo "5. Exit"
}

# Option 1
function option_1() {
    echo "installing Apache2 and PHP"
    # Installation commands
    sudo apt update && sudo apt upgrade -y
    sudo apt install apache2 wget curl -y
    sudo apt install php libapache2-mod-php php-mysql
    sudo apt install php-{zip,curl,bcmath,cli,common,imap,intl,json,xml,imagick,dom,fileinfo,mbstring} -y
    sudo apt install mysql-server -y
    echo -e "${green}Apache,PHP and MySQL sccessfully installed!${clear}"
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
        sudo wget -P /root/.secrets/certbot https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/cloudflare.ini
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
                echo -e "${green}Cloudflare certificate installed and configured!${clear}"
            fi
    else
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
    sudo wget -O /etc/ssl/dhparams.pem https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/dhparams.pem
    sudo wget -O /etc/letsencrypt/options-ssl-apache.conf https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/options-ssl-apache.conf
    sudo wget -O /etc/apache2/conf-available/security.conf https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/security.conf
    sudo wget -O /etc/apache2/sites-available/default_vhost.conf https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/default_vhost.conf
    sudo a2enconf security.conf
    sudo systemctl restart apache2
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
                sudo a2ensite $apachedomain
                sudo systemctl reload apache2
                echo -e "${green}Domain added and apache reloaded!${clear}"
            fi

else
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
    echo -e "${green}SSH config sucessfully configured${clear}"
}

# Main function
function main() {
    while true; do
        display_menu
        read -p "Enter your choice (1-5): " choice
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
                echo -e "${red}Exiting...${clear}"
                break
                ;;
            *)
                echo -e "${red}Invalid choice. Please try again.${clear}"
                ;;
        esac
        echo
    done
}

# Call the main function
main
