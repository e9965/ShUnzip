#!/bin/bash
OLD_IFS=$IFS
IFS=$(echo -en "\n\b")
#------------------------------------------------------------------
WGET_FILE=${TEMP_UNZIP_PATH}mangalist
NAME_FILE=${TEMP_UNZIP_PATH}namelist
NOL=0
unset LINKARRY
unset MANGA
#------------------------------------------------------------------
DRAWLINE(){
	echo -e "${yellow}================================================================================${plain}"
}
DOWN_MULTI(){
    temp_fifo="/tmp/$$.fifo"
	mkfifo ${temp_fifo}
	exec 4<>${temp_fifo}
	rm -f ${temp_fifo}
	for ((i=0;i<${1};i++))
    do 
        echo >&4
    done
}
GET_E_HENTAI_SRC(){
    TEMP_NUM=${1}
    WEB=${2}
    wget -qO ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html --no-check-certificate --header="${EHENTAI_COOKIE}" "${WEB}"
    WEB=$(echo ${WEB} | grep -m 1 -oE "e(-|x)hentai.org")
    echo -e "${green}[INFO]${plain}成功分析漫画網頁代碼"
    #Get the html
    GID=$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE 'gid = [[:alnum:]]+') && GID=${GID##*\ }
    echo -e "${green}[INFO]${plain}成功分析漫画GID為[${GID}]"
    #Get Gid
    NAME=$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE "gn\">[^<]+" | head -1) && NAME=${NAME#*\>} && NAME=${NAME//&lt;/\[} && NAME=${NAME//&gt;/\]}
    echo -e "${green}[INFO]${plain}成功分析漫画标题為[${NAME}]"
        #Store the Temp Name
        echo "${TEMP_NUM}:${NAME}" >> ${NAME_FILE}
    #Get Title
    PAGES=$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE '[[:alnum:]]+ pages') && PAGES=${PAGES%\ *}
    echo -e "${green}[INFO]${plain}成功分析漫画页数為[${PAGES}]"
    #Get Pages
    mkdir -p "${TEMP_UNZIP_PATH}${NAME}" > /dev/null 2>&1
    CLEARFILE ${WGET_FILE}${TEMP_NUM}
    echo -e "${yellow}[INFO]${plain}開始分析漫画圖源直連"
    for ((i=1;i<=${PAGES};i++))
    do
        wget -O ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html --no-check-certificate --header="${EHENTAI_COOKIE}" "$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE "https://${WEB}/s/[[:alnum:]]+/${GID}-${i}" | head -1)"
        [[ ! $? == 0 ]] && echo -e "${red}[ERROR]${plain}請求數量過多，取得鏈接錯誤，請檢查網絡&Cookie並匯報BUG" && exit 2
        LINK=$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE 'img" src="[^"]+') && LINK=${LINK##*\"}
        echo "wget --no-check-certificate --show-progress -qO \"${TEMP_UNZIP_PATH}${NAME}/${i}.${LINK##*.}\" \"${LINK}\" " >> "${WGET_FILE}${TEMP_NUM}"
    done
    CLEARFILE ${WGET_FILE}${TEMP_NUM}.sh
    a=($(cat ${WGET_FILE}${TEMP_NUM}))
    for ((i=0;i<$((${#a[@]}-1));i++))
    do
        [[ $((${i}%5)) = 0 ]] && echo -ne "${a[${i}]}\nwait\n" >>  ${WGET_FILE}${TEMP_NUM}.sh
        echo -ne "${a[${i}]} & " >>  ${WGET_FILE}${TEMP_NUM}.sh
    done
    echo -ne "${a[${i}]}" >>  ${WGET_FILE}${TEMP_NUM}.sh
    unset a && unset i
    echo -e "${green}[INFO]${plain}成功写入所有图源链接"
}
GET_N_HENTAI_SRC(){
    TEMP_NUM=${1}
    WEB=${2}
    wget -qO ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html --no-check-certificate "${WEB}"    
    echo -e "${green}[INFO]${plain}成功分析漫画網頁代碼"
    #Get the html
    GID=$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE 's/[[:alnum:]]+' | head -1 ) && GID=${GID##*\/}
    echo -e "${green}[INFO]${plain}成功分析漫画GID為[${GID}]"
    #Get Gid
    NAME=$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE "tty[^<]+" | head -1 ) && NAME=${NAME#*\>} && NAME=${NAME//&lt;/\[} && NAME=${NAME//&gt;/\]}
    echo -e "${green}[INFO]${plain}成功分析漫画标题為[${NAME}]"
        #Store the Temp Name
        echo "${TEMP_NUM}:${NAME}" >> ${NAME_FILE}
    #Get Title
    PAGES=$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE 'e\">[[:digit:]]+') && PAGES=${PAGES#*\>}
    echo -e "${green}[INFO]${plain}成功分析漫画页数為[${PAGES}]"
    #Get Pages
    wget -qO ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html --no-check-certificate "${WEB}/1/"
    IMG_TYPE=$(cat ${TEMP_UNZIP_PATH}TEMP${TEMP_NUM}.html | grep -m 1 -oE "${GID}/[[:alnum:]]+\.[[:alnum:]]+" | head -1 ) && IMG_TYPE=${IMG_TYPE##*\.}
    #Get Type
    mkdir -p "${TEMP_UNZIP_PATH}${NAME}" > /dev/null 2>&1
    CLEARFILE ${WGET_FILE}${TEMP_NUM}
    echo -e "${yellow}[INFO]${plain}開始分析漫画圖源直連"
    for ((i=1;i<=${PAGES};i++))
    do
        echo "wget --no-check-certificate --show-progress -qO \"${TEMP_UNZIP_PATH}${NAME}/${i}.${IMG_TYPE}\" \"https://i.nhentai.net/galleries/${GID}/${i}.${IMG_TYPE}\" " >> "${WGET_FILE}${TEMP_NUM}"
    done
    CLEARFILE ${WGET_FILE}${TEMP_NUM}.sh
    a=($(cat ${WGET_FILE}${TEMP_NUM}))
    for ((i=0;i<$((${#a[@]}-1));i++))
    do
        [[ $((${i}%50)) = 0 ]] && echo -ne "${a[${i}]}\nwait\n" >>  ${WGET_FILE}${TEMP_NUM}.sh
        echo -ne "${a[${i}]} & " >>  ${WGET_FILE}${TEMP_NUM}.sh
    done
    echo -ne "${a[${i}]}" >>  ${WGET_FILE}${TEMP_NUM}.sh
    unset a && unset i
    echo -e "${green}[INFO]${plain}成功写入所有图源链接"
}
CLEARFILE(){
    touch ${1} > /dev/null 2>&1
    > ${1}
}
NHENTAI_TITLE(){
    DRAWLINE
    echo -e "${yellow} [ EHentai/NHentai ] ${red}下載工具 ver0.01 | By:GetIntoBus${plain}"
    DRAWLINE
}

ASK_MANGA(){
    echo -ne "${green}[INPUT]${plain}請輸入漫畫網址:"
    read TEMPLINK
    if [[ ${TEMPLINK} == "" ]]
    then
        DRAWLINE
        return 1
    else
        case ${TEMPLINK} in
            https://e-hentai.org*)
                LINKARRY[${NOL}]="0:${TEMPLINK}"
                ;;
            https://exhentai.org*)
                if [ -z ${EHENTAI_COOKIE} ]
                then
                    echo -e "${red}[ERROR]${plain}缺少Cookie..."
                    echo -en "${yellow}[INFO]${plain}請輸入你的ExHentai Cookie [留空Enter跳過下載]:"
                    read -r EHENTAI_COOKIE
                    [ -z ${EHENTAI_COOKIE} ] && return 0 || EHENTAI_COOKIE="Cookie: ${EHENTAI_COOKIE}"
                fi
                LINKARRY[${NOL}]="0:${TEMPLINK}"
                ;;
            https://nhentai.net*)
                LINKARRY[${NOL}]="1:${TEMPLINK}"
                ;;
                *)
                echo -e "${red}[ERROR]${plain}僅支持EHentai/NHentai漫畫，請檢查鏈接"
                return 0
                ;;
        esac
        let "NOL++"
        echo -e "${green}[INFO]${plain}成功存入链接${LINKARRY[${NOL}]}"
        DRAWLINE
        return 0
    fi
}
DOWNLOAD_MANGA(){
    DRAWLINE
    unset i && i=0
    for ((i=0;i<${#MANGA[@]};i++))
    do
        read -u4
        {
            echo -e "${yellow}[INFO]${plain}开始下载漫画: [ ${yellow}${MANGA[${i}]}${plain} ]"
            source ${WGET_FILE}${i}.sh
            echo -e "${green}[INFO]${plain}下载漫画: [ ${yellow}${MANGA[${i}]}${plain} ]完成"
            echo >&4
        }&
    done
    wait
    exec 4>&-
}
ASK_MULTI(){
    while true
    do
        unset multi
        echo -en "${green}[INFO]${plain}請輸入漫畫下載並行數|默认为:<${UNZIP_THREAD}> :"
        read multi
        if [[ ${multi} == "" ]]
        then
            multi=${UNZIP_THREAD}
        fi
        case ${multi} in
        [1-9])
                break
                ;;
            *)
                echo -en "${sound}"
                echo -e "${red}[ERROR]${plain}請設置合理數值:"
                ;;
        esac
    done
    DRAWLINE
    return ${multi}
}
DISPLAY_MANGA_LIST(){
    rm -rf *.html
    unset i && i=0
    echo -e "${yellow}[INFO]${plain}即將下載以下漫畫:"
    while (( ${i} < ${#MANGA[@]} ))
    do
        echo -e "編號[${i}]: ${MANGA[${i}]}"
        let "i++"
    done
}
CONC_PATH(){
	a=$1
	if [[ ${USER_OS} == 2 ]]
	then
		a=${a#*/} && a=${a#*/}
		disk=${a:0:1} && disk=$(echo ${disk} | tr 'a-z' 'A-Z')
		a=${disk}:${a:1} && a=${a////\\}
	fi
}
CONC_MANGA(){
    echo -e "${blue}[INFO]${plain}轉換漫畫為PDF......"
    if [[ ${OD} == 0 ]]
    then
        cd ${OUT_DIR}
    else
        cd ${TEMP_DOWN_PATH}
    fi
    DRAWLINE
    for ((i=0;i<${#MANGA[@]};i++))
    do
        echo -e "${yellow}[INFO]${plain}正在轉換[ ${MANGA[${i}]} ]"
        convert $(find "${TEMP_UNZIP_PATH}${MANGA[${i}]}" | sort -V) "${MANGA[${i}]}.pdf"
        DRAWLINE
    done
    for rmfile in $(ls -d ${TEMP_UNZIP_PATH})
    do
        rm -rf ${rmfile}
    done
    if [[ ${OD} == 1 ]]
    then
        rclone move ${TEMP_DOWN_PATH} OneDrive:/ -v --transfers=${MAXPARALLEL} --cache-chunk-size 16M --no-traverse --config "${RCLONE}"
    else
        rsync --remove-source-files --info=progress2 --no-inc-recursive -zrI ${TEMP_DOWN_PATH} ${OUT_DIR}
    fi
    CONC_PATH ${OUT_DIR} && [[ ${OD} == 1 ]] && a="OneDrive"
    echo -e "${green}[INFO]${plain}轉換PDF & 下載成功! & 请查收 【${green}${a}${plain}】"
}
WRITEINDATA(){
    CLEARFILE ${NAME_FILE}
    DOWN_MULTI 10
    i=-1
    for COMIC in "${LINKARRY[@]}"
    do
        read -u4
        let "i++"
        {
            case ${COMIC%%\:*} in
            0)
                COMIC=${COMIC#*\:} && GET_E_HENTAI_SRC ${i} ${COMIC}
                ;;
            1)
                COMIC=${COMIC#*\:} && GET_N_HENTAI_SRC ${i} ${COMIC}
                ;;
            esac
            echo >&4
        }&
    done
    wait
    exec 4>&-
    MANGA=($(cat ${NAME_FILE} | sort -V | cut -d ':' -f 2))
    DRAWLINE
}
MOVE_MANGA(){
    DRAWLINE
    echo -e "${blue}[INFO]${plain}正在移动漫画......"
    if [[ ${OD} == 1 ]]
    then
        for i in ${MANGA[@]}
        do
            rclone move ${TEMP_UNZIP_PATH}${i} OneDrive:/ -v --transfers=${MAXPARALLEL} --cache-chunk-size 16M --no-traverse --config "${RCLONE}"
        done
    else
        for i in ${MANGA[@]}
        do
            rsync --remove-source-files --info=progress2 --no-inc-recursive -zrI ${TEMP_UNZIP_PATH}${i} ${OUT_DIR}
        done
    fi
    CONC_PATH ${OUT_DIR} && [[ ${OD} == 1 ]] && a="OneDrive"
    echo -e "${green}[INFO]${plain}下載成功!请查收【${green}${a}${plain}】"
}
ASKCONC(){
    if [ -z CONCPDF ]
    then
        while true
        do
            echo -en "${yellow}[INFO]${plain}是否需要自动转换漫画为PDF[Y/N]："
            read CONCPDF
            case ${CONCPDF} in
            n|N)
                CONCPDF=1 && break
                ;;
            y|Y)
                CONCPDF=0 && break
                ;;
            *)
                echo -e "${red}[INFO]${plain}請輸入正確的選項"
                ;;
            esac
        done
    fi
}
REMOVE_TEMP(){
    find "${TEMP_UNZIP_PATH}" -type d -empty -delete
    find "${TEMP_DOWN_PATH}" -type d -empty -delete
    rm -rf ${NAME_FILE}
    rm -rf ${WGET_FILE}*
    rm -rf ${TEMP_UNZIP_PATH}TEMP*
}
#------------------------------------------------------------------
NHENTAI_TITLE
ASKCONC
while true
do
    ASK_MANGA
    [[ $? == 1 ]] && break
done
ASK_MULTI
WRITEINDATA
DISPLAY_MANGA_LIST
DOWN_MULTI ${multi}
DOWNLOAD_MANGA
if [[ ${CONCPDF} == 1 ]]
then
    CONC_MANGA
else
    MOVE_MANGA
fi
REMOVE_TEMP
#unset all var
IFS=$OLD_IFS