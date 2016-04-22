#!/bin/sh

data=$(date "+%d%m%y")
USER=""
PASS=""
IPSERVER=""
echo > Sit.Names
profil=$2
login() {
        /opt/IBM/ITM/bin/tacmd login -s $IPSERVER -u $USER -p $PASS
        /opt/IBM/ITM/bin/tacmd tepslogin -s $IPSERVER -u $USER -p $PASS

}

situ() {
login
mkdir -p situations
#/opt/IBM/ITM/bin/tacmd listSit | awk '{print $1}' > ListSit

for Sits in `ls situations/*.xml `
do
	echo "*******************************"
	NSit=`echo $Sits | cut -d "/" -f2`
	echo $NSit
	echo "Profile: " `cat -n situations/$NSit | grep zmmgtems | head -n1 | awk '{print $11}' | cut -d\: -f1 | sed $'s/\'//g'`

	#/opt/IBM/ITM/bin/tacmd viewSit -s $Sits -e situations/$Sits.xml 2>&1 >/dev/null
	echo "hostname: " `cat situations/$NSit | grep MAP | awk -F 'hostname' '{print $2}' | awk -F '/>' '{print $1}' | awk -F\" '{print $3}'`
	echo "*******************************"	

done
}

host() {
	situname=`grep $profil  situations/*.xml | awk -F\: '{print $1}' | sort -u `
	if [ -z "$situname" ]; then
		echo "Nao Encontrado"
		else
		hostname=`cat $situname | grep MAP | awk -F 'hostname' '{print $2}' | awk -F '/>' '{print $1}' | awk -F\" '{print $3}'`
		echo $hostname
	fi

}


	
hostname() {
	login        
	for SitName in `ls profile/SMTP.*.profile`
        do
                fail=`cat $Profiles | wc -l`
                if [ $fail -ne 7 ]; then
                        NomeProfile=`echo $Profiles | cut -d "." -f2`
                        /opt/IBM/ITM/bin/tacmd viewSit -s $NomeProfile -e $NomeProfile.xml
                fi
        done
}


icmp() {

echo "Monitor;IC;Profile;Index;Status;numberofpings;timeout;server;failureretests;typeofservice;retries;hostnamelookuppreference;packetsize;retestinterval;description;packetinterval;poll" > Booking-ICMP.$data.csv

for Profiles in `ls profile/ICMP.*.profile`
do
	Monitor=`echo $Profiles | cut -d "/" -f2| cut -d "." -f1`
	NomeProfile=`echo $Profiles | cut -d "." -f2`
	Prof=`echo  profile/$Monitor.$NomeProfile.profile`
	fail=`cat $Profiles | wc -l`
	if [ $fail -ne 7 ]; then
		qntd_ix=`cat $Profiles | grep Index | wc -l`
		for NI in `cat -n $Profiles | grep Index | awk '{print $1}'`
		do
			lf=`expr $NI + 16`
		        sed -n "$NI,$lf p" $Profiles > $NI.OK
			index=`cat $NI.OK | grep Index | awk '{print $2}' | sed 's/ //g'`
               		status=`cat $NI.OK | grep ctive | sed 's/ //g'`
                       	numberofpings=`cat $NI.OK | grep numberofpings | awk -F "=" '{print $2}' | sed 's/ //g'`
                        timeout=`cat $NI.OK | grep timeout | awk -F "=" '{print $2}' | sed 's/ //g'`
	                IC=`$0 host $NomeProfile`
			server=`cat $NI.OK | grep server | awk -F "=" '{print $2}' | sed 's/ //g'`
               	        failureretests=`cat $NI.OK | grep failureretests | awk -F "=" '{print $2}' | sed 's/ //g'`
               		typeofservice=`cat $NI.OK | grep typeofservice | awk -F "=" '{print $2}' | sed 's/ //g'`
               		retries=`cat $NI.OK | grep retries | awk -F "=" '{print $2}' | sed 's/ //g'`
               		hostnamelookuppreference=`cat $NI.OK | grep hostnamelookuppreference | awk -F "=" '{print $2}' | sed 's/ //g'`
       		        packetsize=`cat $NI.OK | grep packetsize | awk -F "=" '{print $2}' | sed 's/ //g'`
             		retestinterval=`cat $NI.OK | grep retestinterval | awk -F "=" '{print $2}' | sed 's/ //g'`
                       	description=`cat $NI.OK | grep description | awk -F "=" '{print $2}'`
                       	packetinterval=`cat $NI.OK | grep packetinterval | awk -F "=" '{print $2}' | sed 's/ //g'`
                       	poll=`cat $NI.OK | grep poll | awk -F "=" '{print $2}' | sed 's/ //g'`
			rm $NI.OK	
			echo "$Monitor;$IC;$NomeProfile;$index;$status;$numberofpings;$timeout;$server;$failureretests;$typeofservice;$retries;$hostnamelookuppreference;$packetsize;$retestinterval;$description;$packetinterval;$poll" | sed $'s/\'//g'
			echo "$Monitor;$IC;$NomeProfile;$index;$status;$numberofpings;$timeout;$server;$failureretests;$typeofservice;$retries;$hostnamelookuppreference;$packetsize;$retestinterval;$description;$packetinterval;$poll" | sed $'s/\'//g' >> Booking-ICMP.$data.csv
		done
	fi
done
}

