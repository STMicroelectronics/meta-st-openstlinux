/*
* basic_splash_drm.c - Basic splash screen on DRM
*
* Inspired by the code of modeset:
*   https://github.com/dvdhrm/docs/blob/master/drm-howto/modeset.c
*   Written 2012 by David Herrmann <dh.herrmann@googlemail.com>
* For PNG read, it's inspirated from example.c of libpng (git://git.code.sf.net/p/libpng/code)
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
#include <getopt.h>

#include <pixman.h>
#include <png.h>
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


// --------------------------------------------- //
//                 Modeset function
// --------------------------------------------- //
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

// --------------------------------------------- //
//              Draw function
// --------------------------------------------- //
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
splash_draw_image_for_modeset32 (struct modeset_dev *iter,
        int x,
        int y,
        int img_width,
        int img_height,
        uint32_t * rle_data)
{
    uint32_t *p = rle_data;
    int dx = 0, dy = 0, total_len, i;
    unsigned int off;

    total_len = img_width * img_height;

    for (i = 0; i < total_len; i++) {
        off = iter->stride * (y + dy) + (x + dx)*4;
        *(uint32_t *) & iter->map[off] = (*(p));
        if (++dx >= img_width) {
            dx = 0;
            dy++;
        }
        p += 1;
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

// --------------------------------------------- //
//              Exit function
// --------------------------------------------- //
void
splash_exit (int signum)
{
    modeset_cleanup (drm_fd);
    close(pipe_fd);
}
// --------------------------------------------- //
//              fifo processing message
// --------------------------------------------- //
static int
parse_command (char *string, int length)
{
    char *command;

    fprintf(stderr, "got cmd %s", string);
    if (strcmp(string,"QUIT") == 0)
        return 1;

    command = strtok(string," ");

    if (!strcmp(command,"QUIT")) {
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
int get_valid_dri_card() {
    int ind = 0;
    char buf_name[32];

    for (ind = 0; ind < 8; ind++) {
        snprintf(buf_name, 32, "/dev/dri/card%d", ind);
        if (access(buf_name, F_OK) == 0) {
            return ind;
        }
    }
    return -1;
}
// --------------------------------------------- //
//          Load png image
// --------------------------------------------- //
//-------------------------------
// load Image (png file)
static void
pixman_image_destroy_func(pixman_image_t *image, void *data) {
    free(data);
}
static void
read_user_callback(png_structp   png,
                 png_row_infop row_info,
                 png_bytep     data)
{
    unsigned int i;
    png_bytep p;
    int tmp;

    for (i = 0, p = data; i < row_info->rowbytes; i += 4, p += 4) {
        uint32_t alpha = p[3];
        uint32_t w;

        if (alpha == 0) {
            w = 0;
        } else {
            uint32_t red   = p[0];
            uint32_t green = p[1];
            uint32_t blue  = p[2];

            if (alpha != 0xff) {
                tmp = ((alpha * red) + 0x80);
                red   = ((tmp + (tmp >>8)) >> 8);
                tmp = ((alpha * green) + 0x80);
                green = ((tmp + (tmp >>8)) >> 8);
                tmp = ((alpha * blue) + 0x80);
                blue  = ((tmp + (tmp >>8)) >> 8);
        }
            w = (alpha << 24) | (red << 16) | (green << 8) | (blue << 0);
        }

        * (uint32_t *) p = w;
    }
}

static pixman_image_t *read_png_image(FILE *fp)
{
    png_struct *png;
    png_info *info;
    png_byte * data = NULL;
    //png_byte **volatile row_pointers = NULL;

    png_uint_32 width, height;
    int depth, color_type, interlace, stride;
    unsigned int i;
    pixman_image_t *pixman_image = NULL;

    png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    if (!png)
        return NULL;

    info = png_create_info_struct(png);
    if (info != NULL) {

        if (setjmp(png_jmpbuf(png)) == 0) {
            png_init_io(png, fp);

            png_read_info(png, info);

            png_get_IHDR(png, info,
                         &width, &height, &depth,
                         &color_type, &interlace, NULL, NULL);

            if (depth == 16)
                png_set_strip_16(png);
            if (depth < 8)
                png_set_packing(png);

            /* Expand paletted colors into true RGB triplets. */
            if (color_type == PNG_COLOR_TYPE_PALETTE)
                png_set_palette_to_rgb(png);
            /* Expand grayscale images to the full 8 bits from 1, 2 or 4 bits/pixel. */
            if (color_type == PNG_COLOR_TYPE_GRAY)
                png_set_expand_gray_1_2_4_to_8(png);

            if (png_get_valid(png, info, PNG_INFO_tRNS))
                png_set_tRNS_to_alpha(png);

            if (color_type == PNG_COLOR_TYPE_GRAY ||
                color_type == PNG_COLOR_TYPE_GRAY_ALPHA)
                    png_set_gray_to_rgb(png);

            if (interlace != PNG_INTERLACE_NONE)
                png_set_interlace_handling(png);

            /* Add filler (or alpha) byte (before/after each RGB triplet). */
            png_set_filler(png, 0xffff, PNG_FILLER_AFTER);
            png_set_read_user_transform_fn(png, read_user_callback);
            png_read_update_info(png, info);
            png_get_IHDR(png, info, &width, &height, &depth, &color_type, &interlace, NULL, NULL);

            stride = width * 4;
            data = malloc(stride * height);
            if (!data) {
                png_destroy_read_struct(&png, &info, NULL);
                return NULL;
            }
            png_bytep row_pointers[height];
            for (i = 0; i < height; i++)
                row_pointers[i] = NULL; /* Clear the pointer array */
            for (i = 0; i < height; i++)
                row_pointers[i] = &data[i * stride];

            png_read_image(png, row_pointers);
            png_read_end(png, info);

            png_destroy_read_struct(&png, &info, NULL);

            pixman_image = pixman_image_create_bits(PIXMAN_a8r8g8b8,
                width, height, (uint32_t *) data, stride);

            pixman_image_set_destroy_function(pixman_image,
                    pixman_image_destroy_func, data);
            return pixman_image;

        } else { // setjmp
            png_destroy_read_struct(&png, &info, NULL);
            return NULL;
        }
    } else { // info
        png_destroy_read_struct(&png, NULL, NULL);
        return NULL;
    }
    return pixman_image;
}

