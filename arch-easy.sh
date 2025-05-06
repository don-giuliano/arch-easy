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

# Language choice / Choix de langue
lang=$(whiptail --title "Choose your language" --menu "Choose your language :" 15 60 6 \
    "1" "English" \
    "2" "Français" \
    
# Texts by language / Textes par langues

# Automatic or personalized ? / Automatique ou personnalisé ?

# Warning message / Message d'avertissement

# Automatic script / Script automatique

# Script personnalisé

exit 0
