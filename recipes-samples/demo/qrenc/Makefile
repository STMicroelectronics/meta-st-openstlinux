all: qrencode

CFLAGS += -Wall $(shell pkg-config --cflags libqrencode libpng)
LDFLAGS += $(shell pkg-config --libs libqrencode libpng)

qrencode: qrenc.c
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

clean: ; rm -rf *.o qrencode
