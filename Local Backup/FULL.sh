#!/bin/bash

# Vérifier si l'utilisateur courant est root
if [ "$(id -u)" -ne 0 ]; then
    echo "Erreur : Ce script doit être exécuté en tant qu'administrateur (root)." >&2
    exit 1
fi

# Variables
SOURCE_DIR="/home/sunsey/source"  # Répertoire à sauvegarder
BACKUP_DIR="/home/sunsey/Full Backup"  # Destination de la sauvegarde
DATE=$(date +"%Y-%m-%d_%H-%M-%S")  # Date et heure actuelle pour le nom de fichier de sauvegarde
BACKUP_NAME="backup_$DATE.tar.gz"  # Nom du fichier de sauvegarde
LOG_FILE="$BACKUP_DIR/backup_$DATE.log"  # Fichier de log

# Fonction pour vérifier l'espace disque disponible
check_disk_space() {
    local required_space=$(du -s "$SOURCE_DIR" | awk '{print $1}')
    local available_space=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4}')
    
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
mkdir -p "$BACKUP_DIR"

# Vérifier l'espace disque disponible
check_disk_space

# Commencer la sauvegarde
echo "Début de la sauvegarde à $(date)" >> "$LOG_FILE"

# Utiliser rsync pour synchroniser les fichiers et les compresser ensuite
rsync -av --delete "$SOURCE_DIR/" "$BACKUP_DIR/current/" >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
    echo "Synchronisation terminée avec succès." >> "$LOG_FILE"
else
    echo "Erreur lors de la synchronisation avec rsync." >> "$LOG_FILE"
    send_notification "Erreur lors de la synchronisation avec rsync."
    exit 1
fi

# Créer une archive compressée de la sauvegarde
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "$BACKUP_DIR" current >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
    echo "Archive créée avec succès : $BACKUP_NAME" >> "$LOG_FILE"
else
    echo "Erreur lors de la création de l'archive." >> "$LOG_FILE"
    send_notification "Erreur lors de la création de l'archive."
    exit 1
fi

# Supprimer les fichiers temporaires de sauvegarde
rm -rf "$BACKUP_DIR/current"

# Terminer la sauvegarde
echo "Sauvegarde terminée à $(date)" >> "$LOG_FILE"
send_notification "Sauvegarde complète réussie : $BACKUP_NAME"
