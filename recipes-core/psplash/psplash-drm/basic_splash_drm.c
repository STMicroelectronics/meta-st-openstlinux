/*
* basic_splash_drm.c - Basic splash screen on DRM
*
* Inspired by the code of modeset:
*   https://github.com/dvdhrm/docs/blob/master/drm-howto/modeset.c
*   Written 2012 by David Herrmann <dh.herrmann@googlemail.com>
*
*
*/

#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>
#include <xf86drm.h>
#include <xf86drmMode.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "image_header.h"


#define SPLASH_FIFO "/tmp/splash_fifo"

#define MAX_HEIGHT_THRESHOLD 720
//-----------------------
// Static variable
static int drm_fd;
static int pipe_fd;
static int wait = 0;

//----------------------
// Prototype
struct modeset_dev;
static int modeset_find_crtc (int fd, drmModeRes * res,
        drmModeConnector * conn,
        struct modeset_dev *dev);
static int modeset_create_fb (int fd, struct modeset_dev *dev);
static int modeset_setup_dev (int fd, drmModeRes * res,
        drmModeConnector * conn,
        struct modeset_dev *dev);
static int modeset_open (int *out, const char *node);
static int modeset_prepare (int fd);
static void modeset_draw_bgcolor (uint8_t r_p, uint8_t g_p, uint8_t b_p);
static void modeset_cleanup (int fd);

static void splash_draw_image_center (void);


//-------------------------------
// Modeset function
static int
modeset_open (int *out, const char *node)
{
    int fd, ret;
    uint64_t has_dumb;

    fd = open (node, O_RDWR | O_CLOEXEC);
    if (fd < 0) {
        ret = -errno;
        fprintf (stderr, "cannot open '%s': %m\n", node);
        return ret;
    }
    if (drmGetCap (fd, DRM_CAP_DUMB_BUFFER, &has_dumb) < 0 || !has_dumb) {
        fprintf (stderr, "drm device '%s' does not support dumb buffers\n",
                node);
        close (fd);
        return -EOPNOTSUPP;
    }

    *out = fd;
    return 0;
}


struct modeset_dev
{
    struct modeset_dev *next;

    uint32_t width;
    uint32_t height;
    uint32_t stride;
    uint32_t size;
    uint32_t handle;
    uint8_t *map;

    drmModeModeInfo mode;
    uint32_t fb;
    uint32_t conn;
    uint32_t crtc;
    drmModeCrtc *saved_crtc;
};

static struct modeset_dev *modeset_list = NULL;

static int
modeset_prepare (int fd)
{
    drmModeRes *res;
    drmModeConnector *conn;
    unsigned int i;
    struct modeset_dev *dev;
    int ret;

    /* retrieve resources */
    res = drmModeGetResources (fd);
    if (!res) {
        fprintf (stderr, "cannot retrieve DRM resources (%d): %m\n", errno);
        return -errno;
    }

    /* iterate all connectors */
    for (i = 0; i < res->count_connectors; ++i)
    {
        /* get information for each connector */
        conn = drmModeGetConnector (fd, res->connectors[i]);
        if (!conn) {
            fprintf (stderr, "cannot retrieve DRM connector %u:%u (%d): %m\n",
                    i, res->connectors[i], errno);
            continue;
        }
        /* create a device structure */
        dev = malloc (sizeof (*dev));
        memset (dev, 0, sizeof (*dev));
        dev->conn = conn->connector_id;

        /* call helper function to prepare this connector */
        ret = modeset_setup_dev (fd, res, conn, dev);
        if (ret) {
            if (ret != -ENOENT) {
                errno = -ret;
                fprintf (stderr,
                        "cannot setup device for connector %u:%u (%d): %m\n",
                        i, res->connectors[i], errno);
            }
            free (dev);
            drmModeFreeConnector (conn);
            continue;
        }

        /* free connector data and link device into global list */
        drmModeFreeConnector (conn);
        dev->next = modeset_list;
        modeset_list = dev;
    }

    /* free resources again */
    drmModeFreeResources (res);
    return 0;
}


