#include <fcntl.h>
#include <linux/input.h>
#include <pthread.h>
#include <signal.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/timerfd.h>
#include <time.h>
#include <unistd.h>

#include <gtk/gtk.h>
#include <gdk/gdkscreen.h>
#include <cairo.h>

#include "copro.h"
#include "timer.h"

/* the supported board */
#define BOARD_TYPE_DK2             0
#define BOARD_TYPE_EV1             1

/* the supported touch screen */
#define EVENT_DEVICE_NAME_1        "EP0110M09"
#define EVENT_DEVICE_NAME_2        "generic ft5x06"
#define EVENT_DEVICE_NAME_3        "Goodix Capacitive TouchScreen"
#define EVENT_DEVICE_NAME_4        "BYZHYYZHY By ZH851 Touchscreen"

#define EVENT_TYPE_ABS             EV_ABS
#define EVENT_TYPE_KEY             EV_KEY
#define EVENT_CODE_X               ABS_X
#define EVENT_CODE_Y               ABS_Y
#define EVENT_TOUCH                BTN_TOUCH

#define LINE_BREAK                 0x0FFF

#define DISPLAY_DISCO_WIDTH        800
#define DISPLAY_DISCO_HEIGHT       480

#define DISPLAY_EVAL_WIDTH         1280
#define DISPLAY_EVAL_HEIGHT        720

#define DRAW_AREA_WIDTH            250
#define DRAW_AREA_HEIGHT           250
#define DRAW_AREA_MARGIN           20

#define TOUCH_DOWN                 1
#define TOUCH_UP                   0

#define TOUCH_COORDINATE_DEPTH     220

#define INPUT_IS_DIGIT_AND_LETTER  0
#define INPUT_IS_LETTER            1
#define INPUT_IS_DIGIT             2


typedef struct {
	int16_t x;
	int16_t y;
} touch_screen_coordinate_t;

typedef struct {
	uint8_t  character;
	uint8_t  accuracy;
	uint16_t elapsetime;
} ai_processing_result_t;

static volatile int keepRunning = 1;

static int aiProcessingDone;
static int aiProcessingRequested;
static int touchProcessingRequested;
static int threadClosingRequested = 0;
static int defaultInputType;
static ai_processing_result_t ai_result_state;
static pthread_mutex_t lock;
static pthread_t thread_copro, thread_touch, thread_gtk;
static char mByteBuffer[100];
static touch_screen_coordinate_t draw_touch_coordinate[TOUCH_COORDINATE_DEPTH];
static touch_screen_coordinate_t gtk_draw_polygon[TOUCH_COORDINATE_DEPTH];
static int touch_idx;
static size_t timer1 = 0, timer2 = 0, timer3 = 0;
static bool timer_running;
static uint16_t displayWidth;
static uint16_t displayHeight;
static char script_launcher[256];
static int script_launcher_nb_char;

static GtkWidget *window;

static void sleep_ms(int milliseconds)
{
	usleep(milliseconds * 1000);
}

void rpmsg_timeout_callback(size_t timer_id, void * user_data)
{
	/* in case we face an issue with the RPMsg communication => safely quit
	 * the application. */
	printf("rpmsg timeout callback\n");
	sprintf(script_launcher + script_launcher_nb_char, "%c", 0x51);
	printf("script to launch => %s\n", script_launcher);
	system(script_launcher);
}

static void copro_send_input_type(uint8_t input_type)
{
	char TXbuffer[] = {0x20, 0x01, input_type, 0x00};
	int len = sizeof(TXbuffer);
	char crc = copro_computeCRC(TXbuffer, len);
	int ret = 0;

	timer3 = timer_start(500, rpmsg_timeout_callback, NULL);

	TXbuffer[3] = crc;
	ret = copro_writeTtyRpmsg(len, TXbuffer);
	if (ret != len)
		printf("copro specify input type fails\n");
}

