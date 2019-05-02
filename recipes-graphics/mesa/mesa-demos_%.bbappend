PACKAGECONFIG = "drm osmesa freetype2 gbm egl gles1 gles2 \
                  x11 glew glu glx \
		  ${@bb.utils.filter('DISTRO_FEATURES', 'wayland', d)} \
		  "

