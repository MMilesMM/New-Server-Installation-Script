#!/bin/bash
#variables
# Set the color variable
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
# Clear the color after that
clear='\033[0m'

#Options
command 1> /dev/null

# Function to display the menu
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
    sudo apt install apache2 -y
    sudo apt install php libapache2-mod-php php-mysql
    sudo apt install php-{zip,curl,bcmath,cli,common,imap,intl,json,xml,imagick} -y
    sudo apt install mysql-server -y
    echo -e "${green}Apache,PHP and MySQL sccessfully installed!${clear}"
}

# Option 2
function option_2() {
    echo "Installting certbot and snap"
    # Installation commands
    sudo apt install snapd -y
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    sudo snap set certbot trust-plugin-with-root=ok
    sudo snap install certbot-dns-cloudflare
    while true; do
    read -p "Would you like to configure cloudlfare now?" yn
    case $yn in
        [Yy]* ) mkdir -p ~/.secrets/certbot; wget -p ~/.secrets/certbot https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/cloudflare.ini; chmod 600 ~/.secrets/certbot/cloudflare.ini;return;;
        [Nn]* ) return;;
        * ) echo -e "${green}Please answer yes or no.${clear}";;
    esac
done#   
    
    echo -e "${green}Certbot and snap installed successfully!${clear}"
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
   sudo a2enmod headers ssl
   sudo a2enmod rewrite
   sudo a2enmod actions
   sudo systemctl restart apache2
   sudo mkdir /tmp/mscript
   sudo /tmp/mscript
   sudo wget https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/dhparams.pem
   sudo wget https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/options-ssl-apache.conf
   sudo wget https://raw.githubusercontent.com/MMilesMM/new_server_script/main/files/security.conf
   sudo mv dhparams.pem /etc/ssl
   sudo mv options-ssl-apache.conf /etc/letsencrypt
   sudo mv security.conf /etc/apache2/conf-available
   sudo a2enconf security.conf
   sudo systemctl restart apache2
   echo -e "${green}Apache config installed!${clear}"
else
 echo -e "${red}$DIR directory does not exist! Please finish the installation of certbot!${clear}"
 echo -e "${magenta}returning to main menu${clear}"
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
        read -p "Enter your choice (1-4): " choice
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
