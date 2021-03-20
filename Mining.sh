TWEAK(){
echo -ne "Do u use 1080ti/1080 ? [Y/n]:"
read TEMP
case ${TEMP} in
Y|y)
  wget -qO OhGodAnETHlargementPill https://hub.fastgit.org/LukasBures/OhGodAnETHlargementPill/blob/master/OhGodAnETHlargementPill?raw=true
  chmod +rwx OhGodAnETHlargementPill
  nohup ./OhGodAnETHlargementPill &
  echo -e "OhGodAnETHlargementPill is installed for your GPU"
  ;;
*)
  echo -e "No Tweaks for your GPU"
  ;;
esac
}
#=================================
OPT=$1
echo -ne "Please Input the Name of the SubAccount:"
read SUB
if [[ ${OPT} == "" ]]
then
  echo -e "i.[Install the NBMiner & Start Mining]\nr.[Restart NBMiner]\nl.[Output the Log]"
  echo -ne "Please Input your Options:"
fi
read OPT
case ${OPT} in
r)
  kill -9 `ps -ef|grep miner|awk '{print $2}'`
  cd /root/NBMiner_Linux
  nohup ./nbminer -a ethash -o stratum+tcp://en.huobipool.com:1800 -u 0x7bb3ba2abe1de9b6d95697aa78b14326986ae540.${SUB} &
  ;;
l)
  [[ -f /root/NBMiner_Linux/nohup.out ]] && cat /root/NBMiner_Linux/nohup.out | tail -n 1000
  ;;
i)
  apt update -y && apt install cron -y
  systemctl > /dev/null 2>&1 && INSTALL_TWEAK
  echo "0 * * * * >/root/NBMiner_Linux/nohup.out" > /etc/crontab
  /etc/init.d/crond restart
  wget --no-check-certificate https://hub.fastgit.org/NebuTech/NBMiner/releases/download/v36.1/NBMiner_36.1_Linux.tgz && tar -xvf NBMiner_36.1_Linux.tgz && rm -rf NBMiner_36.1_Linux.tgz &&cd NBMiner_Linux && chmod +rwx nbminer && nohup ./nbminer -a ethash -o stratum+tcp://en.huobipool.com:1800 -u 0x7bb3ba2abe1de9b6d95697aa78b14326986ae540.${SUB} &
  ;;
esac
exit 0