static int
modeset_setup_dev (int fd,
        drmModeRes * res,
        drmModeConnector * conn, struct modeset_dev *dev)
{
    int mode, ret;

    /* check if a monitor is connected */
    if (conn->connection != DRM_MODE_CONNECTED) {
        fprintf (stderr, "ignoring unused connector %u\n", conn->connector_id);
        return -ENOENT;
    }

    /* check if there is at least one valid mode */
    if (conn->count_modes == 0) {
        fprintf (stderr, "no valid mode for connector %u\n",
                conn->connector_id);
        return -EFAULT;
    }

    mode = 0;
    if (conn->count_modes > 1) {
        /*  Kick out any resolution above 720p */
        for (mode = 0; mode < conn->count_modes; mode++) {
            if (conn->modes[mode].vdisplay <= MAX_HEIGHT_THRESHOLD) {
                fprintf (stderr, "Defaulting to 720p - id:%d\n", mode);
                break;
            }
        }
        if (mode >= conn->count_modes)
            mode = 0;
    }

    /* copy the mode information into our device structure */
    memcpy (&dev->mode, &conn->modes[mode], sizeof (dev->mode));
    dev->width = conn->modes[mode].hdisplay;
    dev->height = conn->modes[mode].vdisplay;
    fprintf (stderr, "mode for connector %u is %ux%u\n",
            conn->connector_id, dev->width, dev->height);

    /* find a crtc for this connector */
    ret = modeset_find_crtc (fd, res, conn, dev);
    if (ret) {
        fprintf (stderr, "no valid crtc for connector %u\n",
                conn->connector_id);
        return ret;
    }

    /* create a framebuffer for this CRTC */
    ret = modeset_create_fb (fd, dev);
    if (ret) {
        fprintf (stderr, "cannot create framebuffer for connector %u\n",
                conn->connector_id);
        return ret;
    }
    return 0;
}

static int
modeset_find_crtc (int fd, drmModeRes * res, drmModeConnector * conn,
        struct modeset_dev *dev)
{
    drmModeEncoder *enc;
    unsigned int i, j;
    int32_t crtc;
    struct modeset_dev *iter;

    /* first try the currently conected encoder+crtc */
    if (conn->encoder_id)
        enc = drmModeGetEncoder (fd, conn->encoder_id);
    else
        enc = NULL;

    if (enc) {
        if (enc->crtc_id) {
            crtc = enc->crtc_id;
            for (iter = modeset_list; iter; iter = iter->next) {
                if (iter->crtc == crtc) {
                    crtc = -1;
                    break;
                }
            }
            if (crtc >= 0) {
                drmModeFreeEncoder (enc);
                dev->crtc = crtc;
                return 0;
            }
        }
        drmModeFreeEncoder (enc);
    }

    /* If the connector is not currently bound to an encoder or if the
     * encoder+crtc is already used by another connector (actually unlikely
     * but lets be safe), iterate all other available encoders to find a
     * matching CRTC. */
    for (i = 0; i < conn->count_encoders; ++i) {
        enc = drmModeGetEncoder (fd, conn->encoders[i]);
        if (!enc) {
            fprintf (stderr, "cannot retrieve encoder %u:%u (%d): %m\n",
                    i, conn->encoders[i], errno);
            continue;
        }

        /* iterate all global CRTCs */
        for (j = 0; j < res->count_crtcs; ++j) {
            /* check whether this CRTC works with the encoder */
            if (!(enc->possible_crtcs & (1 << j)))
                continue;
            /* check that no other device already uses this CRTC */
            crtc = res->crtcs[j];
            for (iter = modeset_list; iter; iter = iter->next) {
                if (iter->crtc == crtc) {
                    crtc = -1;
                    break;
                }
            }
            /* we have found a CRTC, so save it and return */
            if (crtc >= 0) {
                drmModeFreeEncoder (enc);
                dev->crtc = crtc;
                return 0;
            }
        }
        drmModeFreeEncoder (enc);
    }

    fprintf (stderr, "cannot find suitable CRTC for connector %u\n",
            conn->connector_id);
    return -ENOENT;
}


