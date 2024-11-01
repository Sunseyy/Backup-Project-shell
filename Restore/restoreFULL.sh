#!/bin/bash

# Vérifier si l'utilisateur courant est root
if [ "$(id -u)" -ne 0 ]; then
    echo "Erreur : Ce script doit être exécuté en tant qu'administrateur (root)." >&2
    exit 1
fi

# Vérifier si le nombre d'arguments est correct
if [ "$#" -ne 2 ] && [ "$#" -ne 3 ]; then
    echo "Usage: $0 <backup_directory> <restore_directory> [<date_YYYY-MM-DD_HH-MM-SS>]"
    exit 1
fi

# Variables
BACKUP_DIR="$1"  # Répertoire contenant la sauvegarde
RESTORE_DIR="$2" # Répertoire de restauration
TARGET_DATE="$3" # Date et heure cibles pour la restauration (optionnel)
LOG_FILE="$BACKUP_DIR/restore.log"  # Fichier de log

# Créer le répertoire de restauration s'il n'existe pas
mkdir -p "$RESTORE_DIR"

# Commencer la restauration
echo "Début de la restauration à $(date)" >> "$LOG_FILE"

# Si la date cible n'est pas fournie, obtenir le dernier fichier de sauvegarde
if [ -z "$TARGET_DATE" ]; then
    BACKUP_FILE=$(ls "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | sort | tail -n 1)
    echo "Aucune date fournie. Récupération du dernier fichier de sauvegarde : $BACKUP_FILE" >> "$LOG_FILE"
else
    BACKUP_FILE=$(ls "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | grep "$TARGET_DATE" | sort | tail -n 1)
    echo "Recherche du fichier de sauvegarde pour la date : $TARGET_DATE" >> "$LOG_FILE"
fi

# Vérifier si un fichier de sauvegarde a été trouvé
if [ -z "$BACKUP_FILE" ]; then
    echo "Erreur : Aucun fichier de sauvegarde trouvé pour la date $TARGET_DATE dans $BACKUP_DIR." >> "$LOG_FILE"
    exit 1
fi

# Extraire l'archive de sauvegarde
echo "Extraction de l'archive : $BACKUP_FILE" >> "$LOG_FILE"
tar -xzf "$BACKUP_FILE" -C "$RESTORE_DIR" >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
    echo "Restauration terminée avec succès depuis le fichier $BACKUP_FILE." >> "$LOG_FILE"
else
    echo "Erreur lors de la restauration de l'archive." >> "$LOG_FILE"
    exit 1
fi

# Terminer la restauration
echo "Restauration terminée à $(date)" >> "$LOG_FILE"
