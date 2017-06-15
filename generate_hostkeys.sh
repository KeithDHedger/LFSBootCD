#! /bin/sh

if [ -z "$TOPDIR" ] ; then
	echo "you must define TOPDIR"
	exit
fi

[ -d $TOPDIR/hostkeys ] || mkdir $TOPDIR/hostkeys

if [ ! -f $TOPDIR/hostkeys/ssh_host_dsa_key -o ! -f $TOPDIR/hostkeys/ssh_host_dsa_key.pub ];then
	ssh-keygen -t dsa -b 1024 -N "" -C "RescueCD host key" -f $TOPDIR/hostkeys/ssh_host_dsa_key 
fi

if [ ! -f $TOPDIR/hostkeys/ssh_host_rsa_key -o ! -f $TOPDIR/hostkeys/ssh_host_rsa_key.pub ];then
	ssh-keygen -t rsa -b 1024 -N "" -C "RescueCD host key" -f $TOPDIR/hostkeys/ssh_host_rsa_key 
fi