static void copro_send_touch_screen_coordinate(touch_screen_coordinate_t* draw_touch_coordinate)
{
	char TXbuffer[512];
	int len = 0;
	char crc = 0;
	int ret = 0;
	int i = 0;

	memset(&TXbuffer, 0, sizeof(TXbuffer));

	/* id of the command */
	TXbuffer[0] = 0x21;

	for (i = 0; i < TOUCH_COORDINATE_DEPTH ; i++) {
		if (draw_touch_coordinate[i].x != -1 && draw_touch_coordinate[i].y != -1) {
			/* send touch coordinate for a 28x28 buffer so divide
			 * it by 10 compared to the 280x280 original size */
			if ((draw_touch_coordinate[i].x == LINE_BREAK) ||
			    (draw_touch_coordinate[i].y == LINE_BREAK)) {
				TXbuffer[2 + (i * 2)] = 0xFF;
				TXbuffer[3 + (i * 2)] = 0xFF;
			} else {
				TXbuffer[2 + (i * 2)] = (uint8_t)(draw_touch_coordinate[i].x / 10);
				TXbuffer[3 + (i * 2)] = (uint8_t)(draw_touch_coordinate[i].y / 10);
			}
		} else {
			break;
		}
	}

	/* number of bytes to transfer */
	TXbuffer[1] = i * 2;

	/* crc computation */
	len = TXbuffer[1] + 3;
	crc = copro_computeCRC(TXbuffer, len);
	TXbuffer[len - 1] = crc;

	timer3 = timer_start(500, rpmsg_timeout_callback, NULL);

	ret = copro_writeTtyRpmsg(len, TXbuffer);
	if (ret != len)
		printf("send touch screen coordinate fails\n");
}

static void copro_start_ai_nn(void)
{
	char TXbuffer[] = {0x22, 0x01, 0x01, 0x00};
	int len = sizeof(TXbuffer);
	char crc = copro_computeCRC(TXbuffer, len);
	int ret = 0;

	timer3 = timer_start(500, rpmsg_timeout_callback, NULL);

	TXbuffer[3] = crc;
	ret = copro_writeTtyRpmsg(len, TXbuffer);
	if (ret != len)
		printf("send start ai nn command fails\n");
}

void timer_callback(size_t timer_id, void * user_data)
{
	pthread_mutex_lock(&lock);
	touchProcessingRequested = 1;
	pthread_mutex_unlock(&lock);
	//printf("timer callback\n");
}

void timer_gtk_callback(size_t timer_id, void * user_data)
{
	ai_result_state.character = 0;
	gtk_widget_queue_draw(window);
	//printf("timer_gtk_callback\n");
}

