#!/bin/sh

video() {
    echo "Launch video"
    gst-launch-1.0 playbin uri=file:///usr/local/demo/media/Teaser-STM32MP1.webm video-sink="waylandsink sync=false" audio-sink="fakesink" &
}

audio() {
    echo "Launch audio"
    gst-launch-1.0 playbin uri=file:///usr/local/demo/media/ST12266_269_full_technology-freaks_0160.ogg &
}

picture() {
    echo "Display picture"
    gst-launch-1.0 filesrc location=/usr/local/demo/media/stm32cubeai.png ! pngdec !  videoconvert ! imagefreeze ! glimagesink &
}

camera() {
    echo "Launch preview camera"
    v4l2-ctl --set-parm=20
    gst-launch-1.0 v4l2src ! "video/x-raw, format=YUY2, width=320, height=240" ! waylandsink &
}

kill_all() {
    echo "kill previous app"
    killall gst-launch-1.0
}

quit() {
    kill_all
    killall ai_char_reco_launcher
}

case "$1" in
V)
    video
    ;;
S)
    kill_all
    ;;
A)
    audio
    ;;
P)
    picture
    ;;
C)
    camera
    ;;
Q)
    quit
    ;;
*)
    echo "HELP: $0 [command]"
    echo "available commands:"
    echo "    V (launch video)"
    echo "    A (Launch audio)"
    echo "    P (Display picture)"
    echo "    C (Launch preview camera)"
    echo "    S (kill previous app)"
    echo "    Q (quit the launcher)"
    ;;
esac

exit 0

