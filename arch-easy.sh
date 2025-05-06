#!/bin/sh

# Colors / Couleurs
LIGHT_BLUE='\033[1;34m'  
RED='\033[0;31m'
NC='\033[0m'

# Error message / Message d'erreur /

# Welcome / Bienvenue /
whiptail --msgbox "                   Hello World                   " 10 50 --title "Hello World"

# Language choice / Choix de langue /

# Texts / Textes /

# Automatic or personalized ? / Automatique ou personnalisé ?

# Warning message / Message d'avertissement /
whiptail --yesno "Voulez-vous continuer ?" 10 50

# Automatic script / Script automatique /

# Personalized script / Script personnalisé /

exit 0
