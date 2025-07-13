#!/bin/bash

# Mettre à jour le système
sudo apt update
sudo apt upgrade -y

# Installer Apache2
sudo apt install apache2 -y
sudo systemctl enable --now apache2
#on donne les droits a apache sur le dossier HTML
sudo chown www-data:www-data /var/www/html/ -R

# activation des modules
# headers ( pour la securité des ene-tetes)
# deflate (active la compression des fichiers avent l envoie au client => gain en chargement)
# rewrite (pour la redirection des urls)
# ssl ( pour le support ssl/tls)
sudo a2enmod headers rewrite deflate ssl 

# Installer MariaDB
sudo apt install mariadb-server -y
sudo systemctl enable --now mariadb

#creation du mot de passe root mysql
root_password=""
read -s -p "entrez un mot de passe pour root mariadb : " root_password

# Sécuriser l'installation de MariaDB
# on repond automatiquement aux questions, sauf pour le mot de passe
sudo mysql_secure_installation << EOF
y
$root_password
$root_password
y
y
y
y
EOF
# fin d installation mariadb

# Installer PHP8 et ses modules nécessaires
sudo apt install php8.3 libapache2-mod-php8.3 php8.3-mysql php8.3-common php8.3-mysql php8.3-xml php8.3-xmlrpc php8.3-curl php8.3-gd php8.3-cli php8.3-dev php8.3-imap php8.3-mbstring php8.3-opcache php8.3-soap php8.3-zip php8.3-intl -y php8.3-fpm

# onconfigure apache avec php
sudo a2enmod proxy_fcgi setenvif
sudo a2enconf php8.3-fpm

#installation de  phpMyAdmin
read -p "Voulez-vous installer phpMyAdmin ? (y/n) : " choix

# Vérifier la réponse de l'utilisateur
if [[ "$choix" == "y" || "$choix" == "Y" ]]; then
    echo "Installation de phpMyAdmin..."
    sudo apt update
    sudo apt install phpmyadmin -y
    echo "----------------------------------------------------"
    echo "Entrez le mot de passe ROOT MYSQL défini precedement"
    echo "----------------------------------------------------"
    sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'phpmyadmin'@'localhost' WITH GRANT OPTION;"
    echo "phpMyAdmin a été installé avec succès."
    echo " ########## "
    echo " utilisateur phpmyadmin : phpmyadmin "
    echo " ########## "
echo " mot de passe : celui que vous venez de definir"
elif [[ "$choix" == "n" || "$choix" == "N" ]]; then
    echo "Installation de phpMyAdmin annulée."
else
    echo "Réponse non valide. Veuillez répondre par y (oui) ou n (non)."
fi

# Redémarrer Apache
sudo systemctl restart apache2

#création d'un fichier de test php
sudo echo "<?php phpinfo(); ?>" > /var/www/html/info.php

echo "Installation terminée !"
echo ""
echo "testez la page : http://localhost/info.php"
echo " et supprimez le ensuite"
echo ""
echo ""