void process_touch_coordinate()
{
	int16_t min_x = displayWidth, max_x = 0;
	int16_t min_y = displayHeight, max_y = 0;
	int16_t offset_x = 0;
	int16_t offset_y = 0;
	float ratio_x = 0.0;
	float ratio_y = 0.0;

	printf("process_touch_coordinate\n");

	/* get the min and max coordinate */
	for (int i = 0; i < TOUCH_COORDINATE_DEPTH ; i++) {
		if ((draw_touch_coordinate[i].x != -1) &&
		    (draw_touch_coordinate[i].y != -1)) {
			//printf("%d {%d, %d}\n", i,
			//       draw_touch_coordinate[i].x,
			//       draw_touch_coordinate[i].y);
			if ((draw_touch_coordinate[i].x != LINE_BREAK) &&
			    (draw_touch_coordinate[i].y != LINE_BREAK)) {
				if (draw_touch_coordinate[i].x < min_x)
					min_x = draw_touch_coordinate[i].x;
				if (draw_touch_coordinate[i].x > max_x)
					max_x = draw_touch_coordinate[i].x;
				if (draw_touch_coordinate[i].y < min_y)
					min_y = draw_touch_coordinate[i].y;
				if (draw_touch_coordinate[i].y > max_y)
					max_y = draw_touch_coordinate[i].y;
			}
		} else {
			break;
		}
	}

	//printf("min {%d, %d} max{%d, %d}\n", min_x, min_y, max_x, max_y);

	/* Translate the coordinates to the origine */
	max_x = max_y = 0;
	for (int i = 0; i < TOUCH_COORDINATE_DEPTH ; i++) {
		if ((draw_touch_coordinate[i].x != -1) &&
		    (draw_touch_coordinate[i].y != -1)) {
			if ((draw_touch_coordinate[i].x != LINE_BREAK) &&
			    (draw_touch_coordinate[i].y != LINE_BREAK)) {
				draw_touch_coordinate[i].x = draw_touch_coordinate[i].x - min_x;
				draw_touch_coordinate[i].y = draw_touch_coordinate[i].y - min_y;

				if (draw_touch_coordinate[i].x > max_x)
					max_x = draw_touch_coordinate[i].x;
				if (draw_touch_coordinate[i].y > max_y)
					max_y = draw_touch_coordinate[i].y;
			}
			//printf("Translated %d {%d, %d}\n", i,
			//       draw_touch_coordinate[i].x,
			//       draw_touch_coordinate[i].y);
		} else {
			break;
		}
	}

	//printf("Translated max{%d, %d}\n", max_x, max_y);

	/* The draw should be rescale to fit the draw area 280x280 */
	ratio_x = (float)(max_x) / (float)(DRAW_AREA_WIDTH  - DRAW_AREA_MARGIN);
	ratio_y = (float)(max_y) / (float)(DRAW_AREA_HEIGHT - DRAW_AREA_MARGIN);
	//printf("ratio_x =%f ratio_y=%f\n", ratio_x, ratio_y);
	if (ratio_x < 1.0)
		ratio_x = 1.0;
	if (ratio_y < 1.0)
		ratio_y = 1.0;

	max_x = max_y = 0;
	for (int i = 0; i < TOUCH_COORDINATE_DEPTH ; i++) {
		if ((draw_touch_coordinate[i].x != -1) &&
		    (draw_touch_coordinate[i].y != -1)) {
			if ((draw_touch_coordinate[i].x != LINE_BREAK) &&
			    (draw_touch_coordinate[i].y != LINE_BREAK)) {
				draw_touch_coordinate[i].x = (int16_t)((float)draw_touch_coordinate[i].x / ratio_x);
				draw_touch_coordinate[i].y = (int16_t)((float)draw_touch_coordinate[i].y / ratio_y);

				if (draw_touch_coordinate[i].x > max_x)
					max_x = draw_touch_coordinate[i].x;
				if (draw_touch_coordinate[i].y > max_y)
					max_y = draw_touch_coordinate[i].y;
			}
			//printf("Rescaled %d {%d, %d}\n", i,
			//       draw_touch_coordinate[i].x,
			//       draw_touch_coordinate[i].y);
		} else {
			break;
		}
	}

	//printf("Rescaled max{%d, %d}\n", max_x, max_y);

	/* The draw should be centered in the 280x280 area */
	offset_x = (DRAW_AREA_WIDTH  - max_x) / 2;
	offset_y = (DRAW_AREA_HEIGHT - max_y) / 2;
	//printf("Offset {%d, %d} \n", offset_x, offset_y);

	for (int i = 0; i < TOUCH_COORDINATE_DEPTH ; i++) {
		if ((draw_touch_coordinate[i].x != -1) &&
		    (draw_touch_coordinate[i].y != -1)) {
			if ((draw_touch_coordinate[i].x != LINE_BREAK) &&
			    (draw_touch_coordinate[i].y != LINE_BREAK)) {
				draw_touch_coordinate[i].x = draw_touch_coordinate[i].x + offset_x;
				draw_touch_coordinate[i].y = draw_touch_coordinate[i].y + offset_y;
			}
			//printf("Centered %d {%d, %d}\n", i,
			//       draw_touch_coordinate[i].x,
			//       draw_touch_coordinate[i].y);

			gtk_draw_polygon[i].x = draw_touch_coordinate[i].x;
			gtk_draw_polygon[i].y = draw_touch_coordinate[i].y;
		} else {
			break;
		}
	}

	/* Send touch screen coordinate to the copro */
	copro_send_touch_screen_coordinate(draw_touch_coordinate);
}

static void copro_virtual_tty_process_read_data(char *data, int size)
{
	char uartRx[] = {0,0,0,0,0,0,0,0,0,0};
	int uartRxCnt = 0;

	/* stop the rpmsg timeout callback */
	timer_stop(timer3);

	for (int i = 0; i < size; i++) {
		uartRx[uartRxCnt++] = data[i];
	}

	// check if frame is complete
	if (uartRxCnt >= (uartRx[1]+3)) {
		if (uartRx[0] == 0xFF) {
			/* bad ack */
			printf("bad acknowledge from copro\n");
		} else {
			/* good ack */
			if (uartRx[1] == 0x00) {
				/*length is 0 means simple ack*/
				//printf("simple ack\n");
			} else if (uartRx[1] == 0x01) {
				/* length is 1 means coordinate are well take
				 * into account. Send the signal to start ai
				 * processing. */
				//printf("%d coordinates take into account", uartRx[2]);
				pthread_mutex_lock(&lock);
				aiProcessingRequested = 1;
				pthread_mutex_unlock(&lock);
			} else if (uartRx[1] == 0x04) {
				/*length is 4 means ai nn results*/
				char character = uartRx[2];
				char accuracy  = uartRx[3];
				uint16_t elapsetime = uartRx[4] << 8 | uartRx[5];

				pthread_mutex_lock(&lock);
				aiProcessingDone = 1;
				ai_result_state.character  = character;
				ai_result_state.accuracy   = accuracy;
				ai_result_state.elapsetime = elapsetime;
				pthread_mutex_unlock(&lock);
			}
		}
	} else {
		printf("frame received through ttyRPMSG is incomplete\n");
	}
}

