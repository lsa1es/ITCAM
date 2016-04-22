#!/bin/bash
ISMCNF="/opt/IBM/ITM/ls3266/cw/classes/ismconfig.sh" 
URL=$2

listall_profile() {
number=`/opt/IBM/ITM/ls3266/cw/classes/ismconfig.sh -config -listprofiles | wc -l`
tot_profile=`expr $number - 6`
listallprofiles=`$ISMCNF -config -listprofiles | tail -n $tot_profile | sed 's/ //g'`
profile_x="Profile_Teste_Lsales"

for x in `$ISMCNF -config -listprofiles | tail -n $tot_profile | sed 's/ //g'`
do
$ISMCNF -config -listelts HTTP $x
echo
done
}
profile_detail_search() {
	lm=`cat -n profile/$x.profile | grep server | grep $URL | head -n 1 | awk '{print $1}'`
	li=`expr $lm - 7` # 7 valor geral
	lf=`expr $lm + 14` # 22 valor com proxy, 14 valor sem proxy
	if [ `cat -n profile/$x.profile | grep $lf` == "poll" ]; then
	lf=`expr $lm + 14`
		else
	lf=`expr $lm + 22`
	fi
 	
	echo  
 	sed -n "$li,$lf p" profile/$x.profile > $x.OK
	cat $x.OK 
}
colet_profile_items() {
	profile=`echo $x`
	index=`cat $x.OK | grep Index | awk '{print $2}'`
}
validacao() {
	echo "Deseja validar: (s/n)"
	read op_valida
	case $op_valida in
		"s") $ISMCNF -config -listelts HTTP $x > profile/$x.profile
		     profile_detail_search;
		;;
		"n") break;
		;;
	esac
}

alterar_parametro() {
	echo "Deseja alterar algum parametro: (s/n)"
	read opchn
	case $opchn in
		"s") colet_profile_items;
		     echo -n "Qual parametro voce deseja alterar: "
		     read parameter
		     valor_atual=`cat $x.OK | grep $parameter | head -n 1 | awk -F '=' '{print $2}'`
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
			"s") $ISMCNF -config -change HTTP $x $index $parameter=$valor_novo
		             validacao;
			;;
			"n") break;
		       ;;
			*) echo "opcao invalida"
			esac
		esac


}

search_site() {
number=`/opt/IBM/ITM/ls3266/cw/classes/ismconfig.sh -config -listprofiles | wc -l`
tot_profile=`expr $number - 6`

	for x in `cat oi.tmp`
	do
	$ISMCNF -config -listelts HTTP $x > profile/$x.profile
	if [ `cat -n profile/$x.profile | grep server | grep $URL | head -n 1| wc -l` == 1 ]; then
		echo "Profile: $x contem $URL"
		echo 
		echo "Desejar visualisar ? (s/n)"
		read opver
		case $opver in
			"s") profile_detail_search;
			     alterar_parametro;
			;;
			"n") break;
			;;
			*) echo "Escolha uma das duas opções: (s)im (n)ao"
			;;
		esac
		break;	
	
	fi
		
done
}
	  
case $1 in 
	listallprofiles) listall_profile;	
	;;
	search) search_site;   
	;;
	*) echo "opcao invalida"
	;;
esac


