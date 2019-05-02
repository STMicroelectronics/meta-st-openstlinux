PACKAGECONFIG = "udev bat"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

do_add_audio_sample_files() {
    cp ${S}/speaker-test/samples/Side_Left.wav ${S}/speaker-test/samples/Channel_12.wav
    cp ${S}/speaker-test/samples/Side_Right.wav ${S}/speaker-test/samples/Channel_13.wav
}
addtask add_audio_sample_files after do_unpack before do_patch
