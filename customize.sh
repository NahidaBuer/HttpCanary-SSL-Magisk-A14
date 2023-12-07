#!/system/bin/sh

CERTS_DIR=${MODPATH}/certs
APP_VER_335=/data/data/com.guoshi.httpcanary
APP_VER_336=/data/data/com.guoshi.httpcanary.premium

if [ -d ${APP_VER_335} ]; then
    echo "HttpCanary 3.3.5 detected, copying certs..."
    cp $CERTS_DIR/* $APP_VER_335/cache/
fi
if [ -d ${APP_VER_336} ]; then
    echo "HttpCanary 3.3.6 detected, copying certs..."
    cp $CERTS_DIR/* $APP_VER_336/cache/
fi

ui_print $MODPATH
ui_print "安装成功, 重启手机后去系统证书查看证书是否生效。"
ui_print "问题反馈: "
ui_print "https://github.com/NahidaBuer/HttpCanary-SSL-Magisk-A14/issues"