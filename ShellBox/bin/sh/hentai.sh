#!/bin/bash
OLD_IFS=$IFS
IFS=$(echo -en "\n\b")
#------------------------------------------------------------------
WGET_FILE=${TEMP_UNZIP_PATH}mangalist
MANGA_NUM=0
#------------------------------------------------------------------
DRAWLINE(){
	echo -e "${yellow}================================================================================${plain}"
}
DOWN_MULTI(){
    temp_fifo="/tmp/$$.fifo"
	mkfifo ${temp_fifo}
	exec 4<>${temp_fifo}
	rm -f ${temp_fifo}
	for ((i=0;i<${1};i++)) ; do echo >&4 ; done
}
GET_E_HENTAI_SRC(){
    wget -qO TEMP.html --no-check-certificate --header="${EHENTAI_COOKIE}" "${COMIC}"
    COMIC=$(echo ${COMIC} | grep -m 1 -oE "e(-|x)hentai.org")
    echo -e "${green}[INFO]${plain}成功分析漫画網頁代碼"
    #Get the html
    GID=$(cat TEMP.html | grep -m 1 -oE 'gid = [[:alnum:]]+') && GID=${GID##*\ }
    echo -e "${green}[INFO]${plain}成功分析漫画GID為[${GID}]"
    #Get Gid
    MANGA[${MANGA_NUM}]=$(cat TEMP.html | grep -oE '<h1[^<]+' | tail -1) && MANGA[${MANGA_NUM}]=${MANGA[${MANGA_NUM}]#*\>}
    echo -e "${green}[INFO]${plain}成功分析漫画标题為[${MANGA[${MANGA_NUM}]}]"
    #Get Title
    PAGES=$(cat TEMP.html | grep -m 1 -oE '[[:alnum:]]+ pages') && PAGES=${PAGES%\ *}
    echo -e "${green}[INFO]${plain}成功分析漫画页数為[${PAGES}]"
    #Get Pages
    mkdir -p "${TEMP_UNZIP_PATH}${MANGA[${MANGA_NUM}]}" > /dev/null 2>&1
    touch ${WGET_FILE}${MANGA_NUM} > /dev/null 2>&1
    DOWN_MULTI 25
    echo -e "${yellow}[INFO]${plain}開始分析漫画圖源直連"
    for ((i=1;i<=${PAGES};i++))
    do
        read -u4
        {
            wget -qO TEMP.html --no-check-certificate --header="${EHENTAI_COOKIE}" "$(cat TEMP.html | grep -m 1 -oE "https://${COMIC}/s/[[:alnum:]]+/${GID}-${i}" | head -1)"
            [[ ! $? == 0 ]] && echo -e "${red}[ERROR]${plain}請求數量過多，取得鏈接錯誤，請檢查網絡&Cookie並匯報BUG" && exit 2
            LINK=$(cat TEMP.html | grep -m 1 -oE 'img" src="[^"]+') && LINK=${LINK##*\"}
            echo "wget --no-check-certificate -qO \"${TEMP_UNZIP_PATH}${MANGA[${MANGA_NUM}]}/${i}.${LINK##*.}\" \"${LINK}\" " >> "${WGET_FILE}${MANGA_NUM}"
            echo >&4
        }
    done
    echo -e "${green}[INFO]${plain}成功写入所有图源链接"
    exec 4>&-
}
GET_N_HENTAI_SRC(){
    wget -qO TEMP.html --no-check-certificate "${COMIC}"
    echo -e "${green}[INFO]${plain}成功分析漫画網頁代碼"
    #Get the html
    GID=$(cat TEMP.html | grep -m 1 -oE 's/[[:alnum:]]+' | head -1 ) && GID=${GID##*\/}
    echo -e "${green}[INFO]${plain}成功分析漫画GID為[${GID}]"
    #Get Gid
    MANGA[${MANGA_NUM}]=$(cat TEMP.html | grep -m 1 -oE "tty[^<]+" | head -1 ) && MANGA[${MANGA_NUM}]=${MANGA[${MANGA_NUM}]#*\>}
    echo -e "${green}[INFO]${plain}成功分析漫画标题為[${MANGA[${MANGA_NUM}]}]"
    #Get Title
    PAGES=$(cat TEMP.html | grep -m 1 -oE 'e\">[[:digit:]]+') && PAGES=${PAGES#*\>}
    echo -e "${green}[INFO]${plain}成功分析漫画页数為[${PAGES}]"
    #Get Pages
    wget -qO TEMP.html --no-check-certificate "${COMIC}/1/"
    IMG_TYPE=$(cat TEMP.html | grep -m 1 -oE "${GID}/[[:alnum:]]+\.[[:alnum:]]+" | head -1 ) && IMG_TYPE=${IMG_TYPE##*\.}
    #Get Type
    mkdir -p "${TEMP_UNZIP_PATH}${MANGA[${MANGA_NUM}]}" > /dev/null 2>&1
    touch ${WGET_FILE}${MANGA_NUM} > /dev/null 2>&1
    echo -e "${yellow}[INFO]${plain}開始分析漫画圖源直連"
    for ((i=1;i<=${PAGES};i++))
    do
        echo "wget --no-check-certificate -qO \"${TEMP_UNZIP_PATH}${MANGA[${MANGA_NUM}]}/${i}.${IMG_TYPE}\" \"https://i.nhentai.net/galleries/${GID}/${i}.${IMG_TYPE}\" " >> "${WGET_FILE}${MANGA_NUM}"
    done
    echo -e "${green}[INFO]${plain}成功写入所有图源链接"
}

NHENTAI_TITLE(){
    DRAWLINE
    echo -e "${yellow} [ EHentai/NHentai ] ${red}下載工具 ver0.01 | By:GetIntoBus${plain}"
    DRAWLINE
}

ASK_MANGA(){
    echo -ne "${green}[INPUT]${plain}請輸入漫畫網址:"
    read COMIC
    if [[ ${COMIC} == "" ]]
    then
        DRAWLINE
        return 1
    else
        case ${MANGA} in
            *e-hentai.org*)
                GET_E_HENTAI_SRC
                ;;
            *exhentai.org*)
                if [ -z ${EHENTAI_COOKIE} ]
                then
                    echo -e "${red}[ERROR]${plain}缺少Cookie..."
                    echo -en "${yellow}[INFO]${plain}請輸入你的ExHentai Cookie [留空Enter跳過下載]:"
                    read EHENTAI_COOKIE
                    [ -z ${EHENTAI_COOKIE} ] && return 0
                fi
                GET_E_HENTAI_SRC
                ;;
            *nhentai.net*)
                GET_N_HENTAI_SRC
                ;;
                *)
                echo -e "${red}[ERROR]${plain}僅支持EHentai/NHentai漫畫，請檢查鏈接"
                return 0
                ;;
        esac
        let "MANGA_NUM++"
        DRAWLINE
        return 0
    fi
}
DOWNLOAD_MANGA(){
    echo -en "${yellow}[INFO]${plain}<Enter>键确认 & <Ctlr+C>键取消"
    read
    DRAWLINE
    unset i && i=0
    for ((i=0;i<${MANGA_NUM};i++))
    do
        read -u4
        {
            echo -e "${red}[INFO]${plain}开始下载漫画: [ ${yellow}${MANGA[${i}]}${plain} ]"
            source ${WGET_FILE}${i}
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
    rm -rf TEMP.html
    unset i && i=0
    echo -e "${yellow}[INFO]${plain}即將下載以下漫畫:"
    while (( ${i} < ${#MANGA[@]} ))
    do
        echo -e "編號[${i}]: ${MANGA[${i}]}"
        let "i++"
    done
    DRAWLINE
}
CONC_MANGA(){
    unset i
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
    echo -e "${green}[INFO]${plain}轉換PDF & 下載成功!"
}
#------------------------------------------------------------------
NHENTAI_TITLE
rm -rf ${TEMP_DOWN_PATH}/*
while true
do
    ASK_MANGA
    [[ $? == 1 ]] && break
done
ASK_MULTI
DOWN_MULTI $?
DISPLAY_MANGA_LIST
DOWNLOAD_MANGA
CONC_MANGA
#unset all var
IFS=$OLD_IFS