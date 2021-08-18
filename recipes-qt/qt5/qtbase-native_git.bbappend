# we may encouter some undefined references with the linux kernel statx function
# depending on the ACI machines / Yocto cache / zoostrap versions
QT_CONFIG_FLAGS += "-no-feature-statx"
