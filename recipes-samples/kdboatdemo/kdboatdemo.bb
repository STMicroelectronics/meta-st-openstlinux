DESCRIPTION = "KDAB Nautical UI - concept of the next generation UI for sailing boats"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSES/MIT.txt;md5=7dda4e90ded66ab88b86f76169f28663 \
                    file://LICENSES/Apache-2.0.txt;md5=c846ebb396f8b174b10ded4771514fcc \
                    file://LICENSES/OFL-1.1.txt;md5=2680fce30f17e5fed9bcebd9336e5b78"

S = "${WORKDIR}/git"

DEPENDS += "qtbase qtdeclarative qtgraphicaleffects qtquickcontrols2"

SRCREV = "cf48b0fbb2fa3272cb6ea0f0ae0e7a6f04515b85"
SRC_URI = "git://github.com/KDAB/KDBoatDemo.git;protocol=https;branch=master"

inherit cmake_qt5

RDEPENDS::append = " qtdeclarative-qmlplugins qtgraphicaleffects-qmlplugins qtquickcontrols2-qmlplugins "
