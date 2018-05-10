#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="autoopendriver"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
APACHE_ROOT=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`
export QNAP_QPKG=$QPKG_NAME

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi
    CPU_MODULE=`uname -m`
    KERNEL_VERSION=`uname -r`

    if [ $CPU_MODULE == "armv7l" ]; then
	    if [ $KERNEL_VERSION == "4.2.8" ]; then
        echo "Link cdc-acm.ko"
        notice_log_tool -a "[$QPKG_NAME] Link cdc-acm.ko" -t 0
        ln -s $QPKG_ROOT/cdc-acm.ko /usr/local/modules/
        depmod
      fi
    fi	
      echo "Loading driver..."
      notice_log_tool -a "[$QPKG_NAME] Loading driver..." -t 7
      modprobe cdc-acm.ko
	    modprobe cp210x.ko
	    modprobe ftdi_sio.ko
	    #modprobe usbserial.ko
      test -L /usr/local/modules/cdc-acm.ko
    ;;

  stop)
    echo "Unloading driver..."
    notice_log_tool -a "[$QPKG_NAME] Unloading driver..." -t 7
    modprobe -r cdc-acm.ko
    modprobe -r cp210x.ko
    modprobe -r ftdi_sio.ko
    #modprobe -r usbserial.ko
    if test -L /usr/local/modules/cdc-acm.ko ; then
      echo "Unlink cdc-acm.ko"
      notice_log_tool -a "[$QPKG_NAME] Unlink cdc-acm.ko" -t 0
      rm /usr/local/modules/cdc-acm.ko
      depmod
    fi
    ;;

  restart)
    $0 stop
    $0 start
    ;;

  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit 0