/**
 * Definition for virtual ttyRPMSG thread
 */
static void *copro_vitural_tty_thread(void *arg)
{
	printf("create copro ttyRPMSG thread\n");

	/* open the ttyRPMSG in raw mode */
	if (copro_openTtyRpmsg(1)) {
		printf("fails to open the tty RPMSG\n");
		return NULL;
	}

	while (1) {
		int read = 0;

		if (threadClosingRequested == 1) {
			printf("close copro ttyRPMSG thread\n");
			break;
		}

		sleep_ms(1);

		/* Continuously read the ttyRPMSG */
		read = copro_readTtyRpmsg(512, mByteBuffer);
		if (read > 0) {
			//printf("RPMSG read %d byte(s)\n", read);
			copro_virtual_tty_process_read_data(mByteBuffer, read);
		}
	}

	copro_closeTtyRpmsg();

	int ret = 1;
	pthread_exit(&ret);
}

/**
 * Definition for touch event thread
 */
static void *read_touch_event_thread(void *arg)
{
	struct input_event ev;
	int fd;
	char event_dev_file[128];
	char event_dev_name[256] = "Unknown";
	int touch_rotate = 0;
	int n = 0;
	int i = 0;

	printf("create read touch event thread\n");

	if ((getuid ()) != 0) {
		fprintf(stderr, "You are not root! This may not work...\n");
		return NULL;
	}

	n = sprintf(event_dev_file, "/dev/input/event");
	/* Hack: pre loop to detect specific touchscreen */
	while (i < 20) {
		/* Parse all input event untill we found the right one */
		sprintf(event_dev_file + n, "%d", i);
		fd = open(event_dev_file, O_RDONLY);
		if (fd != -1) {
			ioctl(fd, EVIOCGNAME(sizeof(event_dev_name)), event_dev_name);
			if (strcmp(event_dev_name, EVENT_DEVICE_NAME_4) == 0) {
				displayWidth = DISPLAY_EVAL_WIDTH;
				displayHeight = DISPLAY_EVAL_HEIGHT;
				break;
			}
		}
		i++;
	}
	if (i == 20) {
		i = 0;
		while (i < 20) {
			/* Parse all input event untill we found the right one */
			sprintf(event_dev_file + n, "%d", i);
			fd = open(event_dev_file, O_RDONLY);
			if (fd != -1) {
				ioctl(fd, EVIOCGNAME(sizeof(event_dev_name)), event_dev_name);
				if ((strcmp(event_dev_name, EVENT_DEVICE_NAME_1) == 0) ||
				    (strncmp(event_dev_name, EVENT_DEVICE_NAME_2, strlen(EVENT_DEVICE_NAME_2)) == 0)) {
					displayWidth = DISPLAY_DISCO_WIDTH;
					displayHeight = DISPLAY_DISCO_HEIGHT;
					touch_rotate = 1;
					break;
				} else if (strcmp(event_dev_name, EVENT_DEVICE_NAME_3) == 0) {
					displayWidth = DISPLAY_EVAL_WIDTH;
					displayHeight = DISPLAY_EVAL_HEIGHT;
					touch_rotate = 1;
					break;
				}
			}
			i++;

			if (i == 20) {
				printf("no touch event device found\n");
				exit(0);
			}
		}
	}

	/* Print Device Name */
	printf("Reading from:\n");
	printf("device file = %s\n", event_dev_file);
	printf("device name = %s\n", event_dev_name);

	while (1) {
		const size_t ev_size = sizeof(struct input_event);
		ssize_t size;

		if (threadClosingRequested == 1) {
			printf("close read touch event thread\n");
			break;
		}

		size = read(fd, &ev, ev_size);
		pthread_mutex_lock(&lock);
		if (size < ev_size) {
			fprintf(stderr, "Error size when reading\n");
			close(fd);
			return NULL;
		}

		if (ev.type == EVENT_TYPE_KEY && ev.code == EVENT_TOUCH) {
			if (ev.value == TOUCH_DOWN) {
				if (timer1) {
					timer_stop(timer1);
					timer1= 0;
				}

				/*  Be sure that the timer 2 is stopped */
				if (timer2) {
					timer_stop(timer2);
					timer2 = 0;
					ai_result_state.character = 0;
					gtk_widget_queue_draw(window);
				}

				/* enter a line break */
				draw_touch_coordinate[touch_idx].x = LINE_BREAK;
				draw_touch_coordinate[touch_idx].y = LINE_BREAK;
				touch_idx++;
			} else {
				if (defaultInputType == 0) {
					/* configure default AI naural network input type */
					copro_send_input_type(INPUT_IS_LETTER);
					defaultInputType = 1;
				}
				timer1 = timer_start(500, timer_callback, NULL);
			}
		}

		if (ev.type == EVENT_TYPE_ABS && (ev.code == EVENT_CODE_X
					      || ev.code == EVENT_CODE_Y)) {
			if (touch_rotate) {
				/*  The UI is rotated take it into account */
				if (ev.code == EVENT_CODE_X)
					draw_touch_coordinate[touch_idx].y = ev.value;
				if (ev.code == EVENT_CODE_Y)
					draw_touch_coordinate[touch_idx].x = displayWidth - ev.value;
			} else {
				if (ev.code == EVENT_CODE_X)
					draw_touch_coordinate[touch_idx].x = ev.value;
				if (ev.code == EVENT_CODE_Y)
					draw_touch_coordinate[touch_idx].y = ev.value;
				if ((draw_touch_coordinate[touch_idx].x == 0) ||
				    (draw_touch_coordinate[touch_idx].y == 0)) {
					draw_touch_coordinate[touch_idx].x = -1;
					draw_touch_coordinate[touch_idx].y = -1;
				}
			}

			if ((draw_touch_coordinate[touch_idx].x != -1) &&
			    (draw_touch_coordinate[touch_idx].y != -1))
				touch_idx++;

			if (touch_idx >= TOUCH_COORDINATE_DEPTH) {
				printf("touch event overflow\n");
				memset(&draw_touch_coordinate, -1, sizeof(draw_touch_coordinate));
				draw_touch_coordinate[0].x = LINE_BREAK;
				draw_touch_coordinate[0].y = LINE_BREAK;
				touch_idx = 1;
			}
			gtk_widget_queue_draw(window);
		}
		pthread_mutex_unlock(&lock);
	}

	int ret = 1;
	pthread_exit(&ret);
}