smtp() {
echo "Monitor;Host;NomeProfile;index;status;port;timeout;server;failureretests;retestinterval;authenticationtype;sharedsecret;username;securitytype;password;email;description;poll" > Booking-SMTP.$data.csv
for Profiles in `ls profile/SMTP.SMTP_*.profile`
do
        Monitor=`echo $Profiles | cut -d "/" -f2| cut -d "." -f1`
        NomeProfile=`echo $Profiles | cut -d "." -f2`
        Prof=`echo  profile/$Monitor.$NomeProfile.profile`
        fail=`cat $Profiles | wc -l`
        if [ $fail -ne 7 ]; then
                qntd_ix=`cat $Profiles | grep Index | wc -l`
                for NI in `cat -n $Profiles | grep Index | awk '{print $1}'`
                do
                        lf=`expr $NI + 17`
                        sed -n "$NI,$lf p" $Profiles > $NI.OK
                        index=`cat $NI.OK | grep Index | awk '{print $2}' | sed 's/ //g'`
                        status=`cat $NI.OK | grep ctive | sed 's/ //g'`
                        port=`cat $NI.OK | grep port | awk -F "=" '{print $2}' | sed 's/ //g'`
                        timeout=`cat $NI.OK | grep timeout | awk -F "=" '{print $2}' | sed 's/ //g'`
                        host=`cat $NI.OK | grep server | awk -F "=" '{print $2}' | sed 's/ //g'`
			server=`cat $NI.OK | grep server | awk -F "=" '{print $2}' | sed 's/ //g'`
                        failureretests=`cat $NI.OK | grep failureretests | awk -F "=" '{print $2}' | sed 's/ //g'`
                        retestinterval=`cat $NI.OK | grep retestinterval | awk -F "=" '{print $2}' | sed 's/ //g'`
                        authenticationtype=`cat $NI.OK | grep authenticationtype | awk -F "=" '{print $2}' | sed 's/ //g'`
                        sharedsecret=`cat $NI.OK | grep sharedsecret | awk -F "=" '{print $2}' | sed 's/ //g'`
                        username=`cat $NI.OK | grep username | awk -F "=" '{print $2}' | sed 's/ //g'`
                        securitytype=`cat $NI.OK | grep securitytype | awk -F "=" '{print $2}' | sed 's/ //g'`
                        password=`cat $NI.OK | grep password | awk -F "=" '{print $2}'`
                        email=`cat $NI.OK | grep email | awk -F "=" '{print $2}' | sed 's/ //g'`
			description=`cat $NI.OK | grep description  | awk -F "=" '{print $2}' | sed 's/ //g'`
                        poll=`cat $NI.OK | grep poll | awk -F "=" '{print $2}' | sed 's/ //g'`
                        rm $NI.OK
			echo "$Monitor;$Host;$NomeProfile;$index;$status;$port;$timeout;$server;$failureretests;$retestinterval;$authenticationtype;$sharedsecret;$username;$securitytype;$password;$email;$description;$poll" | sed $'s/\'//g' 
			echo "$Monitor;$Host;$NomeProfile;$index;$status;$port;$timeout;$server;$failureretests;$retestinterval;$authenticationtype;$sharedsecret;$username;$securitytype;$password;$email;$description;$poll" | sed $'s/\'//g' >> Booking-SMTP.$data.csv
                done
        fi
done
}
dns() {
echo "Monitor;IC;NomeProfile;index;status;timeout;port;querytype;localip;server;failureretests;retries;recursivelookups;host;retestinterval;description;poll" > Booking-DNS.$data.csv 
for Profiles in `ls profile/DNS.*.profile`
do
        Monitor=`echo $Profiles | cut -d "/" -f2| cut -d "." -f1`
        NomeProfile=`echo $Profiles | cut -d "." -f2`
        Prof=`echo  profile/$Monitor.$NomeProfile.profile`
        fail=`cat $Profiles | wc -l`
        if [ $fail -ne 7 ]; then
                qntd_ix=`cat $Profiles | grep Index | wc -l`
                for NI in `cat -n $Profiles | grep Index | awk '{print $1}'`
                do
                        lf=`expr $NI + 16`
                        sed -n "$NI,$lf p" $Profiles > $NI.OK
                        index=`cat $NI.OK | grep Index | awk '{print $2}' | sed 's/ //g'`
                        status=`cat $NI.OK | grep ctive | sed 's/ //g'`
                        timeout=`cat $NI.OK | grep timeout | awk -F "=" '{print $2}' | sed 's/ //g'`
                        port=`cat $NI.OK | grep port | awk -F "=" '{print $2}' | sed 's/ //g'`
                        localip=`cat $NI.OK | grep localip | awk -F "=" '{print $2}' | sed 's/ //g'`
			IC=`$0 host $NomeProfile`
			server=`cat $NI.OK | grep server | awk -F "=" '{print $2}' | sed 's/ //g'`
			querytype=`cat $NI.OK | grep querytype | awk -F "=" '{print $2}' | sed 's/ //g'`
                        failureretests=`cat $NI.OK | grep failureretests | awk -F "=" '{print $2}' | sed 's/ //g'`
                        retestinterval=`cat $NI.OK | grep retestinterval | awk -F "=" '{print $2}' | sed 's/ //g'`
                        recursivelookups=`cat $NI.OK | grep recursivelookups | awk -F "=" '{print $2}' | sed 's/ //g'`
                        retries=`cat $NI.OK | grep retries | awk -F "=" '{print $2}' | sed 's/ //g'`
                        host=`cat $NI.OK | grep host | awk -F "=" '{print $2}' | sed 's/ //g'`
                        description=`cat $NI.OK | grep description  | awk -F "=" '{print $2}' | sed 's/ //g'`
                        poll=`cat $NI.OK | grep poll | awk -F "=" '{print $2}' | sed 's/ //g'`
                        rm $NI.OK
			echo "$Monitor;$IC;$NomeProfile;$index;$status;$timeout;$port;$querytype;$localip;$server;$failureretests;$retries;$recursivelookups;$host;$retestinterval;$description;$poll" | sed  $'s/\'//g' 
			echo "$Monitor;$IC;$NomeProfile;$index;$status;$timeout;$port;$querytype;$localip;$server;$failureretests;$retries;$recursivelookups;$host;$retestinterval;$description;$poll" | sed  $'s/\'//g' >> Booking-DNS.$data.csv                        
                done
        fi
done
}


