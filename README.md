# Gestion des Sauvegardes

Ce projet présente différentes méthodes de sauvegarde des données, notamment les sauvegardes complètes, incrémentielles et différentielles, ainsi que la sauvegarde à distance via SSH. 

## Types de Sauvegarde

### 1. Sauvegarde Complète
Copie toutes les données d'un répertoire source vers un emplacement de sauvegarde.

### 2. Sauvegarde Incrémentielle
Ne copie que les fichiers qui ont changé depuis la dernière sauvegarde, qu'elle soit complète ou incrémentielle.

### 3. Sauvegarde Différentielle
Copie tous les fichiers qui ont changé depuis la dernière sauvegarde complète.

## Planification avec Cron

Pour automatiser les sauvegardes, utilisez `cron` :

1. Ouvrez le crontab :
   pour planifier les date de backup
   ```bash
   crontab -e

## Configuration de SSH

Pour la sauvegarde à distance, assurez-vous qu'OpenSSH est installé et configuré. Testez la connexion avec :

```bash
ssh utilisateur@192.168.1.34

Avant d'exécuter les scripts, assurez-vous qu'ils ont les permissions d'exécution :
chmod +x sauvegarde.sh


  