static int get_board_type(void)
{
	char searchText[]="-ev1";
	int len_searchText;
	FILE *file;
	char string[128];
	int len_string;
	int i = 0;

	memset(string, 0x0, sizeof(string));

	file = fopen("/proc/device-tree/compatible", "r");
	if (file == NULL) {
		printf("fails to open /proc/device-tree/compatible\n");
		return -1;
	}

	len_searchText = strlen(searchText);

	while(fgets(string, sizeof(string), file) != 0)
	{
		len_string = strlen(string);
		for(i = 0 ; i < len_string ; i++) {
			if(strncmp(searchText, (string + i), len_searchText) == 0) {
				fclose(file);
				return BOARD_TYPE_EV1;
			}
		}
	}
	fclose(file);

	return BOARD_TYPE_DK2;
}

static int copro_start(void)
{
	int ret = 0;
	int board_type = -1;
	char FwName[128];

	memset(FwName, 0x00, sizeof(FwName));

	/* check if copro is already running */
	ret = copro_isFwRunning();
	if (ret) {
		// check FW name
		int nameLength = copro_getFwName(FwName);

		if (strncmp(FwName, FIRMWARE_NAME, nameLength) == 0) {
			printf("%s is already running.\n", FIRMWARE_NAME);
			goto fwrunning;
		}else {
			printf("%s wrong firmware running. Stop it.\n", FwName);
			if (copro_stopFw()) {
				printf("fails to stop firmware\n");
				goto end;
			}
		}
	}

	/* get the type of the board */
	board_type = get_board_type();
	if (board_type == -1) {
		printf("fails to get the board type\n");
		ret = 1;
		goto end;
	}

	/* make a symbolic link to the firmware to use according to the board */
	char symlink1[256];
	char symlink2[256];
	if (board_type == BOARD_TYPE_EV1)
		sprintf(symlink1, "%s/%s", FIRMWARE_PATH_EV1, FIRMWARE_NAME);
	else
		sprintf(symlink1, "%s/%s", FIRMWARE_PATH_DK2, FIRMWARE_NAME);
	sprintf(symlink2, "/lib/firmware/%s", FIRMWARE_NAME);
	symlink(symlink1, symlink2);

	/* set the firmware name to load */
	ret = copro_setFwName(FIRMWARE_NAME);
	if (ret <= 0) {
		printf("fails to change the firmware name\n");
		goto end;
	}

	/* start the firmware */
	ret = copro_startFw();
	if (ret) {
		printf("fails to start the firmware\n");
		goto end;
	}

	/* check if copro is already running */
	ret = copro_isFwRunning();
	if (ret)
		printf("copro firmware is running.\n");
	else
		printf("copro firmware is not running.\n");

	/* wait for 1 seconds the creation of the virtual ttyRPMSGx */
	sleep_ms(1000);

fwrunning:
	ret = 0;
	if (pthread_create(&thread_copro, NULL, copro_vitural_tty_thread, NULL) != 0) {
		printf("copro_vitural_tty_thread creation fails\n");
		ret = -1;
		goto end;
	}

end:
	return ret;
}


