#!/bin/bash
#
# Luiz Sales - luiz@lsales.biz
# lsales.biz - www.redhate.me
#
# Script Para Alteração no IBM ITCAM
# v.02

ISMCNF="/opt/IBM/ITM/ls3266/cw/classes/ismconfig.sh" 
SERVER=$2
URL=`echo $SERVER | awk -F ":" '{print $1}'`
Port=`echo $SERVER | awk -F ":" '{print $2}'`
Param=$3
Value=$4

update_profiles() {
number=`/opt/IBM/ITM/ls3266/cw/classes/ismconfig.sh -config -listprofiles | wc -l`
tot_profile=`expr $number - 6`
/opt/IBM/ITM/ls3266/cw/classes/ismconfig.sh -config -listprofiles | tail -n $tot_profile | sed 's/ //g' > ALL_PROFILES
#inc_profile=1
echo "Total de Profile: $tot_profile"
echo

for MONITOR in `cat monitor`
do
	rm profile/$MONITOR.*.profile
	for x in `cat ALL_PROFILES` # | grep -v ISM_CCPB | grep -v ISM_DEFAULTOS | grep -v ISM_MIDDLEWARE | grep -v ISM_SAP | grep -v SHARED_HTTP | sort -u`

	do
	#echo $MONITOR $x
	$ISMCNF -config -listelts $MONITOR $x > profile/$MONITOR.$x.profile
	done

done
}
profile_detail_search() {
	li_o=`expr $lm - 7` # 7 valor com proxy, 6 valor sem proxy
	li=`echo $li_o | sed 's/-//g'`
	lf=`expr $lm + 14` # 22 valor com proxy, 14 valor sem proxy
	ll=`cat -n profile/$Profile.profile | grep $lf | awk '{print $2}'`
	if [ "$ll" == "poll" ]; then
	lf=`expr $lm + 14`
		else
	lf=`expr $lm + 22`
	fi
 	
	echo  
 	sed -n "$li,$lf p" profile/$Profile.profile > $Profile.OK
	#cat $Profile.OK 
}
colet_profile_items() {
	profile=`echo $Profile`
	index=`cat $Profile.OK | grep Index | awk '{print $2}'`
}
validacao() {
	echo "Deseja validar: (s/n)"
	read op_valida
	case $op_valida in
		"s") $ISMCNF -config -listelts HTTP $Profile > profile/$Profile.profile
		     profile_detail_search;
	             cat $Profile.OK
		     echo

		;;
		"n") break;
		;;
	esac
}

alterar_parametro() {
	echo
	echo "Deseja alterar algum parametro: (s/n)"
	read opchn
	case $opchn in
		"s") colet_profile_items;
		     echo -n "Qual parametro voce deseja alterar: "
		     read parameter
		     valor_atual=`cat $Profile.OK | grep $parameter | head -n 1 | awk -F '=' '{print $2}'`
		     echo "O valor atual do parametro: $parameter eh: $valor_atual"
		     echo
		     echo -n "Deseja altera para qual valor: "
                     read valor_novo
                     echo
		     echo "O valor do parametro: $parameter sera alterado de $valor_atual para $valor_novo"
  		     echo "Confirma? (s/n)"
		     read valor_novo_confirm
		     echo
		     case $valor_novo_confirm in
			"s") $ISMCNF -config -change HTTP $Profile $index $parameter=$valor_novo
		             validacao;
			;;
			"n") break;
		       ;;
			*) echo "opcao invalida"
			esac
		esac


}

search_site() {
#number=`/opt/IBM/ITM/ls3266/cw/classes/ismconfig.sh -config -listprofiles | wc -l`
#tot_profile=`expr $number - 6`

	for Profile in `ls profile/*.profile | cut -d"." -f1 | cut -d "/" -f2`
	do
	#$ISMCNF -config -listelts HTTP $x > profile/$x.profile
	diff_server=`cat -n profile/$Profile.profile | grep $URL | grep server | wc -l`
	if [ $diff_server -eq 1 ]; then
		lm=`cat -n profile/$Profile.profile | grep server | grep $URL | head -n 1 | awk '{print $1}'`
		profile_detail_search;
		diff_port=`cat -n $Profile.OK | grep $Port | grep port | wc -l`
		if [ $diff_port -eq 1 ]; then
			echo "Profile: $Profile contem $URL:$Port"
			echo 
			lm=`cat -n profile/$Profile.profile | grep server | grep $URL | head -n 1 | awk '{print $1}'`
		view;
		#echo "Desejar visualisar ? (s/n)"
		#read opver
		#case $opver in
	#		"s") profile_detail_search;
#			     alterar_parametro;
#			;;
#			"n") break;
#			;;
#			*) echo "Escolha uma das duas opções: (s)im (n)ao"
#			;;
#		esac
		fi

		else
		if [ $diff_server -ge 2 ]; then
	                echo "Profile: $Profile contem $URL:$Port  --  if 2"
			echo	
			lp=`cat -n profile/$Profile.profile | grep $Port | grep -v Proxy | awk '{print $1}'`
			lm=`expr $lp + 2`
			view;
			#echo "Desejar visualisar ? (s/n)"
                	#read opver
                	#case $opver in
                       # 	"s") profile_detail_search;
                       #              alterar_parametro;
                       # 	;;
                       # 	"n") break;
                       # 	;;
                       # 	*) echo "Escolha uma das duas opções: (s)im (n)ao"
                       # 	;;
                #	esac
		
		fi
	fi
	
done
}
change() { 
 	search_site;
	profile_detail_search;
	echo $SERVER
	echo $Profile
        cat $Profile.OK | grep Index | awk '{print $2}'
	echo $Param
	echo $Value

#	  $ISMCNF -config -change HTTP $Profile $index $2 $3
}
view() {
	echo "Desejar visualisar ? (s/n)"
                read opver
                case $opver in
                        "s") profile_detail_search;
	                     cat $Profile.OK
                             alterar_parametro;
                        ;;
                        "n") break;
                        ;;
                        *) echo "Escolha uma das duas opções: (s)im (n)ao"
                        ;;
                esac
}

case $1 in 
	update) update_profiles;	
	;;
	search) search_site;
	;;
	change) change;
	;;
	*) echo "opcao invalida"
	;;
esac