static pixman_image_t *
load_image(char *filename) {
    FILE *fp = NULL;
    unsigned char header[4];
    pixman_image_t *ppixman_image = NULL;

    // open file
    if (filename == NULL){
        printf("[ERROR] load_image: parameter empty\n");
        goto end;
    }

    fp = fopen(filename, "rb");
    if (!fp) {
        printf("[ERROR] load_image: %s: %s\n", filename, strerror(errno));
        goto end;
    }
    // verify if it's a png file
    if (fread(header, sizeof header, 1, fp) != 1) {
        fclose(fp);
        printf("[ERROR] load_image: %s: unable to read file header\n", filename);
        goto end;
    }
    if ( (header[0] == 0x89) &&
         (header[1] == 'P') &&
         (header[2] == 'N') &&
         (header[3] == 'G') ) {
            printf("load_image: %s is a png\n", filename);
    } else {
        printf("[ERROR] load_image: %s: is not a PNG image\n", filename);
        return NULL;
    }
    rewind(fp);

    ppixman_image = read_png_image(fp);

end:
    fclose(fp);
    return ppixman_image;
}

// --------------------------------------------- //
//           Main
// --------------------------------------------- //
static const char *shortopts = "wb:f:h";

static const struct option longopts[] = {
    {"wait",    no_argument,       0, 'w'},
    {"background",        required_argument, 0, 'b'},
    {"filename",  required_argument, 0, 'f'},
    {"help",          no_argument,       0, 'h'},
    {0, 0, 0, 0}
};
static void
usage(int error_code)
{
    fprintf(stderr, "Usage: psplash-drm [-w][-h][-f <image name>][-b RRGGBB]\n"
        "\n"
        "options:\n"
            "  -w, --wait         Display image and wait\n"
            "  -b, --background=RRGGBB       Set the background color\n"
            "  -f, --filename=image name     Image to display\n"
            "  -h, --help                This help text\n\n");
    exit(error_code);
}

