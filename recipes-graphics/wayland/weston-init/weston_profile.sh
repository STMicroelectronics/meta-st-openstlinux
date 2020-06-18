export XDG_RUNTIME_DIR=/run/user/$(id -u)

export ELM_ENGINE=wayland_shm
export ECORE_EVAS_ENGINE=wayland_shm
export ECORE_EVAS_ENGINE=wayland_shm
export GDK_BACKEND=wayland

if [ $(id -u) -eq 0 ]; then
    mkdir --parents $XDG_RUNTIME_DIR
    chmod 0700 $XDG_RUNTIME_DIR
fi