gboolean background_draw_callback(GtkWidget *widget, cairo_t *cr, gpointer data)
{
	/* draw the background */
	cairo_set_source_rgba (cr, 0.31, 0.32, 0.31, 0.8); /* grey transparent */
	cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE);
	cairo_paint (cr);

	return FALSE;
}


gboolean draw_callback(GtkWidget *widget, cairo_t *cr, gpointer data)
{
	char character[16];
	bool line_break = false;

	cairo_save(cr);

	sprintf(character, "%c", (char)ai_result_state.character);

	/* draw the background */
	cairo_set_source_rgba (cr, 0.31, 0.32, 0.31, 0.0); /* transparent */
	cairo_set_operator (cr, CAIRO_OPERATOR_SOURCE);
	cairo_paint (cr);

	/* display title */
	cairo_select_font_face (cr, "monospace",
				CAIRO_FONT_SLANT_NORMAL,
				CAIRO_FONT_WEIGHT_BOLD);
	cairo_set_font_size (cr, 25);
	cairo_set_source_rgb (cr, 1, 1, 1);
	cairo_move_to (cr, 20, 25);
	cairo_show_text (cr, "Hand Writing Character Recognition");

	cairo_set_font_size (cr, 15);
	cairo_move_to (cr, 20, 50);
	cairo_show_text (cr, "AI NN library is running on the Cortex®-M4 coprocessor");

	/* draw the recognize character */
	cairo_select_font_face (cr, "monospace",
				CAIRO_FONT_SLANT_NORMAL,
				CAIRO_FONT_WEIGHT_BOLD);
	cairo_set_font_size (cr, 40);
	cairo_set_source_rgb (cr, 1, 1, 1);
	cairo_move_to (cr, 20, 105);
	cairo_show_text (cr, character);

	/* draw the hand writen character as an icon */
	cairo_set_source_rgb (cr,  1, 1, 1);
	cairo_set_line_width (cr, 4);
	cairo_translate (cr, 10, 115);
	for (int i = 0; i < TOUCH_COORDINATE_DEPTH ; i++) {
		if ((gtk_draw_polygon[i].x != -1) &&
		    (gtk_draw_polygon[i].y != -1)) {
			if ((gtk_draw_polygon[i].x == LINE_BREAK) ||
			    (gtk_draw_polygon[i].y == LINE_BREAK)) {
				line_break = true;
				//printf("line_break detected\n");
				continue;
			}
			//printf("draw {%d, %d}\n",
			//       (int)(gtk_draw_polygon[i].x / 5),
			//       (int)(gtk_draw_polygon[i].y / 5));
			if (line_break) {
				cairo_move_to (cr,
					       (int)(gtk_draw_polygon[i].x / 5),
					       (int)(gtk_draw_polygon[i].y / 5));
			} else {
				cairo_line_to (cr,
					       (int)(gtk_draw_polygon[i].x / 5),
					       (int)(gtk_draw_polygon[i].y / 5));
			}
			line_break = false;
		} else {
			break;
		}
	}
	cairo_stroke_preserve(cr);

	memset(&gtk_draw_polygon, -1, sizeof(gtk_draw_polygon));

	/* display help */
	cairo_select_font_face (cr, "monospace",
				CAIRO_FONT_SLANT_NORMAL,
				CAIRO_FONT_WEIGHT_BOLD);
	cairo_set_font_size (cr, 15);
	/* return to the origine */
	cairo_translate (cr, -10, -115);

	if(strcmp(character, "A") == 0)
		cairo_set_source_rgb (cr, 212, 0, 122);
	else
		cairo_set_source_rgb (cr, 1, 1, 1);
	cairo_move_to (cr, 20, 185);
	cairo_show_text (cr, "A = Audio");

	if(strcmp(character, "C") == 0)
		cairo_set_source_rgb (cr, 212, 0, 122);
	else
		cairo_set_source_rgb (cr, 1, 1, 1);
	cairo_move_to (cr, 20, 205);
	cairo_show_text (cr, "C = Camera");

	if(strcmp(character, "P") == 0)
		cairo_set_source_rgb (cr, 212, 0, 122);
	else
		cairo_set_source_rgb (cr, 1, 1, 1);
	cairo_move_to (cr, 20, 225);
	cairo_show_text (cr, "P = Picture");

	if(strcmp(character, "V") == 0)
		cairo_set_source_rgb (cr, 212, 0, 122);
	else
		cairo_set_source_rgb (cr, 1, 1, 1);
	cairo_move_to (cr, 20, 245);
	cairo_show_text (cr, "V = Video");

	if(strcmp(character, "S") == 0)
		cairo_set_source_rgb (cr, 212, 0, 122);
	else
		cairo_set_source_rgb (cr, 1, 1, 1);
	cairo_move_to (cr, 20, 265);
	cairo_show_text (cr, "S = Stop");

	if(strcmp(character, "Q") == 0)
		cairo_set_source_rgb (cr, 212, 0, 122);
	else
		cairo_set_source_rgb (cr, 1, 1, 1);
	cairo_move_to (cr, 20, 285);
	cairo_show_text (cr, "Q = Quit");

	cairo_restore(cr);

	/* draw the hand writen character in live */
	cairo_set_source_rgb (cr,  1, 1, 1);
	cairo_set_line_width (cr, 4);
	for (int i = 0; i < TOUCH_COORDINATE_DEPTH ; i++) {
		if ((draw_touch_coordinate[i].x != -1) &&
		    (draw_touch_coordinate[i].y != -1)) {
			if ((draw_touch_coordinate[i].x == LINE_BREAK) ||
			    (draw_touch_coordinate[i].y == LINE_BREAK)) {
				line_break = true;
				//printf("line_break detected\n");
				continue;
			}
			//printf("draw {%d, %d}\n",
			//       (int)(draw_touch_coordinate[i].x),
			//       (int)(draw_touch_coordinate[i].y));
			if (line_break) {
				cairo_move_to (cr,
					       (int)(draw_touch_coordinate[i].x),
					       (int)(draw_touch_coordinate[i].y));
			} else {
				cairo_line_to (cr,
					       (int)(draw_touch_coordinate[i].x),
					       (int)(draw_touch_coordinate[i].y));
			}
			line_break = false;
		} else {
			break;
		}
	}
	cairo_stroke_preserve(cr);

	return FALSE;
}

