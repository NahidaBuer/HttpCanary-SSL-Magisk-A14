#!/system/bin/sh

set_context() {
    [ "$(getenforce)" = "Enforcing" ] || return 0

    default_selinux_context=u:object_r:system_file:s0
    selinux_context=$(ls -Zd $1 | awk '{print $1}')

    if [ -n "$selinux_context" ] && [ "$selinux_context" != "?" ]; then
        chcon -R $selinux_context $2
    else
        chcon -R $default_selinux_context $2
    fi
}

A14_CERT_PATH=/apex/com.android.conscrypt/cacerts
LOG_PATH=/data/local/tmp/HttpCanaryCA.log
echo "[$(date +%F) $(date +%T)] - HttpCanaryCA post-fs-data.sh start." > $LOG_PATH

if [ -d $A14_CERT_PATH ]; then
    # 检测到 android 14 以上，存在该证书目录
    CERT_HASH=87bc3517
    MODDIR=${0%/*}

    CERT_FILE=${MODDIR}/system/etc/security/cacerts/${CERT_HASH}.0
    echo "[$(date +%F) $(date +%T)] - CERT_FILE: ${CERT_FILE}" >> $LOG_PATH
    if ! [ -e "${CERT_FILE}" ]; then
        echo "[$(date +%F) $(date +%T)] - HttpCanaryCA certificate not found." >> $LOG_PATH
        exit 0
    fi

    TEMP_DIR=/data/local/tmp/httpcanarycacerts-copy
    rm -rf "$TEMP_DIR"
    mkdir -p -m 700 "$TEMP_DIR"
    mount -t tmpfs tmpfs "$TEMP_DIR"

    # 复制证书到临时目录
    cp -f $A14_CERT_PATH/* $TEMP_DIR/
    cp -f $CERT_FILE "$TEMP_DIR"

    # 设置证书权限和 selinux 与此前一致
    chown -R 0:0 "$TEMP_DIR"
    set_context $A14_CERT_PATH "$TEMP_DIR"

    # 检查新证书是否成功添加
    CERTS_NUM="$(ls -1 $TEMP_DIR | wc -l)"
    if [ "$CERTS_NUM" -gt 10 ]; then
        mount -o bind "$TEMP_DIR" $A14_CERT_PATH
        echo "[$(date +%F) $(date +%T)] - $CERTS_NUM Mount success!" >> $LOG_PATH
    else
        echo "[$(date +%F) $(date +%T)] - $CERTS_NUM Mount failed!" >> $LOG_PATH
    fi

    # 卸载临时目录
    umount "$TEMP_DIR"
    rmdir "$TEMP_DIR"
else
    echo "[$(date +%F) $(date +%T)] - $A14_CERT_PATH not exists."
fi