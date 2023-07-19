#!/bin/bash


#fucntion to check password length
check_length () {
  if [ ${#1} -lt 8 ]; then
    echo "Le mot de passe est trop court"
    check_length=0  
  else 
    check_length=1
  fi
return "$check_length"
}


#function to ensure the password contain a number
check_num () {
  echo $password | grep -q [[:digit:]]
  s=$?
  if [ $s -eq 1 ]; then
    echo "le mot de passe ne contient aucun caractére numérique"
    check_num=0
  else 
    check_num=1
  fi
  return $check_num
}

#function to ensure the password contain a special character
check_cara_spec () {  
  echo $password | grep -q '[@#$%&*+-=]'
  s=$?
  if [ $s -eq 1 ]; then
    echo "le mot de passe ne contient aucun caractére spéciale"
    check_spec=0
  else 
    check_spec=1
  fi
  return $check_spec
}

#function check if the password contains a sequence of consecutive letters
dict () {   
  s=1
  for ((i=0;i<${#password}-3;i++)); do
    sub=${password:i:4}
    a=$(printf "%d" "'${sub:0:1}'")
    b=$(printf "%d" "'${sub:1:1}'")
    c=$(printf "%d" "'${sub:2:1}'")
    d=$(printf "%d" "'${sub:3:1}'")
    s=$((d - c - b + a))
    if [ $s -eq 0 ]; then
    break
    fi
  done
   if [ $s -eq 0 ]; then
     echo "votre mot de passe contient une séquence de lettre consécutive"
    check_dic=0
  else 
    check_dic=1
  fi
  return $check_dic
}

#function that print help instruction from txt file on the terminal
help(){
  cat /home/$USER/Desktop/projet/help.txt
}

show_usage () {
  echo "password.sh: [-h][-g][-v][-m][-t] mot_de_passe"
  }
  if test $# -eq 0 ; then
     show_usage >&2
     exit 1
  fi 
  
#function to use YAD graphic interface
afficher () { 
   export -f help1
   export -f check_length 
   export -f check_num
   export -f dict 
   export -f check_cara_spec
   champs=$(yad --title="Menu" \
	--form \
        --button="Help":1 \
	--field="mot de passe à tester:" '' \
	--button="tester":2 \
	--button="nom des auteurs et version":3)
	fct=$?
	if [[ $fct -eq 1 ]]; then 
	  help
	elif [[ $fct -eq 2 ]]; then
	  password=$(echo $champs | awk -F "|" '{print $1}')
	  check_length $password
          check_num $password
          dict $password
          check_cara_spec $password
          if [ $check_length -eq 1 ] && [ $check_num -eq 1 ] && [ $check_spec -eq 1 ] && [ $check_dic -eq 1 ]; then echo "votre mot de passe ( $password ) est acceptable" 
          fi
        elif [[ $fct -eq 3 ]]; then
	  echo "Auteurs: Anis Ben Othmen & Iheb Khalfallah"
  	  echo "Version: 1.0"	
        fi
}


# function that manages the text menu
menu() {
	PS3="Votre choix :"
	select item in "- help -" "- test mot de passe -" "nom des auteurs et version" "- Fin -"
	do
	 echo "Vous avez choisi l'item $REPLY : $item"
	 case $REPLY in
	 1)
	  help
	  ;;
	 2)
	  echo "saisissez le mot de passe"
	  read password
          check_length "$password"
          check_num "$password"
          check_cara_spec "$password"
          dict "$password"
          if [ $check_length -eq 1 ] && [ $check_num -eq 1 ] && [ $check_spec -eq 1 ] && [ $check_dic -eq 1 ]; then
            echo "votre mot de passe ( $password ) est acceptable" 
          fi
	  ;;
	3)
	  show_version
	  ;;
	4)
	  echo "Fin du script"
	  exit 0
	 ;;
	*)
	  echo "Choix incorrect"
	  ;;
	  esac
	  done
	}
	

show_version () {
  echo "Auteurs: Anis Ben Othmen & Iheb Khalfallah"
  echo "Version: 1.0"
}


#function that use getops to choice other functions  
while getopts "hgvmt:" option; do
  case $option in
    v)
      show_version
      ;;
    h)
      help
      exit
      ;;
    g)
      afficher $1
      exit 1
      ;;
    t)
      password="$OPTARG"
      check_length "$password"
      check_num "$password"
      check_cara_spec "$password"
      dict "$password"
      if [ $check_length -eq 1 ] && [ $check_num -eq 1 ] && [ $check_spec -eq 1 ] && [ $check_dic -eq 1 ]; then
        echo "votre mot de passe ( $password ) est acceptable" 
      fi
      ;;
    m)
     menu 
     ;;
  esac
done


