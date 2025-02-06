
trepa="F"

to-config(){
str_col=$(grep -c "" $API_FOLDER"api.txt")
rm -f $API_FOLDER"api1.txt" && touch $API_FOLDER"api1.txt"

for (( i=1;i<=$str_col;i++)); do
test=$(sed -n $i"p" $API_FOLDER"api.txt")
if [ "$i" -eq "$mi_num" ]; then
	echo $ch":"$req >> $API_FOLDER"api1.txt"
else
	echo $test >> $API_FOLDER"api1.txt"
fi
done

cp -f $API_FOLDER"api1.txt" $API_FOLDER"api.txt"
}

if [[ "${REQUEST}" == /in* ]];then	#/in_chat_req -> OK
	trepa="K"
	ch=$(echo $REQUEST | awk -F"_" '{print $2}')
	req=$(echo $REQUEST | awk -F"_" '{print $3}')
	if ! [ -z "$ch" ] && ! [ -z "$req" ]; then
		if [[ $ch =~ ^[0-9]+$ ]] && [[ $req =~ ^[0-9]+$ ]]; then
			mi_num=$(cat $API_FOLDER"api.txt" | grep -n $ch":" | awk -F":" '{print $1}' | tr -d '\r')
			if ! [ -z "$mi_num" ]; then
				to-config;
				echo "$(date '+%Y-%m-%d %H:%M:%S')  | CHANGE "$ch":"$req
			else
				echo $ch":"$req >> $API_FOLDER"api.txt"
				echo "$(date '+%Y-%m-%d %H:%M:%S')  | ADD "$ch":"$req
			fi
			reply "200 OK           "
		else
			error
		fi
	else
		error
	fi
fi
if [[ "${REQUEST}" == /out* ]];then	#/out_chat  -> req
	trepa="K"
	ch=$(echo $REQUEST | awk -F"_" '{print $2}')
	if ! [ -z "$ch" ] && [[ $ch =~ ^[0-9]+$ ]]; then
		mi_num=$(cat $API_FOLDER"api.txt" | grep -n $ch":" | awk -F":" '{print $1}' | tr -d '\r')
		if ! [ -z "$mi_num" ]; then
			req=$(sed -n $mi_num"p" $API_FOLDER"api.txt"| awk -F":" '{print $2}' | tr -d '\r')
			echo "$(date '+%Y-%m-%d %H:%M:%S')  | OUT "$ch":"$req
			reply "200 OK      |"$req
		else
			error
		fi
	else
		error
	fi
fi
if [[ "${REQUEST}" == "/ping" ]];then
	trepa="K"
	echo "$(date '+%Y-%m-%d %H:%M:%S')  | PONG "
	reply "200 OK | PONG"
fi
if [[ "${REQUEST}" == "/cls" ]];then
	trepa="K"
	cp -f $API_FOLDER"api.txt" $API_FOLDER"bkp_api_"$(date '+%Y%m%d%H%M%S')".txt"
	rm -f $API_FOLDER"api.txt"
	touch $API_FOLDER"api.txt"
	echo "$(date '+%Y-%m-%d %H:%M:%S')  | CLS "
	reply "200 OK |    CLS"
fi

[ "$trepa" = "F" ] && error;
