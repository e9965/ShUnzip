#!/bin/bash
OLD_IFS=$IFS
IFS=$(echo -en "\n\b")
#--------------------------- [Introduction] ---------------------------------
#變量解釋:
# [SizeArray] = 一共有多少密碼
# [Passwd] = 密碼數組
# [InZip] = 壓縮包目錄 
# [Upzip] = 解壓後目錄
# [UnzipDel] = 解壓後刪除源文件
#   {1:刪除} {0:不刪除}
#
# 如需新增密碼則在直接 [Password Region] 文末寫入
# 寫入方法:
# SizeArray=n+1
# passwd[n-1]="上一個密碼"
# passwd[n]="新密碼"
# 實例:
# SizeArray=83
# passwd[82]="12345chen"
# passwd[83]="你的新密碼"
# 解壓順序: [n] to [0]
#------------------------- [End Introduction] -------------------------------
#------------------------- [Unzip Function] ---------------------------------
Inzip=/content/drive/Shared\ drives/KennyDrive/Download/CangKu/ASMR
Opzip=/content/drive/Shared\ drives/KennyDrive/Download/CangKu/ASMR
UnzipDel=1
ReF=0
Srun=0
#------------------------ [End Unzip Function] -----------------------------
#------------------------ [Password Region] ---------------------------------
SizeArray=83
passwd[0]=yhsxsx
passwd[1]=没有节操的灵梦
passwd[2]=毛玉mouyu
passwd[3]=e46852s
passwd[4]=acg和谐区
passwd[5]=acgzone.us
passwd[6]=http://acgzone.us/
passwd[7]=acgzone.tk
passwd[8]=节操粉碎机
passwd[9]=http://www.tianshi2.com
passwd[10]=傲娇零：aojiao.org
passwd[11]=i-ab.com
passwd[12]=天照大御神
passwd[13]=猫与好天气
passwd[14]=lifaner.com
passwd[15]=456black
passwd[16]=moe
passwd[17]=动漫本子吧
passwd[18]=里番儿
passwd[19]=lsmj
passwd[20]=674434350
passwd[21]=psp.duowan.com
passwd[22]=御宅同萌
passwd[23]=tangtang
passwd[24]=827283516
passwd[25]=ce
passwd[26]=http://www.acgft.us
passwd[27]=hentai.
passwd[28]=tianshi2
passwd[29]=lifaner.com
passwd[30]=妮妙
passwd[31]=发条奶茶
passwd[32]=七曜苏醒
passwd[33]=123456
passwd[34]=yaoying
passwd[35]=gg
passwd[36]=air
passwd[37]=天照大御神
passwd[38]=爱有缘有份
passwd[39]=YES
passwd[40]=malow005
passwd[41]=我没有节操
passwd[42]=拉杰尔的图书馆
passwd[43]=20131225
passwd[44]=RoC_1112@eyny
passwd[45]=moe
passwd[46]=benzi
passwd[47]=Q10
passwd[48]=tianshi2.com
passwd[49]=180998244
passwd[50]=ntr
passwd[51]=CR48
passwd[52]=inori
passwd[53]=BQ510
passwd[54]=120505478
passwd[55]=社会主义歼星炮
passwd[56]=技术宅
passwd[57]=通宵狂魔技术宅
passwd[58]=黙示
passwd[59]=终点
passwd[60]=琉璃神社
passwd[61]=樱花树下实现
passwd[62]=扶她奶茶
passwd[63]=忧郁的弟弟
passwd[64]=忧郁的loli
passwd[65]=当场身亡
passwd[66]=大萝莉教
passwd[67]=四散的尘埃
passwd[68]=哆啦A梦
passwd[69]=say花火
passwd[70]=hacg.me
passwd[71]=当场身亡
passwd[72]=acgngame
passwd[73]=⑨
passwd[74]=不要在线解压
passwd[75]=奶子
passwd[76]=我永远单推FBK
passwd[77]=xufeng
passwd[78]=阿夸大天使
passwd[79]=baimo
passwd[80]=WaterSolubilityC
passwd[81]=cangku.moe
passwd[82]=12345chen
#---------------------- [End Password Region] ------------------------------
#--------------------------- [Start Shell] ----------------------------------
cd "${Inzip}"
while(( ${ReF} <= 0 ))
#First While loop is for recursion [Unzip the zip form the parent zip]
do
#-------------------------------------------------------------------------------
#Search for the zip file
#begin Ver3不刪除文件依然能解壓多層
#begin Ver3解壓分卷文件
  if [ ${Srun} == 0 ]
  then
	i=0
	files=$(find -type f -name "*.rar*" -o -name "*.7z*" -o -name "*.zip*")
  elif [ ${UnzipDel} == 1 ]
  then
	i=0
	files=$(find -type f -name "*.rar*" -o -name "*.7z*" -o -name "*.zip*")
  else
	let "i++"
	checktime=${#sfilecheck[@]}
	checkdummy=0
	checkstring=${sfilecheck[0]}
	while(( ${checkdummy} < checktime))
	do
	checkstring=${checkstring}|${sfilecheck[${checkdummy}]}
	let "checkdummy++"
	done
	files=$(find -type f -name "*.rar*" -o -name "*.7z*" -o -name "*.zip*"|grep -v -E "${checkstring}")
  fi
  g=0
  for Tfilename in ${files}
  do
	filename=${Tfilename:1}
	Fcfilelist[$i]=${filename}
#Ver3解壓分卷文件 Idea [Groupping]
    dummy=0
	tempc=${g}
	Flag=1
	if [ ${g} != 0 ]
	then
	while(( ${dummy} <= ${tempc} ))
		do
		if [ ${Fcfilelist[${i}]%%.*} == ${filelist[${dummy}%%.*]} ]
		then
			Flag=0
			break
		fi
		let "dummy++"
		done
	if  [ ${Flag} == 1 ]
	then
		let "g++"
		filelist[${g}]=${Fcfilelist[$i]}		
	fi
	else
	filelist[0]=${Fcfilelist[${i}]}
	let "g++"
	fi
#End Ver3解壓分卷文件
	if [ ${UnzipDel} != 1 ]
	then
	sfilecheck[${i}]=${sfilecheck[${i}]//(/}
	sfilecheck[${i}]=${sfilecheck[${i}]//)/}
	sfilecheck[${i}]=.${sfilecheck[${i}]}
	fi
#End Ver3不刪除文件依然能解壓多層
	let "i++"
  done
  Fc=${#filelist[@]}
#End for searching the zip file
#-------------------------------------------------------------------------------
#Start Checking whether need unzipping or not
  if [ ${Fc} != 0 ]
  then
#----------------------------------------------------------
#Start Unzip
    while(( ${Fc} > 0 ))
	do
        unzipsucc=0
        let "Fc--"
#----------------------------------------------------------
#Start to use Passwd
        c=1
		extfile=${Inzip}${filelist[${Fc}]}
		TOpzip=${Opzip}${filelist[${Fc}]%%.*}
	    while(( `expr ${SizeArray} - ${c}` >= 0 ))
        do
          7z x -y -p"${passwd[`expr ${SizeArray} - ${c}`]}" ${extfile} -o"${TOpzip}"
          err=$?
          if [ ${err} == 0 ]
            then
                let "unzipsucc++"
                echo "${passwd[`expr ${SizeArray} - ${c}`]} is correct!"
                echo "Unzip Success!!"
                break
            else
                echo "Failed~"
            fi
          let "c++"
        done
#End for trying the Passwd
#----------------------------------------------------------
#Give Response
      if [ ${unzipsucc} == 0 ]
      then
        echo "All Passwd Are incorrect"
      elif [ ${UnzipDel} == 1 ]
        then
		g1filename=${filelist[${Fc}]%%.*}
		delpath=${filelist[${Fc}]#/*}
		groupfilename=${g1filename##/*}
		i=0
		for TNeedDel in ${ls|grep ^${groupfilename}}
		do
		extfile=${Inzip}${delpath}/${TNeedDel}
		rm -f ${extfile}
		done
        echo "The Archives are deleted"
        else
        echo "Notice: The Archive haven't been deleted"
		Srun=1
      fi
    done
#End To Give Response
#----------------------------------------------------------
#----------------------------------------------------------
#Start to clear the file list
unset filelist
unset Fcfilelist
#End
#----------------------------------------------------------
#End Unzip
#-----------------------------------------------------------    
  else
    ReF=1
  fi
#Stop the Program  
#------------------------------------------------------------  
#End for the Unzipping processes
done
IFS=$OLD_IFS