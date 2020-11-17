#/bin/sh
#By KennyBus
IFS=$(echo -en "\n\b")
NUM=1
export blue='\033[36m'
export yellow='\033[33m'
export green='\033[32m'
export red='\033[31m'
export plain='\033[0m'
export BASE_DIR="/content/M2"
#Procedure======================================================
CONC_PDF(){
    convert || apt-get install imagemagick -y > /dev/null 2>&1 
    cd ${BASE_DIR} && convert $(find "${BASE_DIR}/src/${CH}" | sort -V) "${CH}.pdf"
}
#Main===========================================================
echo -ne "${yellow}[INPUT]${plain}請輸入M2 TextBook 地址:"
read LINK
if [[ ${LINK} =~ "www.ctep.com.hk/nelm_ebook" ]]
then
    LINK=$(echo "${LINK}" | grep -oE "M2[^/]+") && CH=$(echo ${LINK} | grep -oE "M2E[[:digit:]]+")
    echo -e "${green}[INPUT]${plain}成功取得源碼 [${LINK}] && 課題[${CH}]"
    LINK="http://www.ctep.com.hk/nelm_ebook/${LINK}/files/page/"
    mkdir -p ${BASE_DIR}/src/${CH} > /dev/null 2>&1
    echo -e "${green}[INPUT]${plain}下載中......"
    while true
    do
        wget -P ${BASE_DIR}/src/${CH} ${LINK}${NUM}.jpg || break
        let "NUM++"
    done
    echo -e "${green}[INPUT]${plain}下載完成，轉換PDF ing"
    CONC_PDF
else
    echo -e "${red}[ERROR]${plain}請輸入正確的M2 TextBook 地址"
    exit 2
fi
echo -e "${green}[INPUT]${plain}轉換完成，請於[${BASE_DIR}]查看相關PDF檔案"
exit 0