static int
modeset_create_fb (int fd, struct modeset_dev *dev)
{
    struct drm_mode_create_dumb creq;
    struct drm_mode_destroy_dumb dreq;
    struct drm_mode_map_dumb mreq;
    int ret;

    /* create dumb buffer */
    memset (&creq, 0, sizeof (creq));
    creq.width = dev->width;
    creq.height = dev->height;
    creq.bpp = 32;
    ret = drmIoctl (fd, DRM_IOCTL_MODE_CREATE_DUMB, &creq);
    if (ret < 0) {
        fprintf (stderr, "cannot create dumb buffer (%d): %m\n", errno);
        return -errno;
    }
    dev->stride = creq.pitch;
    dev->size = creq.size;
    dev->handle = creq.handle;

    /* create framebuffer object for the dumb-buffer */
    ret = drmModeAddFB (fd, dev->width, dev->height, 24, 32, dev->stride,
          dev->handle, &dev->fb);
    if (ret) {
        fprintf (stderr, "cannot create framebuffer (%d): %m\n", errno);
        ret = -errno;
        goto err_destroy;
    }

    /* prepare buffer for memory mapping */
    memset (&mreq, 0, sizeof (mreq));
    mreq.handle = dev->handle;
    ret = drmIoctl (fd, DRM_IOCTL_MODE_MAP_DUMB, &mreq);
    if (ret) {
        fprintf (stderr, "cannot map dumb buffer (%d): %m\n", errno);
        ret = -errno;
        goto err_fb;
    }

    /* perform actual memory mapping */
    dev->map = mmap (0, dev->size, PROT_READ | PROT_WRITE, MAP_SHARED,
          fd, mreq.offset);
    if (dev->map == MAP_FAILED) {
        fprintf (stderr, "cannot mmap dumb buffer (%d): %m\n", errno);
        ret = -errno;
        goto err_fb;
    }

    /* clear the framebuffer to 0 */
    memset (dev->map, 0, dev->size);

    return 0;

err_fb:
    drmModeRmFB (fd, dev->fb);
err_destroy:
    memset (&dreq, 0, sizeof (dreq));
    dreq.handle = dev->handle;
    drmIoctl (fd, DRM_IOCTL_MODE_DESTROY_DUMB, &dreq);
    return ret;
}

static void
modeset_draw_bgcolor (uint8_t r_p, uint8_t g_p, uint8_t b_p)
{
    uint8_t r, g, b;
    unsigned int j, k, off;
    struct modeset_dev *iter;

    srand (time (NULL));
    r = r_p & 0xff;
    g = g_p & 0xff;
    b = b_p & 0xff;

    for (iter = modeset_list; iter; iter = iter->next) {
        for (j = 0; j < iter->height; ++j) {
            for (k = 0; k < iter->width; ++k) {
                off = iter->stride * j + k * 4;
                *(uint32_t *) & iter->map[off] = (r << 16) | (g << 8) | b;
            }
        }
    }
}
static void
modeset_cleanup (int fd)
{
    struct modeset_dev *iter;
    struct drm_mode_destroy_dumb dreq;

    while (modeset_list) {
        /* remove from global list */
        iter = modeset_list;
        modeset_list = iter->next;

        /* restore saved CRTC configuration */
        drmModeSetCrtc (fd,
                iter->saved_crtc->crtc_id,
                iter->saved_crtc->buffer_id,
                iter->saved_crtc->x,
                iter->saved_crtc->y,
                &iter->conn, 1,
                &iter->saved_crtc->mode);
        drmModeFreeCrtc (iter->saved_crtc);

        /* unmap buffer */
        munmap (iter->map, iter->size);

        /* delete framebuffer */
        drmModeRmFB (fd, iter->fb);

        /* delete dumb buffer */
        memset (&dreq, 0, sizeof (dreq));
        dreq.handle = iter->handle;
        drmIoctl (fd, DRM_IOCTL_MODE_DESTROY_DUMB, &dreq);

        /* free allocated memory */
        free (iter);
    }
}

