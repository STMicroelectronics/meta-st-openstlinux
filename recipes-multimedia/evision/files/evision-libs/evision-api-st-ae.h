/**
 ******************************************************************************
 * @file    evision-api-st-ae.h
 * @author  STMicroelectronics / LACROIX - Impulse
 * @brief   ST eVision Auto Exposure algorithm public header.
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2025 STMicroelectronics.
 * Copyright (c) 2023 LACROIX - Impulse.
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 *
 ******************************************************************************
 */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef EVISION_API_ST_AE_H_
#define EVISION_API_ST_AE_H_

/* Includes ------------------------------------------------------------------*/
#include <stdint.h>
#include <stdlib.h>
#include "evision-api-utils.h"

/* Exported types ------------------------------------------------------------*/
typedef struct evision_st_ae_hyper_param {
  /*! @brief
   * Target exposure to reach. <br/>
   * <b>Restrictions:</b> >= 0 AND < 256. <br/>
   * <b>Default value:</b> 56 */
  uint32_t target;
  /*! @brief
   * Max delta between lum stat and target in convergence region <br/>
   * <b>Restrictions:</b> >= 0 AND < 256. <br/>
   * <b>Default value:</b> 10 */
  uint32_t tolerance;
  /*! @brief
   * Factor applied to increment gain update <br/>
   * <b>Restrictions:</b> >= 0 AND < 1000. <br/>
   * <b>Default value:</b> 100 */
  uint32_t gain_increment_coeff;
  /*! @brief
   * Max delta value between lum stat and target in low delta region <br/>
   * <b>Restrictions:</b> >= 0 AND < 256. <br/>
   * <b>Default value:</b> 45 */
  uint32_t gain_low_delta;
  /*! @brief
   * Min delta value between lum stat and target in high delta region <br/>
   * <b>Restrictions:</b> >= 0 AND < 256. <br/>
   * <b>Default value:</b> 120 */
  uint32_t gain_high_delta;
  /*! @brief
   * Maximum gain update value in luminance low delta region <br/>
   * <b>Restrictions:</b> >= #gain_min AND < #gain_max. <br/>
   * <b>Default value:</b> 1500 */
  uint32_t gain_low_increment_max;
  /*! @brief
   * Maximum gain update value in luminance medium delta region <br/>
   * <b>Restrictions:</b> >= #gain_min AND < #gain_max. <br/>
   * <b>Default value:</b> 6000 */
  uint32_t gain_medium_increment_max;
  /*! @brief
   * Maximum gain update value in luminance high delta region <br/>
   * <b>Restrictions:</b> >= #gain_min AND < #gain_max. <br/>
   * <b>Default value:</b> 12000 */
  uint32_t gain_high_increment_max;
  /*! @brief
   * Factor applied to increment exposure <br/>
   * <b>Restrictions:</b> >= 0.0 AND < 1. <br/>
   * <b>Default value:</b> 0.020*/
  double exposure_up_ratio;
  /*! @brief
   * Minimum value accepted for exposure time. <br/>
   * <b>Restrictions:</b> >= 0.0 AND < 1. <br/>
   * <b>Default value:</b> 0.004*/
  double exposure_down_ratio;
  /*! @brief
   * Minimum value accepted for exposure time. <br/>
   * <b>Restrictions:</b> >= 0.0 AND < #exposure_max. <br/>
   * <b>Default value:</b> 0.0*/
  uint32_t exposure_min;
  /*! @brief
   * Maximum value accepted for exposure time. <br/>
   * <b>Restrictions:</b> > 0.0 AND >= #exposure_min. <br/>
   * <b>Default value:</b> 1.0 */
  uint32_t exposure_max;
  /*! @brief
   * Minimum possible gain value. <br/>
   * <b>Restrictions:</b> > 1 AND < #gain_max. <br/>
   * <b>Default value:</b> 1 */
  uint32_t gain_min;
  /*! @brief
   * Maximum possible gain value. <br/>
   * <b>Restrictions:</b> >= 1 AND > #gain_min. <br/>
   * <b>Default value:</b> 1 */
  uint32_t gain_max;
  /*! @brief
   *  Luminance limit where we consider the frame as dark. <br/>
   * <b>Restrictions:</b> >= 0 AND < 256. <br/>
   * <b>Default value:</b> 5 */
  uint32_t dark_zone_lum_limit;
  /*! @brief
   *  Compatible light frequency in Hz to avoid flickering effect. <br/>
   * <b>Restrictions:</b> >= 0 (None) AND < 256. <br/>
   * <b>Default value:</b> 0 (None) */
  uint32_t compat_freq;

} evision_st_ae_hyper_param_t;

/**
 * @typedef evision_ae_estimator_t
 * @brief AE estimator structure.
 *
 * @struct evision_ae_estimator
 * @brief AE estimator structure.
 *
 * Set of all data structures required for the functioning of the AE algorithm.
 */
