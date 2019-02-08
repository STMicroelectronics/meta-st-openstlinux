FIRMWARE_PATH_DK2?="/usr/local/Cube-M4-examples/STM32MP157C-DK2/Demonstrations/AI_Character_Recognition/lib/firmware"
FIRMWARE_PATH_EV1?="/usr/local/Cube-M4-examples/STM32MP157C-EV1/Demonstrations/AI_Character_Recognition/lib/firmware"
FIRMWARE_NAME?="AI_Character_Recognition.elf"


# support GTK
CFLAGS += -Wall $(shell pkg-config --cflags gtk+-3.0)
LDFLAGS += $(shell pkg-config --libs gtk+-3.0)

all: ai_char_reco_launcher

ai_char_reco_launcher: copro.c timer.c ai_char_reco_launcher.c
	$(CC) -DFIRMWARE_PATH_DK2='"${FIRMWARE_PATH_DK2}"' -DFIRMWARE_PATH_EV1='"${FIRMWARE_PATH_EV1}"' -DFIRMWARE_NAME='"${FIRMWARE_NAME}"' -o $@ $^ $(CFLAGS) $(LDFLAGS)

clean: ; rm -rf *.o ai_char_reco_launcher