/**
 * Definition for gtk popup thread
 */
static void *gtk_popup_thread(void *arg)
{
	GtkWidget *background;
	GtkWidget *background_drawing_area;
	GtkWidget *drawing_area;

	/* init gtk */
	gtk_init (NULL, NULL);

	background = gtk_window_new (GTK_WINDOW_TOPLEVEL);
	g_signal_connect(G_OBJECT(background), "delete-event", gtk_main_quit, NULL);
	/* remove title bar */
	gtk_window_set_decorated (GTK_WINDOW (background), FALSE);
	/* tell GTK that we want to draw the background ourself */
	gtk_widget_set_app_paintable(background, TRUE);
	gtk_window_maximize(GTK_WINDOW (background));
	//gtk_window_fullscreen(GTK_WINDOW (window));

	background_drawing_area= gtk_drawing_area_new();
	gtk_container_add (GTK_CONTAINER (background), background_drawing_area);
	g_signal_connect(G_OBJECT(background_drawing_area),"draw", G_CALLBACK(background_draw_callback),NULL);

	gtk_widget_show_all (background);

	window = gtk_window_new (GTK_WINDOW_TOPLEVEL);
	g_signal_connect(G_OBJECT(window), "delete-event", gtk_main_quit, NULL);
	/* remove title bar */
	gtk_window_set_decorated (GTK_WINDOW (window), FALSE);
	/* tell GTK that we want to draw the background ourself */
	gtk_widget_set_app_paintable(window, TRUE);
	gtk_window_maximize(GTK_WINDOW (window));
	//gtk_window_fullscreen(GTK_WINDOW (window));

	drawing_area= gtk_drawing_area_new();
	gtk_container_add (GTK_CONTAINER (window), drawing_area);
	g_signal_connect(G_OBJECT(drawing_area),"draw", G_CALLBACK(draw_callback),NULL);

	gtk_widget_show_all (window);
	/* enter the GTK main loop */
	gtk_main();

	return NULL;
}

