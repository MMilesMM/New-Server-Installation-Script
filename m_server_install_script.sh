#!/bin/bash

# Function to display the menu
function display_menu() {
    echo "Menu for Installing Programs"
    echo "1. Install Apache2 und PHP with common modules"
    echo "2. Install certbot"
    echo "3. Download pre-made default config for apache2 (vhost, ssl extra)"
    echo "4. Edit SSH config to allow root ssh"
    echo "5. Exit"
}

# Option 1
function option_1() {
    echo "installing Apache2 and PHP"
    # Add your installation commands for Program A here
    sudo apt updat && sudo apt upgrade -y
    sudo apt install apache2 -y
    sudo apt install php libapache2-mod-php php-mysql
    sudo apt install php-{zip,curl,bcmath,cli,common,imap,intl,json,xml,imagick} -y
    sudo apt install mysql-server -y
    echo "Apache und PHP sccessfully installed!"
}

# Option 2
function option_2() {
    echo "Installting certbot and snap"
    # Add your installation commands for Program B here
    sudo apt install snapd -y
    sudo snap install --classic certbot
    sudo ln -s /snap/bin/certbot /usr/bin/certbot
    sudo snap set certbot trust-plugin-with-root=ok
    sudo snap install certbot-dns-cloudflare
    
    echo "Certbot and snap installed successfully!"
}

# Option 3
function option_3() {
    echo "Installing Program C..."
    # Add your installation commands for Program C here
    echo "Program C installed successfully!"
}

# Option 4
function option_4() {
    echo "Opening SSH config..."
    sudo nano /etc/ssh/sshd_config
    sudo systemctl restart ssh sshd
    echo "SSH erfolgreich angepasst!"
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
                echo "Exiting..."
                break
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
        echo
    done
}

# Call the main function
main