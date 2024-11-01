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

1. Ouvrez le crontab pour planifier les dates de backup :
   ```bash
   crontab -e

## Configuration de SSH
1. Pour la sauvegarde à distance, assurez-vous qu'OpenSSH est installé et configuré. Testez la connexion avec :
   ```bash
   ssh utilisateur@IP@

2. Avant d'exécuter les scripts, assurez-vous qu'ils ont les permissions d'exécution :
   ```bash
   chmod +x sauvegarde.sh

## Sauvegarde Locale
1. Donnez les permissions d'exécution au script avant de l'exécuter :


   ```bash
   chmod +x sauvegarde_locale.sh

2. Exécutez le script en utilisant vos fichiers de destination et de source :


   ```bash 
   ./sauvegarde_locale.sh /chemin/vers/source /chemin/vers/destination

## Sauvegarde à Distance
1. Configuration de ssh_config (pour les versions distantes)
Ce script est conçu pour s'exécuter sans intervention de l'utilisateur. Pour ce faire, vous devez autoriser votre machine source à accéder à la machine distante. Pour accomplir cela, vous devez utiliser des clés SSH pour vous identifier et configurer un hôte SSH pour les utiliser correctement.

Il existe de nombreux tutoriels dédiés à ces sujets, vous pouvez en suivre un. Je ne rentrerai pas dans une explication plus détaillée ici, mais voici quelques bonnes références :
How To Set Up SSH Keys
[How To Set Up SSH Keys](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-2)
