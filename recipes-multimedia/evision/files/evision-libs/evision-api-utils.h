/**
 ******************************************************************************
 * @file    evision-api-utils.h
 * @author  LACROIX - Impulse
 * @brief   eVision utilitary public header.
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2023 LACROIX - Impulse.
 * Copyright (c) 2025 STMicroelectronics.
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 *
 ******************************************************************************
 */

#ifndef EVISION_API_UTILS_H_
#define EVISION_API_UTILS_H_

#ifdef __cplusplus
extern "C" {
#endif

/************************************************************************
 * Includes
 ************************************************************************/

#include <stdint.h>

/************************************************************************
 * Public Defines
 ************************************************************************/

/**
 * @def EVISION_MIN
 * @brief Determine the lowest value between a and b
 */
#define EVISION_MIN(a, b) ((a) < (b) ? (a) : (b))

/**
 * @def EVISION_MAX
 * @brief Determine the greatest value between a and b
 */
#define EVISION_MAX(a, b) ((a) > (b) ? (a) : (b))

/**
 * @def EVISION_SIGN
 * @brief Determine the sign of a number.
 */
#define EVISION_SIGN(x) ((x) > 0.0f ? 1.0f : -1.0f)

#ifdef ALGO_SW_STATISTICS
/* YUV parameters */
/*! @brief Minimum of Y value due to ISP RGB 2 YUV conversion formula */
#define EVISION_YUV_MIN_Y_VAL (16.0)
/*! @brief Maximum of Y value due to ISP RGB 2 YUV conversion formula */
#define EVISION_YUV_MAX_Y_VAL (235.140625)
/*! @brief YUV factor value due to ISP RGB 2 YUV conversion formula */
#define EVISION_YUV_FACTOR (256)
/*! @brief YUV maximum value due to ISP RGB 2 YUV conversion formula */
#define EVISION_YUV_MAX_VAL (255)
/*! @brief range of Y value due to ISP RGB 2 YUV conversion formula */
#define EVISION_YUV_RANGE_Y_VAL (EVISION_YUV_MAX_Y_VAL - EVISION_YUV_MIN_Y_VAL)
#endif

/**
 * @typedef evision_return_t
 * @brief Return type for functions.
 *
 * @enum evision_return
 * @brief Return type for functions.
 *
 * Return code that must be checked to be sure the output of the function is valid.
 */
typedef enum evision_return {
    EVISION_RET_INVALID_VALUE = 2,  /*!< The process succeeded but the output value is invalid and should not be used.*/
    EVISION_RET_SUCCESS = 1,        /*!< the process succeeded. */
    EVISION_RET_FAILURE = 0,        /*!< Error: There was a failure. */
    EVISION_RET_PARAM_ERR = -1,     /*!< Error: A parameter is invalid. */
    EVISION_RET_DIMENSION_ERR = -2, /*!< Error: A dimension is incompatible with the process. */
    EVISION_RET_MEMORY_ERR = -3,    /*!< Error: Could not allocate memory. */
    EVISION_RET_FILE_ERR = -4,      /*!< Error: A file could not be opened */
    EVISION_RET_FORMAT_ERR = -5,    /*!< Error: the specified format is invalid. */
} evision_return_t;

/**
 * @typedef evision_state_t
 * @brief Describes the state of the estimator.
 *
 * @enum evision_state
 * @brief Describes the state of the estimator.
 */
typedef enum evision_state {
    /*! @brief
     * The estimator exists.
     */
    EVISION_STATE_NONE = 0u,
    /*! @brief
     * The estimator was initialized and is ready to run.
     */
    EVISION_STATE_INIT = 1u,
    /*! @brief
     * The estimator is running.
     */
    EVISION_STATE_RUN = 2u,
} evision_state_t;

/**
 * @typedef evision_image_format_t
 * @brief Specify the format under which the image is stored.
 *
 * @enum evision_image_format
 * @brief Specify the format under which the image is stored.
 *
 * Those formats are as the ones defined by V4L2.
 */
typedef enum evision_image_format {
    /*! @brief
     * 8 bit gray-level.
     */
    EVISION_IMAGE_FORMAT_GRAY8 = 0u,
    /*! @brief
     * 8 bit gray-level.
     */
    EVISION_IMAGE_FORMAT_GREY8 = 1u,
    /*! @brief
     * RGB interleaved, 8 bit per channel, 24 bit per pixel..
     */
    EVISION_IMAGE_FORMAT_RGB8 = 2u,
    /*! @brief
     * BGR interleaved, 8 bit per channel, 24 bit per pixel..
     */
    EVISION_IMAGE_FORMAT_BGR8 = 3u,
    /*! @brief
     * 8 bit YUV 422 SP format.
     */
    EVISION_IMAGE_FORMAT_YUV422SP = 4u,
    /*! @brief
     * RGGB Bayer format, 8 bit per channel, Red compound first.
     */
    EVISION_IMAGE_FORMAT_RGGB8 = 5u,
    /*! @brief
     * BGGR Bayer format, 8 bit per channel, Blue compound first.
     */
    EVISION_IMAGE_FORMAT_BGGR8 = 6u,
    /*! @brief
     * GRBG Bayer format, 16 bit per channel, each coded on 16 bits inverted (0xFF, 0x0F).
     */
    EVISION_IMAGE_FORMAT_GRBG12 = 7u,
    /*! @brief
     * RGGB Bayer format, 16 bit per channel, each coded on 16 bits inverted (0xFF, 0x0F).
     */
    EVISION_IMAGE_FORMAT_RGGB12 = 8u
} evision_image_format_t;

/************************************************************************
 * Public Functions Signatures
 ************************************************************************/

/**
 * @brief Callback function to output logs.
 *
 * @param[in] msg Received message.
 *
 * If the user wants to handle the log and messages yielded by the estimator,
 * a function with this signature must be specified.
 *
 */
typedef void (*evision_api_log_callback)(const char* const msg);

/************************************************************************
 * Public Structures
 ************************************************************************/

/**
 * @typedef evision_image_t
 * @brief Structure to hold frame data and metadata for eVision AE and AWB algorithms.
 *
 * @struct evision_image
 * @brief Structure to hold frame data and metadata for eVision AE and AWB algorithms.
 *
 */
typedef struct evision_image {
    /*! @brief
     * Frame data.
     */
    uint8_t* pdata;
    /*! @brief
     * Number of pixels columns in the image.
     */
    uint16_t width;
    /*! @brief
     * Number of pixels rows in the image.
     */
    uint16_t height;
    /*! @brief
     * The format of the image.
     */
    evision_image_format_t format;
} evision_image_t;

#ifdef ALGO_SW_STATISTICS
/**
 * @typedef evision_roi_t
 * @brief Represents a Region Of Interest (aka a rectangle of pixels in an image).
 *
 * @struct evision_roi
 * @brief Represents a Region Of Interest (aka a rectangle of pixels in an image).
 *
 * A ROI serves to limit the statistics extraction to a specific zone inside the frame.
 * Several ROIs can be defined and for each ROI a weight must be defined.
 * The aggregated statistic is the weighted average of individual ROI statistics.
 * Setting all weights equal results in the aggregated statistic to be the arithmetic average of the individual statistics.
 *
 */
typedef struct evision_roi {
    /*! @brief
     * Horizontal pixel coordinate of the Top-Left corner of the ROI.
     */
    uint16_t x0;
    /*! @brief
     * Vertical pixel coordinate of the Top-Left corner of the ROI.
     */
    uint16_t y0;
    /*! @brief
     * Horizontal pixel coordinate of the Bottom-Right corner of the ROI.
     */
    uint16_t x1;
    /*! @brief
     * Vertical pixel coordinate of the Bottom-Right corner of the ROI.
     */
    uint16_t y1;
    /*! @brief
     * Weight associated to the ROI.
     */
    double weight;
} evision_roi_t;

/**
 * @typedef evision_roi_array_t
 * @brief Represents an array of evision_roi.
 *
 * @struct evision_roi_array
 * @brief Represents an array of evision_roi.
 *
 * Represents the collection of all the defined ROIs for the estimator. Must contain at least one ROI.
 *
 */
typedef struct evision_roi_array {
    /*! @brief
     * Pointer to the beginning of the array.
     */
    evision_roi_t* parray;
    /*! @brief
     * Number of elements in the array.
     */
    uint16_t len;
} evision_roi_array_t;
#endif


/************************************************************************
 * Private Structure Declaration
 ************************************************************************/

/************************************************************************
 * Public Variables
 ************************************************************************/

/************************************************************************
 * Public Function Prototypes
 ************************************************************************/

/* Library management functions */
#ifdef ALGO_SW_STATISTICS
/* ROI array management */

/**
 * @fn evision_roi_array_t* evision_api_roi_array_new(const uint16_t length)
 * @brief Create and allocate the memory for a new array of #evision_roi_array_t elements.
 *
 * @param[in] length Size of the array to create
 * @return Address of the created #evision_roi_array_t. NULL if something went wrong.
 */
evision_roi_array_t* evision_api_roi_array_new(const uint16_t length);

/**
 * @fn evision_roi_array_t* evision_api_roi_array_new_grid(const uint16_t frame_width, const uint16_t frame_height, const uint16_t roi_width, const uint16_t roi_height, const uint16_t nb_roi_col, const uint16_t nb_roi_row)
 * @brief Create and allocate the memory for a new array of #evision_roi_array_t with pre filled ROIs positioned as a grid.
 *
 * In the end, the number of ROIs will be nb_roi_col * nb_roi_row
 *
 * @param[in] frame_width Number of pixels column in the frame where the ROIs will be placed.
 * @param[in] frame_height Number of pixels rows in the frame where the ROIs will be placed.
 * @param[in] roi_width Size (columns) of each ROI.
 * @param[in] roi_height Size (rows) of each ROI.
 * @param[in] nb_roi_col Number of ROIs to be placed in the horizontal dimension.
 * @param[in] nb_roi_row Number of ROIs to be placed in the vertical dimension.
 * @return Address of the created #evision_roi_array_t. NULL if something went wrong.
 */
evision_roi_array_t* evision_api_roi_array_new_grid(const uint16_t frame_width, const uint16_t frame_height, const uint16_t roi_width, const uint16_t roi_height, const uint16_t nb_roi_col, const uint16_t nb_roi_row);

/**
 * @fn evision_return_t evision_api_roi_array_delete(evision_roi_array_t* self)
 * @brief Free the memory allocated to an #evision_roi_array_t.
 *
 * @param[in, out] self Address of the concerned ROI array instance to be deleted, cannot be used after.
 * @return
 * - EVISION_RET_SUCCESS
 * - EVISION_RET_PARAM_ERR
 */
evision_return_t evision_api_roi_array_delete(evision_roi_array_t* self);
#endif

/************************************************************************
 * Public Function Definitions
 ************************************************************************/

#ifdef __cplusplus
}
#endif

#endif /* EVISION_API_UTILS_H_ */
