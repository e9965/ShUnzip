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
    whereis convert || apt-get install imagemagick -y > /dev/null 2>&1 
    cd ${BASE_DIR} && convert $(find "${BASE_DIR}/src/" | sort -V) "${CH}.pdf"
}
#Main===========================================================
mkdir -p ${BASE_DIR}/src/
echo -ne "${green}[INPUT]${plain}請輸入M2 TextBook 地址:"
read LINK
if [[ ${LINK} =~ "www.ctep.com.hk/nelm_ebook" ]]
then
    LINK=$(echo "${LINK}" | grep -oE "M2[^/]+") && CH=$(echo ${LINK} | grep -oE "M2E[[:num:]]+") && LINK="http://www.ctep.com.hk/nelm_ebook/${LINK}/files/page/"
    while true
    do
        wget -qP ${BASE_DIR}/src ${LINK}${NUM}.jpg || break
        let "NUM++"
    done
else
    echo -ne "${red}[ERROR]${plain}請輸入正確的M2 TextBook 地址"
    exit 2
fi
exit 0