#!/bin/bash

while true; do
    clear
    echo "Menu:"
    echo "1. Ajout d'un utilisateur"
    echo "2. Modification d'un utilisateur"
    echo "3. Suppression d'un utilisateur"
    echo "4. Ajout/Suppression d'un utilisateur au fichier sudoers"
    echo "5. Sortie du script"

    read -p "Choisissez une option (1/2/3/4/5): " choice

    case $choice in
        1)
            read -p "Nom d'utilisateur: " username
            read -p "Chemin du dossier utilisateur: " home_dir
            read -p "Date d'expiration (YYYY-MM-DD): " exp_date
            read -p "Mot de passe: " password
            read -p "Shell: " shell
            read -p "Identifiant: " uid

            if [ -z "$username" ] || [ -z "$home_dir" ] || [ -z "$exp_date" ] || [ -z "$shell" ]; then
                echo "Erreur: Veuillez fournir toutes les informations obligatoires."
                sleep 2
                continue
            fi

            if [ -d "$home_dir" ]; then
                echo "Erreur: Le dossier utilisateur existe déjà."
                sleep 2
                continue
            fi

            if [ "$(date -d "$exp_date" +%s)" -le "$(date +%s)" ]; then
                echo "Erreur: La date d'expiration doit être ultérieure à aujourd'hui."
                sleep 2
                continue
            fi

            useradd -m -d "$home_dir" -e "$exp_date" -p "$password" -s "$shell" -u "$uid" "$username"
            echo "Utilisateur ajouté avec succès."
            sleep 2
            ;;

        2)
            read -p "Nom d'utilisateur à modifier: " old_username
            read -p "Nouveau nom d'utilisateur: " new_username
            read -p "Nouveau chemin du dossier utilisateur: " new_home_dir
            read -p "Nouvelle date d'expiration (YYYY-MM-DD): " new_exp_date
            read -p "Nouveau mot de passe: " new_password
            read -p "Nouveau shell: " new_shell
            read -p "Nouvel identifiant: " new_uid

            if [ -z "$new_username" ] || [ -z "$new_home_dir" ] || [ -z "$new_exp_date" ] || [ -z "$new_shell" ]; then
                echo "Erreur: Veuillez fournir toutes les informations obligatoires."
                sleep 2
                continue
            fi

            if [ ! -d "$new_home_dir" ]; then
                mv "$home_dir" "$new_home_dir"
                usermod -l "$new_username" -d "$new_home_dir" -e "$new_exp_date" -p "$new_password" -s "$new_shell" -u "$new_uid" "$old_username"
                echo "Utilisateur modifié avec succès."
                sleep 2
            else
                echo "Erreur: Le nouveau dossier utilisateur existe déjà."
                sleep 2
            fi
            ;;

        3)
            read -p "Nom d'utilisateur à supprimer: " del_username

            read -p "Supprimer le dossier utilisateur? (oui/non): " del_home_dir
            read -p "Supprimer l'utilisateur même s'il est connecté? (oui/non): " del_user

            userdel $del_username

            if [ "$del_home_dir" == "oui" ]; then
                rm -r "/home/$del_username"
            fi

            if [ "$del_user" == "oui" ]; then
                pkill -u $del_username
            fi

            echo "Utilisateur supprimé avec succès."
            sleep 2
            ;;

        4)
            read -p "Nom d'utilisateur pour sudoers: " sudo_user
            read -p "Ajouter ou supprimer l'utilisateur au fichier sudoers? (ajout/suppression): " sudo_choice

            case $sudo_choice in
                ajout)
                    echo "$sudo_user ALL=(ALL:ALL) ALL" >> /etc/sudoers
                    echo "Utilisateur ajouté au fichier sudoers avec succès."
                    ;;
                suppression)
                    sed -i "/$sudo_user/d" /etc/sudoers
                    echo "Utilisateur supprimé du fichier sudoers avec succès."
                    ;;
                *)
                    echo "Option invalide pour l'ajout/suppression au fichier sudoers."
                    sleep 2
                    ;;
            esac
            sleep 2
            ;;

        5)
            echo "Sortie du script."
            exit 0
            ;;
        *)
            echo "Option invalide. Veuillez réessayer."
            sleep 2
            ;;
    esac
done