http() {
echo "HTTP;IC;NomeProfile;Index;status;port;ProxyUsername;server;failureretests;ProxyPassword;hostnamelookuppreference;retestinterval;command;formname;page;localip;username;version;dynamiccontent;password;ProxyAuth;timeout;Proxy;ProxyPort;ProxyServer;AuthType;ProxyUsrPrx;ProxyNoCache;description;poll" | sed "s/'//g" > Booking-HTTP.$data.csv


for Profile in `ls profile/HTTP.*.profile`
do
        fail=`cat $Profile | wc -l`
        NomeProfile=`echo $Profile | cut -d "/" -f2 | awk -F "." '{print $2}'`
	for qntd_ics in `$0 host $NomeProfile | grep -v Encontrado`
	do
		echo $qntd_ics >> $NomeProfile.ICS
	done
	if [ -e $NomeProfile.ICS ]; then
	#echo		
		#echo "Profile: $NomeProfile possui `cat $NomeProfile.ICS | wc -l` hosts/servicos"
		#echo 
#		sleep 2s
       	rm $NomeProfile.ICS
	fi
	if [ $fail -ne 7 ]; then
                qntd_ix=`cat $Profile | grep Index | grep -v = | wc -l`
                        li_qntd_ix=`cat -n $Profile | grep "Index " | awk '{print $1}'`
                        for li_ix in `echo $li_qntd_ix`
                        do
                                lf=`expr $li_ix + 21` # 29 valor com proxy, 21 valor sem proxy
                                ll=`cat -n $Profile | grep -v "Checksum" | awk '{print $1" "$2}' | grep $lf | head -n 1 | awk '{print $2}'`
                                if [ "$ll" == "poll" ]; then
                                        lf=`expr $li_ix + 21`
                                        else
                                        lf=`expr $li_ix + 29`
                                fi
			
                        sed -n "$li_ix,$lf p" $Profile > $li_ix.OK
                        NomeProfile=`echo $Profile | cut -d "/" -f2 | awk -F "." '{print $2}'`
                        Index=`cat $li_ix.OK | grep "Index " | awk '{print $2}' | sed 's/ //g'`
                        status=`cat $li_ix.OK | grep ctive | sed 's/ //g'`
                        port=`cat $li_ix.OK | grep "port =" | grep -v Proxy  | awk -F "=" '{print $2}' | sed 's/ //g'`
                        ProxyUsername=`cat $li_ix.OK | grep proxy:username | awk -F "=" '{print $2}' | sed 's/ //g'`
              		IC=`./$0 host $NomeProfile`
			server=`cat $li_ix.OK | grep 'server =' | grep -v Proxy | awk -F "=" '{print $2}' | sed 's/ //g'`
                        failureretests=`cat $li_ix.OK | grep 'failureretests =' | awk -F "=" '{print $2}' | sed 's/ //g'`
                        ProxyPassword=`cat $li_ix.OK | grep 'Proxy:password =' | awk -F "=" '{print $2}' | sed 's/ //g'`
                        hostnamelookuppreference=`cat $li_ix.OK | grep hostnamelookuppreference | awk -F "=" '{print $2}' | sed 's/ //g'`
                        retestinterval=`cat $li_ix.OK | grep retestinterval | awk -F "=" '{print $2}' | sed 's/ //g'`
                        command=`cat $li_ix.OK | grep command | awk -F "=" '{print $2}' | sed 's/ //g'`
                        formname=`cat $li_ix.OK | grep formname | awk -F "=" '{print $2}' | sed 's/ //g'`
                        page=`cat $li_ix.OK | grep 'page =' | awk -F "=" '{print $2}' | sed 's/ //g'`
                        localip=`cat $li_ix.OK | grep localip | awk -F "=" '{print $2}' | sed 's/ //g'`
                        username=`cat $li_ix.OK | grep 'username ='| grep -v Proxy | awk -F "=" '{print $2}' | sed 's/ //g'`
                        version=`cat $li_ix.OK | grep version | awk -F "=" '{print $2}' | sed 's/ //g'`
                        dynamiccontent=`cat $li_ix.OK | grep dynamiccontent | awk -F "=" '{print $2}'  | sed 's/ //g'`
                        password=`cat $li_ix.OK | grep 'password =' | grep -v Proxy | awk -F "=" '{print $2}' | sed 's/ //g'`
                        ProxyAuth=`cat $li_ix.OK | grep Proxy:authenticationtype | awk -F "=" '{print $2}' | sed 's/ //g'`
                        timeout=`cat $li_ix.OK | grep timeout | awk -F "=" '{print $2}' | sed 's/ //g'`
                        Proxy=`cat $li_ix.OK | grep Proxy: | grep -v username | grep -v auth | grep -v pass | grep -v port | grep -v server | grep -v use | grep -v cache | awk -F "=" '{print $2}' | sed 's/ //g'`
                        ProxyPort=`cat $li_ix.OK | grep Proxy:port | awk -F "=" '{print $2}' | sed 's/ //g'`
                        ProxyServer=`cat $li_ix.OK | grep Proxy:server | awk -F "=" '{print $2}' | sed 's/ //g'`
                        AuthType=`cat $li_ix.OK | grep authenticationtype | grep -v Proxy:authenticationtype |awk -F "=" '{print $2}' | sed 's/ //g'`
                        ProxyUsrPrx=`cat $li_ix.OK | grep Proxy:useproxy | awk -F "=" '{print $2}' | sed 's/ //g'`
                        ProxyNoCache=`cat $li_ix.OK | grep proxy:nocache | awk -F "=" '{print $2}' | sed 's/ //g'`
                        description=`cat $li_ix.OK | grep description | awk -F "=" '{print $2}'`
                        poll=`cat $li_ix.OK | grep poll | awk -F "=" '{print $2}' | sed 's/ //g'`
			echo "HTTP;$IC;$NomeProfile;$Index;$status;$port;$ProxyUsername;$server;$failureretests;$ProxyPassword;$hostnamelookuppreference;$retestinterval;$command;$formname;$page;$localip;$username;$version;$dynamiccontent;$password;$ProxyAuth;$timeout;$Proxy;$ProxyPort;$ProxyServer;$AuthType;$ProxyUsrPrx;$ProxyNoCache;$description;$poll" | sed "s/'//g" 
                        echo "HTTP;$IC;$NomeProfile;$Index;$status;$port;$ProxyUsername;$server;$failureretests;$ProxyPassword;$hostnamelookuppreference;$retestinterval;$command;$formname;$page;$localip;$username;$version;$dynamiccontent;$password;$ProxyAuth;$timeout;$Proxy;$ProxyPort;$ProxyServer;$AuthType;$ProxyUsrPrx;$ProxyNoCache;$description;$poll" | sed "s/'//g" >> Booking-HTTP.$data.csv

                        rm -rf $li_ix.OK
                        done

                fi
done

}
https() {

echo "Monitor;IC;NomeProfile;index;status;port;ProxyUsername;server;failureretests;ProxyPassword;sslcertificatefile;hostnamelookuppreference;retestinterval;command;sslkeyfile;formname;page;localip;username;version;dynamiccontent;password;ProxyAuth;timeout;Proxy;ProxyPort;sslkeypassword;ProxyServer;authenticationtype;ProxyUseProxy;ProxyNoCache;description;poll" >  Booking-HTTPS.$data.csv

for Profiles in `ls profile/HTTPS.*.profile`
do
        Monitor=`echo $Profiles | cut -d "/" -f2| cut -d "." -f1`
        NomeProfile=`echo $Profiles | cut -d "." -f2`
        Prof=`echo  profile/$Monitor.$NomeProfile.profile`
        fail=`cat $Profiles | wc -l`
        if [ $fail -ne 7 ]; then
                qntd_ix=`cat $Profiles | grep "Index "| wc -l`
                        for NI in `cat -n $Profiles | grep "Index "| awk '{print $1}'`
                        do
                        lf=`expr $NI + 24`
                        ll=`cat -n $Profiles | grep -v "Checksum" | awk '{print $1" "$2}' | grep $lf | head -n 1 | awk '{print $2}'`
                        	if [ "$ll" == "poll" ]; then
                        		lf=`expr $NI + 24`
                        		else
                        		lf=`expr $NI + 32`
                        	fi

                        sed -n "$NI,$lf p" $Profiles > $NI.OK

                        index=`cat $NI.OK | grep "Index "| awk '{print $2}' | sed 's/ //g'`
                        status=`cat $NI.OK | grep ctive | sed 's/ //g'`
			port=`cat $NI.OK | grep "port =" | grep -v "Proxy" | awk -F "=" '{print $2}' | sed 's/ //g'`
			ProxyUsername=`cat $NI.OK | grep "Proxy:username" | awk -F "=" '{print $2}' | sed 's/ //g'`
			IC=`$0 host $NomeProfile`
			server=`cat $NI.OK | grep "server" | grep -v "Proxy" | awk -F "=" '{print $2}' | sed 's/ //g'`
			failureretests=`cat $NI.OK | grep "failureretests" | awk -F "=" '{print $2}' | sed 's/ //g'`
			ProxyPassword=`cat $NI.OK | grep "Proxy:password" | awk -F "=" '{print $2}' | sed 's/ //g'`
			sslcertificatefile=`cat $NI.OK | grep "sslcertificatefile" | awk -F "=" '{print $2}' | sed 's/ //g'`
			hostnamelookuppreference=`cat $NI.OK | grep "hostnamelookuppreference" | awk -F "=" '{print $2}' | sed 's/ //g'`
			retestinterval=`cat $NI.OK | grep "retestinterval" | awk -F "=" '{print $2}' | sed 's/ //g'`
			command=`cat $NI.OK | grep "command" | awk -F "=" '{print $2}' | sed 's/ //g'`
			sslkeyfile=`cat $NI.OK | grep "sslkeyfile" | awk -F "=" '{print $2}' | sed 's/ //g'`
			formname=`cat $NI.OK | grep "formname" | awk -F "=" '{print $2}' | sed 's/ //g'`
			page=`cat $NI.OK | grep "page" | awk -F "=" '{print $2}' | sed 's/ //g'`
			localip=`cat $NI.OK | grep "localip" | awk -F "=" '{print $2}'  | sed 's/ //g'`
			username=`cat $NI.OK | grep "username" | grep -v "Proxy" | awk -F "=" '{print $2}' | sed 's/ //g'`
			version=`cat $NI.OK | grep "version" | awk -F "=" '{print $2}' | sed 's/ //g'`
			dynamiccontent=`cat $NI.OK | grep "dynamiccontent" | awk -F "=" '{print $2}' | sed 's/ //g'`
			password=`cat $NI.OK | grep "password" | grep -v "sslkey" | grep -v "Proxy" | awk -F "=" '{print $2}' | sed 's/ //g'`
			ProxyAuth=`cat $NI.OK | grep "Proxy:authenticationtype" | awk -F "=" '{print $2}' | sed 's/ //g'`
			timeout=`cat $NI.OK | grep "timeout" | awk -F "=" '{print $2}' | sed 's/ //g'`
			Proxy=`cat $NI.OK | grep "Proxy: " | awk -F "=" '{print $2}' | sed 's/ //g'`
			ProxyPort=`cat $NI.OK | grep "Proxy:port" | awk -F "=" '{print $2}' | sed 's/ //g'`
			sslkeypassword=`cat $NI.OK | grep "sslkeypassword " | awk -F "=" '{print $2}' | sed 's/ //g'`
			ProxyServer=`cat $NI.OK | grep "Proxy:server " | awk -F "=" '{print $2}' | sed 's/ //g'`
			authenticationtype=`cat $NI.OK | grep "authenticationtype" | grep -v "Proxy" | awk -F "=" '{print $2}' | sed 's/ //g'`
			ProxyUseProxy=`cat $NI.OK | grep "Proxy:useproxy" | awk -F "=" '{print $2}' | sed 's/ //g'`
			ProxyNoCache=`cat $NI.OK | grep  "Proxy:nocache" | awk -F "=" '{print $2}' | sed 's/ //g'`
			description=`cat $NI.OK | grep "description" | awk -F "=" '{print $2}'`
			poll=`cat $NI.OK | grep "poll" | awk -F "=" '{print $2}' | sed 's/ //g'`
			
                        rm $NI.OK
                        echo "$Monitor;$IC;$NomeProfile;$index;$status;$port;$ProxyUsername;$server;$failureretests;$ProxyPassword;$sslcertificatefile;$hostnamelookuppreference;$retestinterval;$command;$sslkeyfile;$formname;$page;$localip;$username;$version;$dynamiccontent;$password;$ProxyAuth;$timeout;$Proxy;$ProxyPort;$sslkeypassword;$ProxyServer;$authenticationtype;$ProxyUseProxy;$ProxyNoCache;$description;$poll" | sed $'s/\'//g'
			echo "$Monitor;$IC;$NomeProfile;$index;$status;$port;$ProxyUsername;$server;$failureretests;$ProxyPassword;$sslcertificatefile;$hostnamelookuppreference;$retestinterval;$command;$sslkeyfile;$formname;$page;$localip;$username;$version;$dynamiccontent;$password;$ProxyAuth;$timeout;$Proxy;$ProxyPort;$sslkeypassword;$ProxyServer;$authenticationtype;$ProxyUseProxy;$ProxyNoCache;$description;$poll" | sed $'s/\'//g' >> Booking-HTTPS.$data.csv
                        done
        fi
done

}


case $1 in
	all)	icmp;
		http;
		https;
		smtp;
		dns;
	;;
	host)	host;
	;;
	situ)	situ;
	;;
	icmp)	icmp;
	;;
	https)	https;
	;;
	http)	http;
	;;
	smtp)	smtp;
	;;
	dns)	dns;
	;;
	*) echo "dns icmp https http smtp"	
	;;
esac
