LIC_FILES_CHKSUM = "file://COPYING;md5=f8fee3d59797546cffab04f3b88b2d44"

DEPENDS += "jsoncpp openssl curl jq"
DEPENDS += "tbb"
DEPENDS += "libb64"
DEPENDS += "elfutils"

SRC_URI = "git://github.com/draios/sysdig.git;protocol=https"
SRCREV = "aa82b2fb329ea97a8ade31590954ddaa675e1728"

PV = "0.24.2+git${SRCPV}"

EXTRA_OECMAKE += ' -DUSE_BUNDLED_LUAJIT="OFF" \
                   -DUSE_BUNDLED_ZLIB="OFF" \
                   -DUSE_BUNDLED_NCURSES="OFF" \
                   -DUSE_BUNDLED_JSONCPP="OFF" \
                   -DUSE_BUNDLED_OPENSSL="OFF" \
                   -DUSE_BUNDLED_CURL="OFF" \
                   -DUSE_BUNDLED_B64="OFF" \
                   -DUSE_BUNDLED_JQ="OFF" \
                   -DUSE_BUNDLED_TBB="OFF" \
                 '
FILES_${PN}_remove = "${prefix}/src/*"

FILES_${PN}-dev += "${prefix}/src/*"
