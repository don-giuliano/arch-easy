#!/bin/sh

# Colors / Couleurs
LIGHT_BLUE='\033[1;34m'  
RED='\033[0;31m'
NC='\033[0m'

# Error message / Message d'erreur  
error_msg() {
    whiptail --title "$error_title" --msgbox "$1" 8 45  
    exit 1  
}

# Welcome / Bienvenue 
whiptail --title "Hello world" --msgbox "$welcome_msg" --menu "HELLO WORLD" 10 60

# Language choice / Choix de langue  
lang=$(whiptail --title "Select your language" --menu "Select your language :" 15 60 6 \
    "1" "English" \
    "2" "French" \
    "3" "Italiano" \ 
    3>&1 1>&2 2>&3) || exit

# Texts / Textes  
case $lang in  
    1) 
        error_title="Error"
        welcome_msg="Welcome to the Arch Linux installation script!"
        ;;
    2) 
        error_title="Erreur"
        welcome_msg="Bienvenue dans le script d'installation d'Arch Linux !"
        ;;
    3) 
        error_title="Errore"
        welcome_msg="Benvenuto nello script di installazione di Arch Linux!"
        ;;
esac

# Automatic or personalized ? / Automatique ou personnalisé ?

# Warning message / Message d'avertissement

# Automatic script / Script automatique

# Script personnalisé

exit 0