static void intHandler(int dummy)
{
	keepRunning = 0;
	threadClosingRequested = 1;
}

int main(int argc, char **argv)
{
	void *ret;

	/* Catch CTRL + C signal*/
	signal(SIGINT, intHandler);
	/* Catch kill signal */
	signal(SIGTERM, intHandler);

	if (argc != 2) {
		goto usage;
	}

	script_launcher_nb_char = sprintf(script_launcher, "%s ",  argv[1]);
	printf("script_launcher = %s\n", script_launcher);
	printf("firmware path DK2=%s\n", FIRMWARE_PATH_DK2);
	printf("firmware path EV1=%s\n", FIRMWARE_PATH_EV1);

	if (pthread_mutex_init(&lock, NULL) != 0) {
		fprintf(stderr,"mutex init failed\n");
		goto end;
	}

	if (copro_start())
		goto end;

	/* set initial state */
	ai_result_state.character  = 0;
	ai_result_state.accuracy   = 0;
	ai_result_state.elapsetime = 0;
	threadClosingRequested = 0;
	touchProcessingRequested = 0;
	aiProcessingRequested = 0;
	aiProcessingDone = 0;
	defaultInputType = 0;

	if (pthread_create(&thread_touch, NULL, read_touch_event_thread, NULL) != 0) {
		printf("read_touch_event_thread creation fails\n");
		goto end;
	}

	if (pthread_create(&thread_gtk, NULL, gtk_popup_thread, NULL) != 0) {
		printf("gtk_popup_thread creation fails\n");
		goto end;
	}

	memset(&draw_touch_coordinate, -1, sizeof(draw_touch_coordinate));
	memset(&gtk_draw_polygon, -1, sizeof(draw_touch_coordinate));

	touch_idx = 0;

	timer_init();
	timer_running = false;

	while(keepRunning) {
		sleep_ms(1);

		if (touchProcessingRequested == 1) {
			pthread_mutex_lock(&lock);
			/* Process touch events */
			touchProcessingRequested = 0;
			pthread_mutex_unlock(&lock);
			process_touch_coordinate();
		}

		if (aiProcessingRequested == 1) {
			pthread_mutex_lock(&lock);
			aiProcessingRequested = 0;
			pthread_mutex_unlock(&lock);
			/* Run the NN to start the character recognition */
			copro_start_ai_nn();
			memset(&draw_touch_coordinate, -1, sizeof(draw_touch_coordinate));
			touch_idx = 0;
		}

		if (aiProcessingDone == 1) {
			pthread_mutex_lock(&lock);
			aiProcessingDone = 0;
			pthread_mutex_unlock(&lock);

			printf("Result=0x%x, (%d percent %dms)\n",
			       ai_result_state.character,
			       ai_result_state.accuracy,
			       ai_result_state.elapsetime);

			gtk_widget_queue_draw(window);
			timer2 = timer_start(2000, timer_gtk_callback, NULL);

			/* Call the script that will launch applications based
			 * on the letter recognized.
			 */
			sprintf(script_launcher + script_launcher_nb_char, "%c", (char)ai_result_state.character);
			printf("script to launch => %s\n", script_launcher);
			system(script_launcher);
			printf("script launched\n");
		}
	}

	pthread_join(thread_copro, &ret);
	pthread_kill(thread_touch, 0);
	pthread_kill(thread_gtk, 0);

	timer_finalize();

end:
	/* check if copro is already running */
	if (copro_isFwRunning()) {
		printf("stop the firmware before exit\n");
		copro_stopFw();
	}

	/* delete the firmware symbolic link */
	//char symlink[256];
	//sprintf(symlink, "/lib/firmware/%s", FIRMWARE_NAME);
	//remove(symlink);
	return EXIT_SUCCESS;

usage:
	printf ("USAGE: ai_char_reco_launcher [<absolute launcher script path>]\n");
	return EXIT_FAILURE;
}
