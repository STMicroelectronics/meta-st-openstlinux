# Meta-st-openstlinux

## Introduction
meta-st-openstlinux is a layer containing the framework metadata for current versions of OpenSTLinux.

OpenSTLinux is a Linux® distribution based on the OpenEmbedded build framework.

## DISTRO
OpenSTLinux layer provides severals distro:
* **openstlinux-weston**:
Distribution with Wayland/Weston graphic backend usage.
* **openstlinux-eglfs**:
Distribution dedicated to Qt usage. With this distribution, Qt uses the eglfs graphic backend.
* **openstlinux-x11**:
Distribution dedicated to X11 framework usage.

## Images
OpenSTLinux provides two reference image to be used mainly with **openstlinux-weston** distro:
* **st-image-core**:
Basic core image with: ssh server, several tools for kernel, audio,  network.
* **st-image-weston**:
Image with Wayland/weston UI (if **openstlinux-weston** distro are used).  This image contains weston UI, GTK+3 demo and all tools present on st-image-core.

OpenSTLinux provides also some image **as example** to show how to enable some specific framework:
* **st-example-image-qt** (with **openstlinux-eglfs** distro):
Image which demonstrates an example of Qt usage
* **st-example-image-x11** (with **openstlinux-x11** distro):
Image which demonstrates an example of Basic X11 usage.
* **st-example-image-xfce.bb** (with **openstlinux-x11** distro):
Image which demonstrates an example of X11 usage with XFCE as UI.
