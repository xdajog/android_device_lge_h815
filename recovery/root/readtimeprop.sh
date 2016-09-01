#!/sbin/sh
# workaround script by steadfasterX to ensure time is correct

LOG=/tmp/recovery.log
F_LOG(){
   MSG="$1"
   echo "I:$TAG: $(date +%F_%T) - $MSG" >> $LOG
}
F_ELOG(){
   MSG="$1"
   echo "E:$TAG: $(date +%F_%T) - $MSG" >> $LOG
}

TAG="READTIME"
F_LOG "Starting $0"
F_LOG "timeadjust before setprop: >$(getprop persist.sys.timeadjust)<"
if [ -r /data/property/persist.sys.timeadjust ];then
    setprop persist.sys.timeadjust $(cat /data/property/persist.sys.timeadjust)
    F_LOG "setting persist.sys.timeadjust ended with $?"
    # trigger the timekeep daemon
    setprop twrp.timeadjusted 1
else
    FSTABHERE=0
    F_LOG "checking /data"
    mount |grep -q "/data"
    MNTERR=$?
    F_LOG "No /data in fstab yet! will wait until its there.."
    while [ "$FSTABHERE" -eq 0 ];do
        sleep 2
        grep -q "/data" /etc/fstab && FSTABHERE=1
    done
    F_LOG "/data detected: >$(grep "/data" /etc/fstab)<"

    if [ -d /data/property ];then
        F_LOG "skipping mount /data as it is already mounted"
    else
        F_LOG "mounting /data to access time offset from ROM"
        mount /data >>$LOG 2>&1
        F_LOG "mounting /data ended with <$?>"
    fi
    if [ -r /data/property/persist.sys.timeadjust ];then
        setprop persist.sys.timeadjust $(cat /data/property/persist.sys.timeadjust)
        F_LOG "setting persist.sys.timeadjust ended with $?"
        # trigger the timekeep daemon
        setprop twrp.timeadjusted 1
    else
        F_ELOG "/data/property/persist.sys.timeadjust not accessible!"
    fi
fi
F_LOG "timeadjust after setprop: >$(getprop persist.sys.timeadjust)<"
F_LOG "$0 finished"
