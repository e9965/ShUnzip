OPT=$1
echo -ne "Please Input the Name of the SubAccount:"
read SUB
if [[ ${OPT} == "" ]]
then
  echo -e "i.[Install the NBMiner & Start Mining]\nr.[Restart NBMiner]\nl.[Output the Log]"
  echo -ne "Please Input your Options:"
fi
case ${OPT} in
r)
  kill -9 `ps -ef|grep miner|awk '{print $2}'`
  cd /root/NBMiner_Linux
  nohup ./nbminer -a ethash -o stratum+tcp://en.huobipool.com:1800 -u 0x7bb3ba2abe1de9b6d95697aa78b14326986ae540.cco2fe &
  ;;
l)
  [[ -f /root/NBMiner_Linux/nohup.out ]] && cat /root/NBMiner_Linux/nohup.out | tail -n 1000
  ;;
i)
  wget --no-check-certificate https://hub.fastgit.org/NebuTech/NBMiner/releases/download/v36.1/NBMiner_36.1_Linux.tgz && tar -xvf NBMiner_36.1_Linux.tgz && rm -rf NBMiner_36.1_Linux.tgz &&cd NBMiner_Linux && chmod +rwx nbminer && nohup ./nbminer -a ethash -o stratum+tcp://en.huobipool.com:1800 -u 0x7bb3ba2abe1de9b6d95697aa78b14326986ae540.cco2fe &
  ;;
esac
exit 0
