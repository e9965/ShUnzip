#!/bin/bash
OLD_IFS=$IFS
IFS=$(echo -en "\n\b")
#-------------------------------------------------------------------
[[ ${USER_OS} == 2 ]] && CONC_FLAG=0 || CONC_FLAG=2
DRAWLINE(){
	echo -e "${yellow}================================================================================${plain}"
}
UNZIP_MULTI(){
	temp_fifo="/tmp/$$.fifo"
	mkfifo ${temp_fifo}
	exec 4<>${temp_fifo}
	rm -f ${temp_fifo}
	for ((i=0;i<${1};i++))
	do
    	echo >&4
    done
}
CONC_PATH(){
	a=$1
	if [[ ${CONC_FLAG} == 0 ]]
	then
		a=${a#*/} && a=${a#*/}
		disk=${a:0:1} && disk=$(echo ${disk} | tr 'a-z' 'A-Z')
		a=${disk}:${a:1} && a=${a////\\}
		[ -z ${2} ] && CONC_FLAG=1
	fi
}
REVERS_PATH(){
	a=${1}
	if [[ ${CONC_FLAG} == 1 ]]
	then
		drive=${a:0:1} && drive=$(echo ${drive} | tr 'A-Z' 'a-z')
		a=${a#*\\}
		a=/cygdrive/${drive}/${a//\\//}
		CONC_FLAG=0
	fi
}
CHECK_ARC(){
	checkarc=$(file -b ${1}) && checkarc=${checkarc%%\ *}
	case ${checkarc} in
		RAR|rar|Rar|7-zip|7-Zip|7-Z|7-z|7z|7Z|7-ZIP|Zip|ZIP)
		return 1
			;;
		*)
		return 0
			;;
	esac
}
CHECKINPUT(){
if [[ $1 == 1 ]]
then
	INPUT_DIR=${TEMP_DOWN_PATH}
else
	if [[ ${INPUT_DIR} == "FLASE" ]]
	then
		echo -e "${blue}[INFO]${plain}填寫壓縮包目錄實現本地自動解壓 - 支持拖動 - 不可留空"
		while true
		do
			echo -en "${yellow}[INPUT]${plain}請輸入你的${green}壓縮包的目錄${plain}:"
			read -r INPUT_DIR
			if [[ -d ${INPUT_DIR} ]]
			then
				echo -e "${green}[INFO]${plain}成功設置為$(echo ${INPUT_DIR}| tr '\\' '/')"
				break
			else
				echo -ne "${sound}"
				echo -e "${red}[INFO]${plain}請輸入正確的目錄"
			fi
		done
	fi
fi
}
UNZIP_TITLE(){
DRAWLINE
echo -e "自動解壓插件 Ver.0.0.1 By:GetIntoBus"
DRAWLINE
}
ENSURE_PATH(){
	mkdir -p ${TEMP_UNZIP_PATH} > /dev/null 2>&1
	mkdir -p ${OUT_DIR} > /dev/null 2>&1
}
UNZIP_INITIALIZED(){
	UNZIP_TITLE
	echo -e "${blue}[INFO]${plain}初始化中......"
	DRAWLINE
	CHECKINPUT $1
	echo -e "${blue}[INFO]${plain}完成初始化"
	DRAWLINE
}
SET_TEMP_FILE_LIST(){
	rm -rf ${TEMP_FILE_LIST} > /dev/null 2>&1
	touch ${TEMP_FILE_LIST} > /dev/null 2>&1
}
SET_FAIL_FILE_LIST(){
	rm -rf ${FAIL_FILE_LIST} > /dev/null 2>&1
	touch ${FAIL_FILE_LIST} > /dev/null 2>&1
}
SET_SUCC_FILE_LIST(){
	rm -rf ${SUCC_FILE_LIST} > /dev/null 2>&1
	touch ${SUCC_FILE_LIST} > /dev/null 2>&1
}
DEL_BLANK_FOLDER(){
	find ${TEMP_PATH} -type d -empty -delete
}
COLAB_TEMP_MV(){
    if [[ ${USER_OS} == 1 ]]
    then
        touch ${TEMP_FILE_LIST}.tmp
        for i in $(cat ${TEMP_FILE_LIST})
        do
            rsync --remove-source-files --info=progress2 --no-inc-recursive -zrI "${i}" "${TEMP_DOWN_PATH}/${i##*\/}"
            echo ${TEMP_DOWN_PATH}/${i##*\/} >> ${TEMP_FILE_LIST}.tmp
        done
        rm -rf ${TEMP_FILE_LIST}
        mv ${TEMP_FILE_LIST}.tmp ${TEMP_FILE_LIST}
    fi
}
CHECK_TEMP_DIR(){
	if [ ! -d  ${TEMP_DOWN_PATH} ]
	then
		mkdir -p ${TEMP_DOWN_PATH}
	fi
	if [ ! -d ${TEMP_UNZIP_PATH} ]
	then
		mkdir -p ${TEMP_UNZIP_PATH}
	fi
}
METHOD(){
	echo -e -n "${yellow}[INFO]${plain}是否仅提取文件/无文件夹结构[默认为Y|输入任意字符取消]:"
	read ex
	if [ -z ${ex} ]
	then
		ex=e
	else
		ex=x
	fi
}
#-------------------------------------------------------------------
NUM_RUN=0
FILE_NUM=0
TEMP_FILE_LIST=${TEMP_PATH}/list.txt
FAIL_FILE_LIST=${TEMP_PATH}/fail_list.txt
SUCC_FILE_LIST=${TEMP_PATH}/succ_list.txt
DUMMY="."
TRY_PASS=""
UNZIP_INITIALIZED $1
SET_SUCC_FILE_LIST
CHECK_TEMP_DIR
[ ${AUTO} -eq 1 ] && METHOD
clear
#-------------------------------------------------------------------
while true
do
	let "NUM_RUN++"
	echo -e "${green}[INFO]${plain}開始第[ ${NUM_RUN} ]輪的解壓"
	DRAWLINE
	ENSURE_PATH
	echo -e "${yellow}[INFO]${plain}正在尋找壓縮文件中......"
	CHECKFILES_LIST=$(find ${INPUT_DIR} -type f -name "*" )
	UNZIP_MULTI 50
	wait
	SET_TEMP_FILE_LIST
	SET_FAIL_FILE_LIST
	for i in ${CHECKFILES_LIST}
	do
		read -u4
		{
			CHECK_ARC $i
			if [[ $? == 1 ]]
			then
				echo "$i" >> ${TEMP_FILE_LIST}
			fi
			echo >&4
		}&
	done
	wait
	exec 4>&-
	if [[ ${NUM_RUN} > 1 ]]
	then
		CHECKFILES_LIST=$(find ${TEMP_UNZIP_PATH} -type f -name "*" )
		UNZIP_MULTI 50
		wait
		for i in ${CHECKFILES_LIST}
		do
			read -u4
			{
				CHECK_ARC $i
				if [[ $? == 1 ]]
				then
					echo "$i" >> ${TEMP_FILE_LIST}
				fi
				echo >&4
			}&
		done
		wait
		exec 4>&-
	fi
	echo -e "${green}[INFO]${plain}完成尋找壓縮文件"
	echo -e "${yellow}[INFO]${plain}正在處理壓縮文件中......"
	COLAB_TEMP_MV
	for i in $(cat ${TEMP_FILE_LIST}| sort -n)
	do
		if [[ ${DUMMY%%.*} != ${i%%.*} ]]
		then
			CONC_PATH ${i} 0
			FILE_LIST[${FILE_NUM}]=${a}
			DUMMY=${i}
			let "FILE_NUM++"
		fi
	done
	CONC_PATH ${TEMP_UNZIP_PATH} && TEMP_UNZIP_PATH=${a}
	if [[ ${#FILE_LIST[@]} > 0 ]]
	then
		echo -e "${yellow}[INFO]${plain}正在解壓文件中......"
		UNZIP_MULTI ${UNZIP_THREAD}
		wait
		for i in ${FILE_LIST[@]}
		do
			read -u4
			{
				[[ ${USER_OS} == 2 ]] && a=${i##*\\} || a=${i##*\/}
				for TRY_PASS in ${PASSWD[@]}
				do
					7z ${ex} -y -r -bsp1 -bso0 -bse0 -aot -p${TRY_PASS} -o${TEMP_UNZIP_PATH}${a} ${i}
					if [[ $? != 2 ]]
					then
						echo "[ ${i##*\/} ] | 解壓密碼: [ ${TRY_PASS} ]" >> ${SUCC_FILE_LIST}
						break
					else
						if [[ ${TRY_PASS} == ${PASSWD[-1]} ]]
						then
							echo ${i} >> ${FAIL_FILE_LIST}
							break
						fi
					fi
				done
				echo >&4
			}&
		done
		wait
		exec 4>&-
	#Start The Process of The Wrong Pass Arc
		for i in $(cat ${FAIL_FILE_LIST})
		do
			while true
			do
				echo -ne "${sound}"
				echo -ne "${red}[INFO]${plain}錯誤密碼 | 直接回車進行跳過 | 請輸入${i##\/}的解压密码:"
				read TRY_PASS
				if [[  ${TRY_PASS} != "" ]]
				then
					7z ${ex} -y -r -aot -p${TRY_PASS} -o${TEMP_UNZIP_PATH}${a} ${i}
					if [[ $? != 2 ]]
					then
						break
					fi
				else
					if [[ ${OD} == 0 ]]
					then
						rsync --remove-source-files --info=progress2 --no-inc-recursive -zrI ${i} ${OUT_DIR}
					else
						rclone move ${i} OneDrive:/ -v --transfers=${MAXPARALLEL} --cache-chunk-size 16M --no-traverse --config "${RCLONE}"
					fi
					break
				fi
			done
		done
	#End for the The Process of The Wrong Pass Arc
	#Remove All Succ File
		for i in $(cat ${TEMP_FILE_LIST})
		do
			rm -f ${i}
		done
		clear
	#End For Remove
		unset FILE_LIST
	else
		echo -e "${red}[INFO]${plain}已無壓縮文檔需要解壓"
		break
	fi
done
DRAWLINE
echo -e "${green}[INFO]${plain}以下文件解壓成功:"
cat ${SUCC_FILE_LIST}
DRAWLINE
echo -e "${yellow}[INFO]${plain}正在移往解壓目錄"
DEL_BLANK_FOLDER > /dev/null 2>&1
REVERS_PATH ${TEMP_UNZIP_PATH} && TEMP_UNZIP_PATH=${a}
if [[ ${OD} == 0 ]]
then
	rsync --remove-source-files --info=progress2 --no-inc-recursive -zrI ${TEMP_UNZIP_PATH} ${OUT_DIR}
else
	rclone move ${TEMP_UNZIP_PATH} OneDrive:/ -v --transfers=${MAXPARALLEL} --cache-chunk-size 16M --no-traverse --config "${RCLONE}"
fi
DEL_BLANK_FOLDER > /dev/null 2>&1
wait
echo -e "${green}[INFO]${plain}移動完成"
#-------------------------------------------------------------------
IFS=$OLD_IFS
