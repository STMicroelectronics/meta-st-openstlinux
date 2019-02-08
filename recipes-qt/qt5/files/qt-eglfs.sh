#!/bin/sh -

export QT_QPA_PLATFORM=eglfs
if [ -e /usr/share/qt5/cursor.json ];
then
	export QT_QPA_EGLFS_KMS_CONFIG=/usr/share/qt5/cursor.json
fi

