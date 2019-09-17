#!/bin/sh -

export QT_QPA_PLATFORM=eglfs
if [ -e /usr/share/qt5/cursor.json ];
then
	export QT_QPA_EGLFS_KMS_CONFIG=/usr/share/qt5/cursor.json
fi
# force to keep the MODE SETTING set
export QT_QPA_EGLFS_ALWAYS_SET_MODE=1
#force to use KMS ATOMIC
export QT_QPA_EGLFS_KMS_ATOMIC=1

# EGLFS environment variables accessible for qt 5.12
# Documentation: https://doc.qt.io/qt-5/embedded-linux.html
##
# * QT_QPA_EGLFS_ROTATION
# Specifies the rotation applied to software-rendered content in QWidget-based applications
#
# * QT_QPA_EGLFS_KMS_ATOMIC
# enable the DRM atomic
#
# * QT_QPA_EGLFS_HIDECURSOR
# The mouse cursor shows up whenever this variable is not set
#
# * QT_QPA_EGLFS_ALWAYS_SET_MODE
# Due to the fact that modesetting is done only when the desired mode is actually
# different from the active one (unless forced via the QT_QPA_EGLFS_ALWAYS_SET_MODE
# environment variable), this value is useful to keep the current mode and any content
# in the planes not touched by Qt.
