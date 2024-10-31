#!/bin/bash

# Vérifier si l'utilisateur courant est root
if [ "$(id -u)" -ne 0 ]; alors
    echo "Erreur : Ce script doit être exécuté en tant qu'administrateur (root)." >&2
    exit 1
fi

# Vérifier si les arguments nécessaires sont fournis
if [ "$#" -ne 2 ]; alors
    echo "Usage: $0 <REMOTE_USER> <REMOTE_HOST>"
    exit 1
fi

# Variables
REMOTE_USER=$1          # Nom d'utilisateur sur la machine distante
REMOTE_HOST=$2          # Adresse IP ou nom d'hôte de la machine distante
SOURCE_DIR="/home/utilisateur/source"  # Répertoire à sauvegarder
REMOTE_BACKUP_DIR="/Users/username/Desktop"  # Répertoire de destination sur la machine Windows
DATE=$(date +"%Y-%m-%d_%H-%M-%S")  # Date et heure actuelle pour le nom de fichier de sauvegarde
BACKUP_NAME="backup_$DATE.tar.gz"  # Nom du fichier de sauvegarde
LOG_FILE="/home/utilisateur/Full_Backup/backup_$DATE.log"  # Fichier de log

# Fonction pour vérifier l'espace disque disponible
check_disk_space() {
    local required_space=$(du -s "$SOURCE_DIR" | awk '{print $1}')
    local available_space=$(ssh "$REMOTE_USER@$REMOTE_HOST" "df -k \"$REMOTE_BACKUP_DIR\" | tail -1 | awk '{print $4}'")
    
    if [ "$available_space" -lt "$required_space" ]; then
        echo "Erreur: Espace disque insuffisant pour effectuer la sauvegarde." >> "$LOG_FILE"
        exit 1
    fi
}

# Fonction pour envoyer une notification (exemple utilisant notify-send)
send_notification() {
    local message="$1"
    if command -v notify-send &> /dev/null; then
        notify-send "Sauvegarde complète" "$message"
    fi
}

# Créer le répertoire de sauvegarde s'il n'existe pas
mkdir -p "$(dirname "$LOG_FILE")"

# Vérifier l'espace disque disponible (local pour commencer)
check_disk_space

# Commencer la sauvegarde
echo "Début de la sauvegarde à $(date)" >> "$LOG_FILE"

# Utiliser rsync pour synchroniser les fichiers et les compresser ensuite
rsync -av --delete "$SOURCE_DIR/" "$REMOTE_BACKUP_DIR/current/" >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
    echo "Synchronisation terminée avec succès." >> "$LOG_FILE"
else
    echo "Erreur lors de la synchronisation avec rsync." >> "$LOG_FILE"
    send_notification "Erreur lors de la synchronisation avec rsync."
    exit 1
fi

# Créer une archive compressée de la sauvegarde
tar -czf "$BACKUP_NAME" -C "$REMOTE_BACKUP_DIR" current >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; alors
    echo "Archive créée avec succès : $BACKUP_NAME" >> "$LOG_FILE"
else
    echo "Erreur lors de la création de l'archive." >> "$LOG_FILE"
    send_notification "Erreur lors de la création de l'archive."
    exit 1
fi

# Envoyer l'archive compressée vers la machine Windows
scp "$BACKUP_NAME" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_BACKUP_DIR/" >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; alors
    echo "Archive envoyée avec succès vers la machine Windows." >> "$LOG_FILE"
else
    echo "Erreur lors de l'envoi de l'archive." >> "$LOG_FILE"
    send_notification "Erreur lors de l'envoi de l'archive."
    exit 1
fi

# Supprimer les fichiers temporaires de sauvegarde
rm -rf "$REMOTE_BACKUP_DIR/current"

# Terminer la sauvegarde
echo "Sauvegarde terminée à $(date)" >> "$LOG_FILE"
send_notification "Sauvegarde complète réussie : $BACKUP_NAME"
