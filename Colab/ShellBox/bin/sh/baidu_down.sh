#!/bin/bash
OLD_IFS=$IFS
IFS=$(echo -en "\n\b")
echo -e "${yellow}[INFO]${plain}获取BDSTOKEN中......"
filetxt=${TEMP_DOWN_PATH}/list.txt
[ ! -f ${filetxt} ] && touch ${filetxt}
fileno=0
[ -z ${KEYCOOKIES} ] && export KEYCOOKIES="$(echo $COOKIES | grep -oE 'BDUSS=([[:alnum:]]|[[:punct:]])+;') $(echo $COOKIES | grep -oE 'STOKEN=[[:alnum:]]+;')"
[ -z ${BDSTOKEN} ] && export BDSTOKEN=$(curl -s --cookie "${KEYCOOKIES}" "https://pan.baidu.com/disk/home/" | grep -oE 'bdstoken[[:punct:]]+ [[:punct:]]+[[:alnum:]]+') && BDSTOKEN=${BDSTOKEN##*\'}
[[ ${USER_OS} == 2 ]] && CONC_FLAG=0 || CONC_FLAG=2
if [[ ${OD} == 1 ]]
then
	DOWN_PATH=${TEMP_DOWN_PATH}
else
	DOWN_PATH=$1
fi
clear
#-------------------------------------------------------
DRAWLINE(){
	echo -e "${yellow}================================================================================${plain}"
}
DOWN_MULTI(){
	temp_fifo="/tmp/$$.fifo"
	mkfifo ${temp_fifo}
	exec 5<>${temp_fifo}
	rm -f ${temp_fifo}
	for ((i=0;i<$1;i++))
	do
    	echo >&5
    done
}
BAIDU_DIR_INI(){
	while true
	do
		if [[ $(bd mkdir ${TEMP_BAIDU_DOWN_PATH}) =~ "31061" ]] || [[ $(bd mkdir ${TEMP_BAIDU_DOWN_PATH}) =~ "成功" ]]
		then
			break
		else
			bd mkdir ${TEMP_BAIDU_DOWN_PATH} > /dev/null 2>&1
		fi
	done
	while true
	do
		if [[ $(bd mv ${TEMP_BAIDU_DOWN_PATH}* /) =~ "成功" ]]
		then
			break
		else
			bd mv ${TEMP_BAIDU_DOWN_PATH}* / > /dev/null 2>&1
		fi
	done
	while true
	do
		if [[ ! $(bd pwd) == ${TEMP_BAIDU_DOWN_PATH%\/*} ]]
		then
			bd cd ${TEMP_BAIDU_DOWN_PATH} > /dev/null 2>&1
		else
			break
		fi
	done
	DRAWLINE
}
TRANS(){
	link=0
	key=0
	echo -e -n "${green}[ 留空停止转存 ]请输入分享链接:${plain}"
    read -r link
    if [[ -z ${link} ]]
    then
    	echo -e "${yellow}[ INFO ]本次無轉存文件,即將開始下載文件....${plain}"
    	DRAWLINE
        return 0
    else
        if [[ ${link} =~ "https" ]]
        then
            link=${link#https\:\/\/*}
            echo -e -n "${yellow}[ 留空停止转存 ]請輸入密碼:${plain}"
            read -r key
            echo -e "${red}[ INFO ]${plain}轉存中"
            bd transfer ${link} ${key}
        else
            echo -e "${red}[ INFO ]${plain}轉存中"
            BDRAPID ${link}
        fi
        DRAWLINE
        return 1
    fi
}
BDRAPID(){
	IFS=" "
	if [[ ${1} =~ "bdpan://" ]]
	then
		linkarr=($(echo ${1:8}| base64 -d | tr ' ' '_' |tr '|' ' '))
		linkarr[0]=$(echo ${linkarr[3]}|hexdump -v -e '"\\" /1 "%02x"'|tr '\\' '%')
		curl -s --cookie "${KEYCOOKIES}" -d "path=/ShellBox/${linkarr[0]}&content-length=${linkarr[1]}&content-md5=${linkarr[2]}&slice-md5=${linkarr[3]}" -X POST "https://pan.baidu.com/api/rapidupload?app_id=250528&bdstoken=${BDSTOKEN}&channel=chunlei&clienttype=0&rtype=1&web=1" > ${TEMP_PATH}/res.json
	else
		linkarr=($(echo ${1} | tr ' ' '_' | tr '#' ' '))
		linkarr[3]=$(echo ${linkarr[3]}|hexdump -v -e '"\\" /1 "%02x"'|tr '\\' '%')
		curl -s --cookie "${KEYCOOKIES}" -d "path=/ShellBox/${linkarr[3]}&content-length=${linkarr[2]}&content-md5=${linkarr[0]}&slice-md5=${linkarr[1]}" -X POST "https://pan.baidu.com/api/rapidupload?app_id=250528&bdstoken=${BDSTOKEN}&channel=chunlei&clienttype=0&rtype=1&web=1" > ${TEMP_PATH}/res.json
	fi
	ERR=$(cat ${TEMP_PATH}/res.json | grep -oE "\"errno\":-?[[:alnum:]]") && ERR=${ERR##*\:}
	case $ERR in
		0)
			echo -e "${green}[INFO]${plain}保存成功"
			;;
		2)
			echo -e "${red}[INFO]${plain}保存失败，请重新登录"
			;;
		6)
			echo -e "${red}[INFO]${plain}Cookie已过期，请重新登录"
			;;
		4)
			echo -e "${red}[INFO]${plain}服务器无相关文件，请检查快链"
			;;
		8)
			echo -e "${red}[INFO]${plain}已有同名文件"
			;;
		1)
			echo -e "${red}[INFO]${plain}容量不足"
			;;
		*)
			echo -e "${red}[INFO]${plain}未知错误"
			;;
		esac
		IFS=$(echo -en "\n\b")
}
CONC_PATH(){
	a=$1
	if [[ ${CONC_FLAG} == 0 ]]
	then
		a=${a#*/} && a=${a#*/}
		disk=${a:0:1} && disk=$(echo ${disk} | tr 'a-z' 'A-Z')
		a=${disk}:${a:1} && a=${a////\\}
		CONC_FLAG=1
	fi
}
REVERS_PATH(){
	a=$1
	if [[ ${CONC_FLAG} == 1 ]]
	then
		drive=${a:0:1} && drive=$(echo ${drive} | tr 'A-Z' 'a-z')
		a=${a#*\\}
		a=/cygdrive/${drive}/${a//\\//}
		CONC_FLAG=0
	fi
}
DOWNLOAD(){
	rm -rf ${filetxt} > /dev/null 2>&1
	echo -e "${yellow}[INFO]${plain}正在獲取下載清單......"
	DRAWLINE
	bd match ${TEMP_BAIDU_DOWN_PATH}* > ${filetxt}
	if [[ -f ${filetxt} ]]
	then
    	fileno=$(wc -l ${filetxt})
    	fileno=${fileno%%\ *}
    	while [[ ${fileno} > 0 ]]
    	do
    	    dummy=`expr ${fileno} - 1 `
    	    file[${dummy}]=$(tail -${fileno} ${filetxt}|head -1)
    	    echo -e "${green}${file[${dummy}]}${plain}"
    	    fileno=`expr ${fileno} - 1 `
    	done
    	fileno=${file[@]}
    	echo -e -n "${red}即將下載以上文件 | 按下 <Enter> 進行確認:${plain}"
    	read -n 1
    	rm -f ${filetxt}
    	DRAWLINE
		CONC_PATH ${DOWN_PATH} && DOWN_PATH=${a}
    	for i in ${file[*]}
    	do
    	    read -u5
        	{
        	    bd d --nocheck -mode locate --ow --retry 10 --saveto "${DOWN_PATH}" ${i}
        	    echo >&5
        	}&
    	done
    	wait
		exec 5>&-
    	for i in ${file[*]}
    	do
	    	{
	    	    bd rm ${i}
	    	}&
    	done
    	wait
    	DRAWLINE
    	echo -e "${blue} 下载完成${plain}"
    	DRAWLINE
	else
	    echo -e "${red}| 获取失败 | 請回報Bug |${plain}"
	    DRAWLINE
	    sleep 2s && exit 2
	fi
	[[ ${OD} == 1 ]] && [[ ${CHOICE} == 2 ]] && rclone move ${DOWN_PATH} OneDrive:/ -v --transfers=${MAXPARALLEL} --cache-chunk-size 16M --no-traverse --config "${RCLONE}"
}
BAIDU_DOWN_TITLE(){
echo -e "${yellow} BaiduPCS-Go 辅助下载插件 ver0.3.0 | By:GetIntoBus ${plain}"
DRAWLINE
echo -e "${yellow} 正在初始化 ${plain}"
DRAWLINE
}
#-------------------------------------------------------
BAIDU_DOWN_TITLE
DOWN_MULTI ${MAXPARALLEL}
BAIDU_DIR_INI
while [[ true ]]
do
	TRANS
	if [[ $? == 0 ]]
	then
		break
	fi
done
DOWNLOAD
REVERS_PATH ${DOWN_PATH} && DOWN_PATH=${a}
IFS=$OLD_IFS