int
main (int argc, char **argv)
{
    int ret;
    char card[32];
    struct modeset_dev *iter;
    mode_t oldMask;
    char *tmpdir;
    char background_red = 0x03;
    char background_green = 0x23;
    char background_blue = 0x4b;
    int opt;
    char *filename = "";
    pixman_image_t *pixman_image = NULL;

    /* check which DRM device to open */
    ret = get_valid_dri_card();
    if (ret < 0) {
        perror("There is no dri card arvaible (/dev/dri/cardX)");
        exit(-1);
    }
    sprintf(card, "/dev/dri/card%d", ret);
    fprintf (stderr, "using card '%s'\n", card);

    wait = 0;

    while ((opt = getopt_long_only(argc, argv, shortopts, longopts, NULL)) != -1) {
        switch (opt) {
        case 'w':
            wait = 1;
            fprintf (stderr, "    Wait until we are stopped via %s\n"
                        "        echo QUIT > %s\n",
                        SPLASH_FIFO, SPLASH_FIFO);
            break;
        case 'h':
            usage(EXIT_SUCCESS);
            break;
        case 'b':
            char *color = strdup(optarg);
            unsigned int bg_color;
            if (sscanf(color, "%x", &bg_color) > 0) {
                background_red = (bg_color & 0xff0000) >> 16;
                background_green = (bg_color & 0x00ff00) >> 8;
                background_blue = bg_color & 0x0000ff;
                printf("Background color  RR=%02x GG=%02x BB=%02x\n",
                       background_red, background_green, background_blue);
            }
            free(color);
            break;
        case 'f':
            filename = strdup(optarg);
            printf("Filename of image: %s\n", filename);
            break;
        default:
            usage(EXIT_FAILURE);
            break;
        }
    }

    //set signal
    signal(SIGHUP, splash_exit);
    signal(SIGINT, splash_exit);
    signal(SIGQUIT, splash_exit);

    remove(SPLASH_FIFO);
    oldMask = umask(0);
    if (mkfifo(SPLASH_FIFO, 0777)) {
        if (errno != EEXIST) {
            perror("mkfifo");
            exit(-1);
        }
    }
    /* restore old umask */
    umask(oldMask);


    //open fifo for receiving command
    tmpdir = getenv("TMPDIR");
    if (!tmpdir)
        tmpdir = "/tmp";
    chdir(tmpdir);
    pipe_fd = open (SPLASH_FIFO,O_RDONLY|O_NONBLOCK);
    if (-1 == pipe_fd) {
        perror("pipe open");
        exit(-2);
    }

    /* if there is a specified filename, open it */
    if (strlen(filename) > 0) {
        printf("try filename -> %s\n", filename);

        pixman_image  = load_image(filename);

        if (pixman_image_get_width(pixman_image) <= 0)
            exit(-3);
    }

    /* open the DRM device */
    ret = modeset_open (&drm_fd, (const char*)card);
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

    /* set background color and display picture */
    //modeset_draw_bgcolor (0xFF, 0xFF, 0xFF);
    modeset_draw_bgcolor (background_red, background_green, background_blue);
    if (pixman_image != NULL) {
        struct modeset_dev *iter;
        int img_width, img_height;
        int x, y;
        int bad_size = 0;

        for (iter = modeset_list; iter; iter = iter->next) {
            img_width = pixman_image_get_width(pixman_image);
            img_height = pixman_image_get_height(pixman_image);

            x = (iter->width - img_width) / 2;
            y = (iter->height - img_height) / 2;
            if ((img_width < iter->width) && (img_height < iter->height) )
                splash_draw_image_for_modeset32 (iter, x, y, img_width, img_height,
                    (uint32_t *)pixman_image_get_data(pixman_image));
            else {
                fprintf(stderr, "[ISSUE] Image %s is greater than screen (Image: %dx%d, screen: %dx%d)\n",
                        filename, img_width, img_height, iter->width, iter->height);
                fprintf(stderr, "       use fallback picture\n");
                bad_size = 1;
            }
        }
        if (bad_size)
            splash_draw_image_center ();
    } else
        splash_draw_image_center ();

    splash_processing ();

    /* cleanup everything */
    modeset_cleanup (drm_fd);
    close(pipe_fd);
    if (strlen(filename) > 0) {
        free(filename);
    }
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
    remove(SPLASH_FIFO);
    return ret;
}