typedef struct evision_st_ae_process_t {
  /*! @brief
   * Indicates the state of the AE algorithm. <br/>
   * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
   * Possible values: see #evision_state_t */
  evision_state_t state;
  /*! @brief
   * Computed exposure time to apply to sensor. <br/>
   * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! */
  uint32_t new_exposure;

  /*! @brief
   * Computed gain value to apply to sensor. <br/>
   * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! */
  uint32_t new_gain;

  /*! @brief
   * The set of AE algorithm hyper-parameters. Set to default values at creation! <br/>
   * #evision_ae_hyper_param_t.exposure_min, #evision_ae_hyper_param_t.exposure_max,
   * #evision_ae_hyper_param_t.gain_min and #evision_ae_hyper_param_t.gain_max hyper-parameters
   * <b> must be updated </b> before running the ae process with respect to the sensor in use. <br/>
   * As a general note, the hyper-parameters can be updated from their default values.
   * Care must be taken as in such a case there is no guarantee of proper functioning of the process! <br/>
   * <b>Restrictions:</b> Must not be updated during runtime!
   */
  evision_st_ae_hyper_param_t hyper_params;

  /*! @brief
   * Handler to output logs. <br/> */
  evision_api_log_callback log_cb;

} evision_st_ae_process_t;

/* Exported constants --------------------------------------------------------*/
#define EVISION_ST_AEC_LUM_TARGET               56      /* Default luminance value targeted by the AE algorithm */
#define EVISION_ST_AEC_TOLERANCE                10      /* Max delta between lum stat and target in convergence region */
#define EVISION_ST_AEC_GAIN_INCREMENT_COEFF     100     /* Factor applied to increment gain update */
#define EVISION_ST_AEC_GAIN_LOW_DELTA           45      /* Max delta value between lum stat and target in low delta region */
#define EVISION_ST_AEC_GAIN_HIGH_DELTA          120     /* Min delta value between lum stat and target in high delta region */
#define EVISION_ST_AEC_GAIN_LOW_INC_MAX         1500    /* Maximum gain update value in luminance low delta region */
#define EVISION_ST_AEC_GAIN_MEDIUM_INC_MAX      6000    /* Maximum gain update value in luminance medium delta region */
#define EVISION_ST_AEC_GAIN_HIGH_INC_MAX        12000   /* Maximum gain update value in luminance high delta region */
#define EVISION_ST_AEC_EXPOSURE_UP_RATIO        0.020F  /* Factor applied to increment exposure */
#define EVISION_ST_AEC_EXPOSURE_DOWN_RATIO      0.004F  /* Factor applied to decrement exposure */
#define EVISION_ST_AEC_DARKZONE_LUM_LIMIT       5       /* Default value for dark zone luminance limit */
#define EVISION_ST_DEFAULT_EXPOSURE_MIN         0       /* Default value for exposure min */
#define EVISION_ST_DEFAULT_EXPOSURE_MAX         33000   /* Default value for expsoure max */
#define EVISION_ST_DEFAULT_GAIN_MIN             1       /* Default value for gain min */
#define EVISION_ST_DEFAULT_GAIN_MAX             100     /* Default value for gain max */
#define EVISION_ST_DEFAULT_COMPAT_FREQ          0       /* Default value for compatible frequency */


/* Exported macro ------------------------------------------------------------*/
/* Exported functions ------------------------------------------------------- */
/**
 * @fn evision_st_ae_process_t* evision_api_st_ae_new(void);
 * @brief Create a new #evision_st_ae_process_t instance.
 *
 * @param[in] log_cb Callback to output logs.
 * @return The address of the created instance. NULL if it failed.
 */
evision_st_ae_process_t* evision_api_st_ae_new(evision_api_log_callback log_cb);

/**
 * @fn evision_return_t evision_api_st_ae_delete(evision_st_ae_process_t* self);
 * @brief Releases the memory allocated for the #evision_st_ae_process_t ae process instance.
 *
 * @param[in, out] ae process instance address.
 * @return
 * - EVISION_RET_SUCCESS
 * - EVISION_RET_PARAM_ERR

 */
evision_return_t evision_api_st_ae_delete(evision_st_ae_process_t* self);

/**
 * @fn evision_return_t evision_api_st_ae_init(evision_st_ae_process_t* const self)
 * @brief Initialize the AE process structure.
 *
 * @param[in, out] self AE process to be initialized.
 * @return
 * - EVISION_RET_SUCCESS
 * - EVISION_RET_PARAM_ERROR
 *
 * Initializes the AE process structure. Hyper params can later be modified.
 */
evision_return_t evision_api_st_ae_init(evision_st_ae_process_t* const self);

/**
 * @fn evision_return_t evision_api_st_ae_process(evision_st_ae_process_t* const self, uint32t_t current_gain, uint32_t current_exposure, uint8_t average_lum)
 * @brief Run the ae process to calculate new gain and expsoure
 *
 * @param[in, out] self Concerned process instance address.
 * @param[in] current_gain Current sensor gain in mdB.
 * @param[in] current_exposure Current sensor exposure microsecond.
 * @param[in] average_lum Average luminance measurement value. Range should normally be between 0 (completely dark image) and 255 (completely white image).
 *
 * @return
 * - EVISION_RET_SUCCESS
 * - EVISION_RET_FAILURE
 */
evision_return_t evision_api_st_ae_process(evision_st_ae_process_t* const self, uint32_t current_gain, uint32_t current_exposure, uint8_t average_lum);

/* Exported variables --------------------------------------------------------*/

#endif /* EVISION_API_ST_AE_H_ */