//-------------------------------
// Draw function
static void
splash_draw_image_for_modeset (struct modeset_dev *iter,
        int x,
        int y,
        int img_width,
        int img_height,
        int img_bytes_per_pixel,
        uint8_t * rle_data)
{
    uint8_t *p = rle_data;
    int dx = 0, dy = 0, total_len;
    unsigned int len;
    unsigned int off;

    total_len = img_width * img_height * img_bytes_per_pixel;

    while ((p - rle_data) < total_len) {
        len = *(p++);

        if (len & 128) {
            len -= 128;

            if (len == 0) break;
            do {
                if (img_bytes_per_pixel < 4 || *(p + 3)) {
                    off = iter->stride * (y + dy) + (x + dx) * 4;
                    *(uint32_t *) & iter->map[off] =
                        (*(p) << 16) | (*(p + 1) << 8) | *(p + 2);
                }
                if (++dx >= img_width) {
                    dx = 0;
                    dy++;
                }
            } while (--len && (p - rle_data) < total_len);

            p += img_bytes_per_pixel;
        }
        else {
            if (len == 0) break;
            do {
                if (img_bytes_per_pixel < 4 || *(p + 3)) {
                    off = iter->stride * (y + dy) + (x + dx) * 4;
                    *(uint32_t *) & iter->map[off] =
                        (*(p) << 16) | (*(p + 1) << 8) | *(p + 2);
                }
                if (++dx >= img_width) {
                    dx = 0;
                    dy++;
                }
                p += img_bytes_per_pixel;
            } while (--len && (p - rle_data) < total_len);
        }
    }
}


static void
splash_draw_image_center (void)
{
    struct modeset_dev *iter;
    int img_width, img_height, img_bytes_per_pixel;
    uint8_t *rle_data;
    int x, y;

    for (iter = modeset_list; iter; iter = iter->next) {
        if (iter->width >= iter->height) {
            /* Default mode is landscape, ie. use image with no rotation */
            img_width = SPLASH_IMG_WIDTH;
            img_height = SPLASH_IMG_HEIGHT;
            img_bytes_per_pixel = SPLASH_IMG_BYTES_PER_PIXEL;
            rle_data = SPLASH_IMG_RLE_PIXEL_DATA;
        } else {
            /* Else portrait, ie. use image with 90 degree rotation */
            img_width = SPLASH_IMG_ROT_WIDTH;
            img_height = SPLASH_IMG_ROT_HEIGHT;
            img_bytes_per_pixel = SPLASH_IMG_ROT_BYTES_PER_PIXEL;
            rle_data = SPLASH_IMG_ROT_RLE_PIXEL_DATA;
        }

        x = (iter->width - img_width) / 2;
        y = (iter->height - img_height) / 2;
        splash_draw_image_for_modeset (iter, x, y, img_width, img_height,
                img_bytes_per_pixel, rle_data);
    }
}

//-------------------------------
// Exit function
void
splash_exit (int signum)
{
    modeset_cleanup (drm_fd);
    close(pipe_fd);
}
//-------------------------------
// fifo processing message
static int
parse_command (char *string, int length)
{
    char *command;
    //int   parsed=0;
    //parsed = strlen(string)+1;

    fprintf(stderr, "got cmd %s", string);
    if (strcmp(string,"QUIT") == 0)
        return 1;

    command = strtok(string," ");

    if (!strcmp(command,"PROGRESS")) {
        //psplash_draw_progress (fb, atoi(strtok(NULL,"\0")));
    }
    else if (!strcmp(command,"MSG")) {
        //psplash_draw_msg (fb, strtok(NULL,"\0"));
    }
    else if (!strcmp(command,"QUIT")) {
        return 1;
    }
    return 0;
}

