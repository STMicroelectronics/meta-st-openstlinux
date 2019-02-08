SPLASH_IMG ?= ST13028_Linux_picto_11_480x352_8bits.png
SPLASH_IMG_ROT ?= ST13028_Linux_picto_11_480x352_8bits_rotation.png

all: modeset

generate_header: $(SPLASH_IMG) $(SPLASH_IMG_ROT)
	@gdk-pixbuf-csource --macros $(SPLASH_IMG) > image_header.tmp
	@(sed -e "s/MY_PIXBUF/SPLASH_IMG/g" -e "s/guint8/uint8_t/g" image_header.tmp > image_header.h && rm image_header.tmp)
	@gdk-pixbuf-csource --macros $(SPLASH_IMG_ROT) > image_header.tmp
	@(sed -e "s/MY_PIXBUF/SPLASH_IMG_ROT/g" -e "s/guint8/uint8_t/g" image_header.tmp >> image_header.h && rm image_header.tmp)

psplash:
	$(CC) $(CFLAGS) $(LDFLAGS) -o psplash-drm basic_splash_drm.c -I. `pkg-config --cflags --libs libdrm` -Wall -Os

clean:
	rm -rf psplash-drm
