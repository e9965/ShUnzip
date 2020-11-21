#!/bin/bash
OLD_IFS=$IFS
IFS=$(echo -en "\n\b")
COLAB_BAIDU=/root/colab_baidu
#-------------------------------------------------------------------
DRAWLINE(){
	echo -e "${yellow}================================================================================${plain}"
}
BAIDU_INI_TITLE(){
	DRAWLINE
	echo -e "${blue}BaiduPCS-Go初始化插件 By:GetIntoBus"
	echo -e "${blue}開始設定下載參數......"
	DRAWLINE
}
LOGIN(){
	echo -e "${yellow}[INFO]${plain}登錄中......"
	bd login -cookies=${COOKIES}
	if [ $? != 0 ]
	then
		read -n 1 -p "登錄失敗 - 按<r>鍵重試 - 其他鍵退出" retry
		if [ ${retry} == 'r' ]
		then
			login
		else
			exit 2
		fi
	else
		DRAWLINE
	fi
}
SET_DOWN_PARAMETER(){
	bd config set -max_parallel ${MAXTHREAD} > /dev/null 2>&1
	bd config set -cache_size=${MAXCACHE} > /dev/null 2>&1
	bd config set --enable_https=false > /dev/null 2>&1
	bd config set -user_agent "netdisk;2.2.51.6;netdisk;10.0.63;PC;android-android" > /dev/null 2>&1
	bd mkdir ${TEMP_BAIDU_DOWN_PATH} > /dev/null 2>&1
	bd cd ${TEMP_BAIDU_DOWN_PATH} > /dev/null 2>&1
}
SET_INI_FLAG(){
    if [[ ${USER_OS} != 1 ]]
    then
    	sed -i 's/INITIALIZED=0/INITIALIZED=1/g' ${COOKIES_FILE}
    	export INITIALIZED=1
    else
        touch ${COLAB_BAIDU}
    fi
}
INI_PROCESS(){
BAIDU_INI_TITLE
LOGIN
SET_DOWN_PARAMETER
}	
#-------------------------------------------------------------------
if [[ ${INITIALIZED} == 0 ]]
then
    if [[ ${USER_OS} == 1 ]]
    then
        if [[ ! -f "${COLAB_BAIDU}" ]]
        then
        	INI_PROCESS
    	fi
    else
		INI_PROCESS
	fi
	SET_INI_FLAG
fi
IFS=$OLD_IFS