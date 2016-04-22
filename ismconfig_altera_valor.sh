#!/bin/sh
#Server=$1
ISMCNF="/opt/IBM/ITM/ls3266/cw/classes/ismconfig.sh"

URL=$1
Port=$2
Page=$3
#URL=`echo $Server | cut -d ":" -f1`
#Port=`echo $Server | cut -d ":" -f2`
#Page=`echo $Server | cut -d ":" -f3`
Param=$4
Value=$5

if [ -z $1 ];then
	echo
	echo "Modo de uso: $0  URL PORTA PAGE Parametro Valor_Novo
	echo "$0 172.26.79.62 6101 /default.aspx retestinterval 15
	echo

	else


if [ -z "$4" ];then 
	echo
	echo "Variaveis vazias nao sao permitidas"
	echo
	else
 
echo > Profiles_Port
grep "server = '$URL'" profile/* | awk '{print $1}' | sort -u | sed 's/://g' > Profiles

menu() {
        echo "Voce deseja ver:  (s/n)"

	read opcao
	case opcao in
	 "s") cat tmp/$p
         #$ISMCNF -config -change HTTP $Profile $index $Param=$Value
          ;;
         "n") echo "Voce deseja executar: (s/n)"
         break;
          ;;
        *) echo "escolha s/n"
	menu;
        ;;
esac
}


for NomeProfile in `cat Profiles`
do
#echo $NomeProfile
#echo
	qntd_srv=`cat -n $NomeProfile | grep "server = '$URL'" | wc -l`
	
	if [ $qntd_srv -ge 1 ];then
		qntd_srv_i=`cat -n $NomeProfile | grep "server = '$URL'" | awk '{print $1}'`
		for i in `echo $qntd_srv_i`
		do
			lm=`echo $i`
			la_o=`expr $lm - 4`
        		la=`echo $la_o | sed 's/-//g'`
        		lla=`cat -n $NomeProfile | grep $la | awk '{print $2}' | grep ctive`
        		if [ "$lla" == "Active" ]; then
				li_o=`expr $lm - 7` # 7 valor com proxy, 6 valor sem proxy
        			li=`echo $li_o | sed 's/-//g'`
				lf=`expr $lm + 14` # 22 valor com proxy, 14 valor sem proxy
        			ll=`cat -n $NomeProfile | grep $lf | awk '{print $2}' | grep oll`
        			if [ "$ll" == "poll" ]; then
        				lf=`expr $lm + 14`
					else
        				lf=`expr $lm + 22`
        			fi
	
				sed -n "$li,$lf p" $NomeProfile > tmp/$NomeProfile.OK
				index=`grep Index 'tmp/'$NomeProfile.OK  | awk '{print $2}'`
				mv tmp/$NomeProfile.OK tmp/$NomeProfile.$index.OK
				count_prt=`grep "port = '$Port'" tmp/$NomeProfile.$index.OK | wc -l `
				if [ $count_prt -eq 1 ];then
					echo $NomeProfile.$index.OK >> Profiles_Port 
				fi
				qntd_prt=`cat -n Profiles_Port | wc -l`
				if [ $qntd_prt -ne 1 ];then
					for p in `cat Profiles_Port`
					do
						qntd_pg=`grep "page = '$Page'" tmp/$p  | wc -l`
						if [ $qntd_pg -eq 1 ];then
							Profile=`echo $p | cut -d "." -f2 | cut -d "/" -f2`
							#echo $Profile
							Index=`echo $p | cut -d "." -f4`
							#echo $Index
							# Bloco de teste e escolha ( homologacao )
							#cat tmp/$p
							echo "ismconfig.sh -config -change HTTP $Profile $Index $Param=$Value"
							$ISMCNF -config -change HTTP $Profile $index $Param=$Value
						fi
					done
				fi
			fi
 
		done
	fi
done


fi

fi

