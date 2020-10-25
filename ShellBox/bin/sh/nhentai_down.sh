#!/bin/bash
OLD_IFS=$IFS
IFS=$(echo -en "\n\b")
#------------------------------------------------------------------
WGET_FILE=${TEMP_UNZIP_PATH}mangalist
HTML=${TEMP_UNZIP_PATH}manga.html
MANGA_NUM=0
sample=""
url=""
title=""
imgtype=""
page=""
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
GET_SRC(){
    unset sample && unset url && unset title && unset imgtype && unset page && unset i
    touch "${WGET_FILE}${CURR_NUM}"
    wget -qO ${HTML} ${2} --tries=0
    sample=$(cat ${HTML})
    sample=${sample%%Upl*}
    echo -e "${green}[INFO]${plain}成功取得网站源码"
    page=${sample##*\:}
    page=${page%%\<\/*}
    page=${page##*\>}
    echo -e "${green}[INFO]${plain}成功分析漫画页数: [${page}]"
    title=${sample#*name\"}
    title=${title#*\"}
    title=${title%%\"*}
    echo -e "${green}[INFO]${plain}成功分析漫画标题: [${title}]"
    MANGA[${1}]=${title}
    sample=${sample##*src}
    url=${sample%%\/cover*}
    url=${url##*\/}
    echo -e "${green}[INFO]${plain}成功分析漫画图源代码: [${url}]"
    url=https://i.nhentai.net/galleries/${url}/
    wget -q ${url}1.jpg -O /dev/null
    if [[ $? != 0 ]]
    then
        imgtype=png
    else
        imgtype=jpg
    fi
    IMG[${1}]=${imgtype}
    echo -e "${green}[INFO]${plain}成功分析漫画图源格式: [${imgtype}]"
    mkdir "${TEMP_UNZIP_PATH}${title}" > /dev/null 2>&1
    for ((i=1;i<=${page};i++))
    do
        echo "${url}${i}.${imgtype}" >> "${WGET_FILE}${1}"
    done
    echo -e "${green}[INFO]${plain}成功写入所有图源链接"
    rm -f ${HTML}
}

NHENTAI_TITLE(){
    DRAWLINE
    echo -e "${yellow} [ nHentai.net ] ${red}下載工具 ver0.01 | By:GetIntoBus${plain}"
    DRAWLINE
}

ASK_MANGA(){
    echo -ne "${green}[INPUT]${plain}請輸入 nHentai.net 漫畫網址:"
    read COMIC
    if [[ ${COMIC} == "" ]]
    then
        DRAWLINE
        return 1
    else
        if [[ ${COMIC} =~ "nhentai.net" ]]
        then
            GET_SRC ${MANGA_NUM} ${COMIC}
            let "MANGA_NUM++"
        else
            echo -e "${red}[ERROR]${plain}请输入正确的nHentai.net漫画"
        fi
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
            wget -q -i "${WGET_FILE}${i}" -A.jpg,.jpeg,.png,.PNG,.JPEG,.JPG -P "${TEMP_UNZIP_PATH}${MANGA[${i}]}"
            echo -e "${green}[INFO]${plain}下载漫画: [ ${yellow}${MANGA[${i}]}${plain} ]完成"
            echo >&4
        }&
    done
    wait
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
        convert $(find "${TEMP_UNZIP_PATH}${MANGA[${i}]}" -iname "*.${IMG[${i}]}*" | sort -V) "${MANGA[${i}]}.pdf"
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
    if [[ $? == 1 ]]
    then
        break
    fi
done
ASK_MULTI
DOWN_MULTI $?
DISPLAY_MANGA_LIST
DOWNLOAD_MANGA
CONC_MANGA
#unset all var
unset WGET_FILE
unset HTML
unset MANGA_NUM
unset sample
unset url
unset title
unset imgtype
unset page
unset MANGA
unset IMG
unset rmfile
IFS=$OLD_IFS