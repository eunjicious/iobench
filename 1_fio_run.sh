#!/usr/bin/bash
if [ $# -lt 1 ]; then
	echo "./.sh [seq / jesd / rand]"
	exit
fi

#echo "sshpass -p '12345abc' scp ejlee@203.255.11.56:~/FEMU/build-femu/femu.conf ."
#sshpass -p '12345abc' scp ejlee@203.255.11.56:~/FEMU/build-femu/femu.conf .
echo "sshpass -p '12345abc' scp ejlee@203.255.11.56:~/FEMU/build-femu/femu.conf ."
#sshpass -p '12345abc' scp ejlee@203.255.11.56:~/FEMU/build-femu/femu.conf . 
sshpass -p '12345abc' scp ejlee@203.255.11.56:~/FEMU/build-femu/femu.conf . 

DVSZ=`grep "DEVICE_SIZE" femu.conf | awk '{print $2}'`
POLICY=`grep "POLICY" femu.conf | awk '{print $2}' `
BFSZ=`grep "BUFFSZ_GB" femu.conf | awk '{print $2}' `
PR=`grep "PROTECTED_RATIO" femu.conf | awk '{print $2}' `

DIR=/mnt/femu
TEST=fio_test
BLKSZ=4K
FPSZGB=4
#TOTIOSZGB=12
TOTIOSZGB=16
NUMJOBS=4
#FPSZGB=4
#TOTIOSZGB=12
#NUMJOBS=4


test_num="1 2 3"
test_num="1"
workloads="seq rand jesd"
workloads="$1"
for tn in $test_num; do
	for wk in $workloads; do
	#	sudo umount $DIR 
	#	sudo ./0_mount_ext4.sh
	
		ofdir=./femu_perf
		ofname=$ofdir/fio_"$wk"_"$POLICY"_"$BFSZ"_"$DVSZ"_"$PR"_"$tn".perf
		wofname=$ofdir/fio_"$wk"_"$POLICY"_"$BFSZ"_"$DVSZ"_"$PR"_"$tn".wt
		gofname=$ofdir/fio_"$wk"_"$POLICY"_"$BFSZ"_"$DVSZ"_"$PR"_"$tn".gc

		echo $ofname
	
		echo "$wk ...." 
		if [[ $wk == "seq" ]]; then
			sudo fio --directory=$DIR --name fio_test_file --direct=1 --rw=write --bs=$BLKSZ --size=$(expr $FPSZGB / $NUMJOBS)G --io_size=$(expr $TOTIOSZGB / $NUMJOBS)G --numjobs=$NUMJOBS --group_reporting --norandommap > $ofname
		elif [[ $wk == "rand" ]]; then
			sudo fio --directory=$DIR --name fio_test_file --direct=1 --rw=randwrite --bs=$BLKSZ --size=$(expr $FPSZGB / $NUMJOBS)G --io_size=$(expr $TOTIOSZGB / $NUMJOBS)G --numjobs=$NUMJOBS --group_reporting --norandommap > $ofname
		elif [[ $wk == "jesd" ]]; then
			echo "sudo fio --directory=$DIR --name fio_test_file --direct=1 --rw=randwrite --size=$(expr $FPSZGB / $NUMJOBS)G --io_size=$(expr $TOTIOSZGB / $NUMJOBS)G --norandommap --randrepeat=0 --iodepth=256 --numjobs=$NUMJOBS --bssplit=512/4:1024/1:1536/1:2048/1:2560/1:3072/1:3584/1:4k/67:8k/10:16k/7:32k/3:64k/3 --blockalign=4k --random_distribution=zoned:50/5:30/15:20/80 --group_reporting"
			sudo fio --directory=$DIR --name fio_test_file --direct=1 --rw=randwrite --size=$(expr $FPSZGB / $NUMJOBS)G --io_size=$(expr $TOTIOSZGB / $NUMJOBS)G --norandommap --randrepeat=0 --iodepth=256 --numjobs=$NUMJOBS --bssplit=512/4:1024/1:1536/1:2048/1:2560/1:3072/1:3584/1:4k/67:8k/10:16k/7:32k/3:64k/3 --blockalign=4k --random_distribution=zoned:50/5:30/15:20/80 --group_reporting > $ofname

		fi

		sshpass -p '12345abc' scp ejlee@203.255.11.56:~/femu_stat.log . 
		tail -n 1 femu_stat.log > $wofname

		sshpass -p '12345abc' scp ejlee@203.255.11.56:~/femu_gc_stat.log . 
		mv femu_gc_stat.log $gofname


		cat $ofname
		cat $wofname
	done
done