void
splash_processing ()
{
    int            err;
    ssize_t        length = 0;
    fd_set         descriptors;
    struct timeval tv;
    char          *end;
    char           command[2048];
    int            timeout = 2; //2 sec

    tv.tv_sec = timeout;
    tv.tv_usec = 0;

    FD_ZERO(&descriptors);
    FD_SET(pipe_fd, &descriptors);

    end = command;

    if (wait > 0)
        timeout = 0;
    while (1) {
        if (timeout != 0)
            err = select(pipe_fd+1, &descriptors, NULL, NULL, &tv);
        else
            err = select(pipe_fd+1, &descriptors, NULL, NULL, NULL);
        if (err <= 0) {
            return;
        }
        length += read (pipe_fd, end, sizeof(command) - (end - command));
        if (length == 0) {
            /* Reopen to see if there's anything more for us */
            close(pipe_fd);
            pipe_fd = open(SPLASH_FIFO,O_RDONLY|O_NONBLOCK);
            goto out;
        }
        if (command[length-1] == '\0') {
            fprintf(stderr, "1 %m\n");
            if (parse_command(command, strlen(command)))
                return;
            length = 0;
        }
        else if (command[length-1] == '\n') {
            command[length-1] = '\0';
            if (parse_command(command, strlen(command)))
                return;
            length = 0;
        }
    out:
      end = &command[length];

      tv.tv_sec = timeout;
      tv.tv_usec = 0;

      FD_ZERO(&descriptors);
      FD_SET(pipe_fd,&descriptors);
    }

    return;
}

//-------------------------------
// Main function
int
main (int argc, char **argv)
{
    int ret;
    const char *card;
    struct modeset_dev *iter;
    char *tmpdir;

    /* check which DRM device to open */
    //if (argc > 1)
    //    card = argv[1];
    //else
    card = "/dev/dri/card0";
    fprintf (stderr, "using card '%s'\n", card);

    wait = 0;
    if (argc > 1) {
        if ( !strncasecmp(argv[1], "-w",2) ||
             !strncasecmp(argv[1], "--wait", 6) ) {
            fprintf (stderr, "Wait until we are stopped via %s\n"
                        "echo QUIT > %s",
                        SPLASH_FIFO, SPLASH_FIFO);
            wait = 1;
        }
        else {
            fprintf (stderr, "%s [-w|--wait]\n", argv[0]);
            wait = 1;
        }
    }

    //set signal
    signal(SIGHUP, splash_exit);
    signal(SIGINT, splash_exit);
    signal(SIGQUIT, splash_exit);

    //open fifo for receiving command
    tmpdir = getenv("TMPDIR");
    if (!tmpdir)
        tmpdir = "/tmp";
    chdir(tmpdir);
    if (mkfifo(SPLASH_FIFO, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP)) {
        if (errno != EEXIST) {
            perror("mkfifo");
            exit(-1);
        }
    }
    pipe_fd = open (SPLASH_FIFO,O_RDONLY|O_NONBLOCK);
    if (-1 == pipe_fd) {
        perror("pipe open");
        exit(-2);
    }

    /* open the DRM device */
    ret = modeset_open (&drm_fd, card);
    if (ret)
        goto out_return;

    /* prepare all connectors and CRTCs */
    ret = modeset_prepare (drm_fd);
    if (ret)
        goto out_close;

    /* perform actual modesetting on each found connector+CRTC */
    for (iter = modeset_list; iter; iter = iter->next) {
        iter->saved_crtc = drmModeGetCrtc (drm_fd, iter->crtc);
        ret = drmModeSetCrtc (drm_fd, iter->crtc, iter->fb, 0, 0,
                &iter->conn, 1, &iter->mode);
        if (ret)
            fprintf (stderr, "cannot set CRTC for connector %u (%d): %m\n",
                    iter->conn, errno);
    }

    /* draw some colors for 5seconds */
    modeset_draw_bgcolor (0xFF, 0xFF, 0xFF);
    splash_draw_image_center ();

    splash_processing ();

    /* cleanup everything */
    modeset_cleanup (drm_fd);
    close(pipe_fd);
    ret = 0;

out_close:
    close (drm_fd);
    close(pipe_fd);
out_return:
    if (ret) {
        errno = -ret;
        fprintf (stderr, "modeset failed with error %d: %m\n", errno);
    }
    else {
        fprintf (stderr, "exiting\n");
    }
    close(pipe_fd);
    return ret;
}

