/**
 ******************************************************************************
 * @file    evision-api-awb.h
 * @author  LACROIX - Impulse
 * @brief   eVision Auto White Balance algorithm public header.
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

#ifndef EVISION_API_AWB_H_
#define EVISION_API_AWB_H_

/************************************************************************
 * Includes
 ************************************************************************/

#include <stdint.h>
#include <stdlib.h>

#include "evision-api-utils.h"

/************************************************************************
 * Public Defines
 ************************************************************************/

/*! @brief Maximum number of supported sensor configurations. */
#define EVISION_AWB_MAX_SENSOR_CONFIGS (2u)
/*! @brief Default sensor configuration index. */
#define EVISION_AWB_DEFAULT_SENSOR_CONFIG_INDEX (0u)
/*! @brief Default number of ROIs for AWB. */
#define EVISION_AWB_DEFAULT_NB_ROI (1u)
/*! @brief Maximum  number of AWB profiles. */
#define EVISION_AWB_MAX_PROFILE_COUNT (5u)

/*! @brief Number of CFA digital gains for AWB */
#define EVISION_AWB_NB_DG_CFA_GAINS (4u)
/*! @brief Number of rows / columns of CCM for AWB */
#define EVISION_AWB_CCM_SIZE (3u)
/*! @brief Size of estimated color temperatures history. Restrictions: >= 3. */
#define EVISION_AWB_HIST_SIZE (3u)
/*! @brief Number of components for external measurements */
#define EVISION_AWB_EXT_MEAS_SIZE (3u)

/*! @brief Flag value to indicate the use of profile selection based AWB operation mode. */
#define EVISION_AWB_USE_PROFILE_SELECTION_AWB (1u)

/************************************************************************
 * Public Structures
 ************************************************************************/

/**
 * @typedef evision_awb_priv_param_runtime_t
 * @brief AWB algorithm private run-time parameters, member of #evision_awb_estimator_t.
 *
 * @struct evision_awb_priv_param_runtime
 * @brief AWB algorithm private run-time parameters, member of #evision_awb_estimator_t.
 */
typedef struct evision_awb_priv_param_runtime {
    /*! @brief
     * Current convergence speed. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * <b>Default value:</b> 1.0
     */
    double speed_p_value;
    /*! @brief
     * Flag to indicate change in estimated AWB color temperature. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * <b>Default value:</b> 0
     */
    uint8_t temp_changed;
    /*! @brief
     * AWB internal color temperature. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * <b>Default value:</b> -1.0
     */
    double int_temp;
    /*! @brief
     * T value parameter. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * <b>Default value:</b> 0.1 */
    double t_value;

    /*! @brief
     * Flag to indicate the estimator has entered an oscillatory state. <br/>
     * <b>Restrictions:</b> >=0 AND < #EVISION_AWB_HIST_SIZE
     */
    uint8_t oscillation;
    /*! @brief
     * History of selected profile color temperatures. <br/>
     */
    double hist_temp_current[EVISION_AWB_HIST_SIZE];
    /*! @brief
     * History of computed color temperatures. <br/>
     */
    double hist_temp_estim[EVISION_AWB_HIST_SIZE];
    /*! @brief
     * History of computed chromaticity stats. <br/>
     */
    double hist_stats[EVISION_AWB_HIST_SIZE][2u];
    /*! @brief
     * Counter for the current number of items in history. <br/>
     * <b>Restrictions:</b> >=0 AND < #EVISION_AWB_HIST_SIZE
     */
    uint16_t cnt_hist;

} evision_awb_priv_param_runtime_t;

/**
 * @typedef evision_awb_profile_t
 * @brief AWB algorithm profile definition.
 *
 * @struct evision_awb_profile
 * @brief AWB algorithm profile definition.
 */
typedef struct evision_awb_profile {
    /*! @brief
     * The color temperature of the illumination for which the profile is defined.
     * Positive value, typical range of values is between 2000 and 10000 °Kelvin. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter set during initialization, must not be changed during run-time. <br/>
     */
    float color_temperature;
    /*! @brief
     * The sensor/ISP channel gains. <br/>
     * <b>Note:</b> The individual gain values are stored using the float type.
     * The gains can be stored as ratios or as floating point representations of integer values.
     * It is up to the user to convert the values to the format expected by the sensor/ISP.
     */
    float gain_values[EVISION_AWB_NB_DG_CFA_GAINS];
    /*! @brief
     * The ISP color correction matrix coefficients. <br/>
     * <b>Note:</b> The individual color correction matrix coefficients are stored using the float type.
     * The coefficients can be stored as ratios or as a floating point representation of integer values.
     * It is up to the user to convert the values to the format expected by the sensor/ISP.
     */
    float ccm_coefficients[EVISION_AWB_CCM_SIZE][EVISION_AWB_CCM_SIZE];
    /*! @brief
     * The ISP color correction matrix offset coefficients. <br/>
     * <b>Note:</b> The individual color correction matrix offset coefficients are stored using the float type.
     * The coefficients can be stored as ratios or as a floating point representation of integer values.
     * It is up to the user to convert the values to the format expected by the sensor/ISP.
     */
    float ccm_offsets[EVISION_AWB_CCM_SIZE];
} evision_awb_profile_t;

/**
 * @typedef evision_awb_calib_data_t
 * @brief Sensor specific AWB calibration data, member of #evision_awb_estimator_t.
 *
 * @struct evision_awb_calib_data
 * @brief Sensor specific AWB calibration data, member of #evision_awb_estimator_t.
 *
 * Contains sensor specific AWB calibration data for accurate color rendering.
 * Support for both continious AWB and profile selection based AWB.
 *
 */
typedef struct evision_awb_calib_data {
    /*! @brief
     * Minimum supported color temperature. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter, positive valued. Set during estimator initialization.
     */
    double min_temp;
    /*! @brief
     * Maximum supported color temperature. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter, positive valued and > #min_temp. Set during estimator initialization.
     */
    double max_temp;

    /* ##############################
        Parameters for continuous AWB
    */

    /* #################################
        Parameters for profile based AWB
    */

    /*! @brief
     * Counter for the actual number of specified profiles. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter set during initialization. Must not be changed during runtime.
     * Range of possible values: > 0 and < #EVISION_AWB_MAX_PROFILE_COUNT
     */
    uint16_t profiles_count;

    /*! @brief
     * Array containing the color temperatures of the defined profiles. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter set during initialization. Must not be changed during runtime.
     */
    float temperatures[EVISION_AWB_MAX_PROFILE_COUNT];

    /*! @brief
     * Array containing the decision thresholds between the different profiles for profile selection. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter set during initialization. Must not be changed during runtime.
     */
    float decision_thresholds[EVISION_AWB_MAX_PROFILE_COUNT - 1];

    /*! @brief
     * Array containing the different AWB profiles. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter set during initialization. Must not be changed during runtime.
     */
    evision_awb_profile_t profiles[EVISION_AWB_MAX_PROFILE_COUNT];

    /*! @brief
     * Pointer to the active profile. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter updated during runtime. Code outside of the library must not alter its value.
     */
    evision_awb_profile_t* active_profile;

} evision_awb_calib_data_t;

/**
 * @typedef evision_awb_hyper_param_t
 * @brief AWB algorithm hyper-parameters, member of #evision_awb_estimator_t.
 *
 * @struct evision_awb_hyper_param
 * @brief AWB algorithm hyper-parameters, member of #evision_awb_estimator_t.
 *
 */
typedef struct evision_awb_hyper_param {
    /*! @brief
     * Ratio of pixels to be processed for AWB when using the SW statistics extraction block, direct impact on processing time.
     * (Ex. A value of 2 will process 1 pixel every 2*2 pixel block in the entire ROI). <br/>
     * <b>Restrictions:</b> >= 1 AND < image_size. <br/>
     * <b>Default value:</b> 1 */
    uint16_t awb_process_ratio;

    /*! @brief
     * AWB low luminance threshold value when using the SW statistics extraction block.
     * Skip pixel from AWB stats if luminance value below the threshold. <br/>
     * <b>Restrictions:</b> >= 0 AND < #y_thresh_high. <br/>
     * <b>Default value:</b> 0 */
    double y_thresh_low;
    /*! @brief
     * AWB high luminance threshold value when using the SW statistics extraction block.
     * Skip pixel from AWB stats if luminance value above the threshold. <br/>
     * <b>Restrictions:</b> > #y_thresh_low AND <= 255. <br/>
     * <b>Default value:</b> 0 */
    double y_thresh_high;

    /*! @brief
     * Convergence speed increment. <br/>
     * <b>Restrictions:</b> > 0 AND < #speed_p_max. <br/>
     * <b>Default value:</b> 0.1 */
    double speed_p_increment;
    /*! @brief
     * Minimum convergence speed. <br/>
     * <b>Restrictions:</b> > 0 AND < #speed_p_max. <br/>
     * <b>Default value:</b> 1.0 */
    double speed_p_min;
    /*! @brief
     * Maximum convergence speed. <br/>
     * <b>Restrictions:</b> > #speed_p_min. <br/>
     * <b>Default value:</b> 3.0 */
    double speed_p_max;

    /*! @brief
     * AWB color temperature estimation precision. <br/>
     * <b>Default value:</b> 1 °K */
    double precision_temp;

    /*! @brief
     * Offset around the decision threshold for hysteresis based decision for profile selection. <br/>
     * <b>Default value:</b> 50 °K */
    float hysteresis_offset;

    /*! @brief
     * Threshold of acceptable chromatic deviation around neutrality for convergence. <br/>
     * <b>Restrictions:</b> > 0. <br/>
     * <b>Default value:</b> 1.0. */
    float conv_criterion;

    /*! @brief
     * Threshold of acceptable chromatic deviation along the green-magenta axis.
     * Inhibit profile switch if the green or magenta component is higher than this threshold.<br/>
     * <b>Restrictions:</b> > 0. <br/>
     * <b>Default value:</b> 0.5. */
    float gm_tolerance;

    /*! @brief
     * Tolerance parameter to assess color temperature similarity: assume same colour temperature if absolute difference smaller than this value.
     * Parameter of the profile selection oscillation detection logic.<br/>
     * <b>Restrictions:</b> > 0 and >= 2 * #hysteresis_offset  <br/>
     * <b>Default value:</b> 175 K. */
    float ct_tolerance;

    /*! @brief
     * Tolerance parameter to assess similarity of AWB statistics: assume identical statistics if euclidean norm smaller than this value.
     * Parameter of the profile selection oscillation detection logic.<br/>
     * <b>Restrictions:</b> > 0. <br/>
     * <b>Default value:</b> 1.5. */
    float stats_tolerance;

} evision_awb_hyper_param_t;

/**
 * @typedef evision_awb_estimator_t
 * @brief AWB estimator structure.
 *
 * @struct evision_awb_estimator
 * @brief AWB estimator structure.
 *
 * Set of all data structures required for the functioning of the AWB algorithm.
 */
typedef struct evision_awb_estimator {
    /*! @brief
     * Indicates the state of the AWB algorithm. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * Possible values: see #evision_state_t */
    evision_state_t state;

    /*! @brief
     * Computed sensor/ISP gain values stored as float values.
     * To be applied to the sensor/ISP after conversion to the format expected by the sensor/ISP. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * <b>Note:</b> Storing values as floats provides the required flexibility to support different sensors and ISPs.
     * Converting the float value to the specific sensor/ISP format is to be performed at application level.
     */
    float dg_cf[EVISION_AWB_NB_DG_CFA_GAINS];
    /*! @brief
     * Computed ISP CCM coefficients stored as float values.
     * To be applied to the sensor/ISP after conversion to the format expected by the sensor/ISP. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * <b>Note:</b> Storing values as floats provides the required flexibility to support different sensors and ISPs.
     * Converting the float value to the specific sensor/ISP format is to be performed at application level.
     */
    float ccm[EVISION_AWB_CCM_SIZE][EVISION_AWB_CCM_SIZE];
    /*! @brief
     * Computed ISP CCM offset coefficients stored as float values.
     * To be applied to the sensor/ISP after conversion to the format expected by the sensor/ISP. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * <b>Note:</b> Storing values as floats provides the required flexibility to support different sensors and ISPs.
     * Converting the float value to the specific sensor/ISP format is to be performed at application level.
     */
    float ccm_offsets[EVISION_AWB_CCM_SIZE];

    /*! @brief
     * Estimated color temperature. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter. Must not be changed! <br/>
     * <b>Default value:</b> 5000 °K
     */
    double out_temp;

    /*! @brief
     * Select the AWB operating mode. <br/>
     * <b>Restrictions:</b> Only profile selection AWB is currently supported.
     */
    uint8_t awb_mode;

    /*! @brief
     * The set of run-time variables. <br/>
     * <b>Restrictions:</b> Internal algorithm parameters.
     * Must not be changed! */
    evision_awb_priv_param_runtime_t runtime_vars;

    /*! @brief
     * AWB calibration data. <br/>
     * <b>Restrictions:</b> Internal algorithm parameter.
     * Must be set during initialization using the provided functions!
     * Must not be changed during runtime! */
    evision_awb_calib_data_t calib_data;

    /*! @brief
     * The set of AWB algorithm hyper-parameters. Set to default values during initialization! <br/>
     * As a general note, the hyper-parameters can be updated from their default values.
     * Care must be taken as in such a case there is no guarantee of proper functioning of the estimator! <br/>
     * <b>Restrictions:</b> Must not be updated during runtime!
     */
    evision_awb_hyper_param_t hyper_params;

    /*! @brief
     * Handler to output logs. <br/> */
    evision_api_log_callback log_cb;

} evision_awb_estimator_t;

/************************************************************************
 * Public Variables
 ************************************************************************/

/************************************************************************
 * Public Function Prototypes
 ************************************************************************/

/************************************************************************
 * Public Function Definitions
 ************************************************************************/

/**
 * @fn evision_awb_estimator_t* evision_api_awb_new(void);
 * @brief Create a new #evision_awb_estimator_t instance.
 *
 * @param[in] log_cb Callback to output logs.
 * @return The address of the created instance. NULL if it failed.
 *
 * This function performs dynamic memory allocations for the AWB estimator.
 * If the process fails, NULL is returned.
 *
 * @warning Allocates memory. Free memory with evision_api_awb_delete().
 */
evision_awb_estimator_t* evision_api_awb_new(evision_api_log_callback log_cb);

/**
 * @fn evision_return_t evision_api_awb_delete(evision_awb_estimator_t* self);
 * @brief Releases the memory allocated for the #evision_awb_estimator_t estimator instance.
 *
 * @param[in, out] self Concerned estimator instance address.
 * @return
 * - EVISION_RET_SUCCESS
 * - EVISION_RET_PARAM_ERR
 *
 * This function releases the memory allocated for an AWB estimator.
 * To be called when the estimator is no longer required.
 */
evision_return_t evision_api_awb_delete(evision_awb_estimator_t* self);

/**
 * @brief Set the parameters of the input AWB profile structure.
 *
 * @param[in, out] awb_profile AWB profile structure.
 * @param[in] color_temperature Color temperature of the illumination used to derive the profile parameters.
 * @param[in] cfa_gains Array containing the sensor/ISP channel gains.
 * @param[in] ccm_coefficients Matrix containing the color correction matrix coefficients.
 * @param[in] ccm_offsets Array containing the color correction matrix offsets.
 *
 */
void evision_api_awb_set_profile(evision_awb_profile_t* awb_profile,
    float color_temperature, const float cfa_gains[EVISION_AWB_NB_DG_CFA_GAINS],
    const float ccm_coefficients[EVISION_AWB_CCM_SIZE][EVISION_AWB_CCM_SIZE],
    const float ccm_offsets[EVISION_AWB_CCM_SIZE]);

/**
 * @brief Initialize the AWB profiles from user supplied data.
 * The library supports a variable number of profiles from a minimum of 1 up to a max number of #EVISION_AWB_MAX_PROFILE_COUNT.
 *
 * @param[in, out] self AWB estimator to be initialized.
 * @param[in] min_temp Minimum supported color temperature, positive value.
 * @param[in] max_temp Maximum supported color temperature, positive value and greater than min_temp.
 * @param[in] nb_profiles The number of defined profiles, between 1 and #EVISION_AWB_MAX_PROFILE_COUNT.
 * @param[in] decision_thresholds The decision thresholds between profiles in degrees Kelvin. A total of nb_profiles - 1 decision thresholds must be provided.
 * @param[in] awb_profiles Array of profile data, a total of nb_profiles must be provided.
 * @return
 * - EVISION_RET_SUCCESS
 * - EVISION_RET_PARAM_ERR
 * - EVISION_RET_FAILURE
 *
 * The min_temp parameter must be at most equal to the smallest color temperature of the defined profiles.
 * The max_temp parameter must be at least equal to the highest color temperature of the defined profiles.
 *
 * The profiles must be unique with respect to the color temperature of the illumination and must be specified in ascending order.
 * The choice of the actual number of profiles and the color temperature of the illumination for each profile is
 * generally dependent on the intended application and/or the available hardware equipement for generating the calibration data.
 * They must be complete in the sense that they must contain all the required fields (channel gains and color correction coefficients).
 * It is the user's responsibility to ensure that this is indeed the case.
 *
 * The decision thresholds must be unique and specified in ascending order.
 * Between each pair of adjacent profiles there must be exactly one decision threshold.
 * The exact strategy for choosing the decision thresholds between adjacent thresholds (e.g. halfway, 1/3 - 2/3, etc.)
 * is a tuning strategy which generally depends on the intended application and the choice of the profiles.
 *
 */
evision_return_t evision_api_awb_init_profiles(evision_awb_estimator_t* const self,
    double min_temp, double max_temp,
    uint16_t nb_profiles, float decision_thresholds[EVISION_AWB_MAX_PROFILE_COUNT - 1],
    evision_awb_profile_t awb_profiles[EVISION_AWB_MAX_PROFILE_COUNT]);

/**
 * @brief Run the AWB estimator on the full frame data.
 *
 * @param[in] self Concerned estimator instance address.
 * @param[in] image Current frame.
 * @param[in] use_ext_meas Flag to indicate the use of external AWB measurement: 0 - use internal AWB measurement, > 0 - use external measurement.
 * @param[in] ext_meas External measurement vector, contains average R, G, B values.
 * @return
 * - EVISION_RET_INVALID_VALUE
 * - EVISION_RET_SUCCESS
 * - EVISION_RET_PARAM_ERROR
 * - EVISION_RET_FAILURE
 *
 * Run an execution of the control loop on the current camera setup and frame.
 * The parameters #evision_awb_estimator_t.ccm and #evision_awb_estimator_t.dg_cf are updated to reflect the new CCMs and channel gains to apply.
 *
 * The software statistics extraction block, if used, will consider the entire data frame in the extraction of the AWB statistics.
 * The parameter #evision_awb_hyper_param_t.awb_process_ratio defines a ratio of pixels to check PER row and PER column.
 * It serves to reduce the computational requirements for AWB statistics extraction.
 * For example: a process_ratio of 4 means that for every 4 pixels per row and per column, (block of 16 pixels) only 1 is considered.
 * For small to moderate values, the loss in accuracy is mostly negligeable with non-negligeable improvements in computational time.
 *
 * The average R, G, and B values provided by the external \[hardware\] measurement block must be in the range \[0, 255\].
 * If the data is in a different range, the average values must be converted to this range before being passed as parameters to the function.
 *
 * The switch at run-time between using the internal software measurements and the external \[hardware\] measurements is not supported.
 *
 * <b>Raises:</b>
 * - EVISION_LOGSEV_INFO
 * - EVISION_LOGSEV_WARNING
 * - EVISION_LOGSEV_ERROR
 */
evision_return_t evision_api_awb_run_average(evision_awb_estimator_t* const self, const evision_image_t* const image,
    uint8_t use_ext_meas, double ext_meas[EVISION_AWB_EXT_MEAS_SIZE]);

#ifdef ALGO_SW_STATISTICS
/**
 * @brief Run the AWB estimator on the selected ROIs.
 *
 * @param[in] self Concerned estimator instance address.
 * @param[in] image Current frame.
 * @param[in] roi_array Set of ROIs where the process will be applied, other regions will not be considered.
 * @param[in] use_ext_meas Flag to indicate the use of external AWB measurement: 0 - use internal AWB measurement, > 0 - use external measurement.
 * @param[in] ext_meas External measurement vector, contains average R, G, B values.
 * @return
 * - EVISION_RET_INVALID_VALUE
 * - EVISION_RET_SUCCESS
 * - EVISION_RET_PARAM_ERROR
 * - EVISION_RET_FAILURE
 *
 * Run an execution of the control loop on the current camera setup and frame.
 * The parameters #evision_awb_estimator_t.ccm and #evision_awb_estimator_t.dg_cf are updated to reflect the new CCMs and channel gains to apply.
 *
 * The software statistics extraction block, if used, will only considered the pixels within the specified ROIs.
 * The parameter #evision_awb_hyper_param_t.awb_process_ratio defines, within the ROI to check, a portion of pixels to check PER row and PER column.
 * It serves to reduce the computational requirements for AWB statistics extraction.
 * For example: a process_ratio of 4 means that for every 4 pixels per row and per column, (block of 16 pixels) only 1 is considered.
 * For small to moderate values, the loss in accuracy is mostly negligeable with non-negligeable improvements in computational time.
 *
 * The average R, G, and B values provided by the external \[hardware\] measurement block must be in the range \[0, 255\].
 * If the data is in a different range, the average values must be converted to this range before being passed as parameters to the function.
 *
 * The switch at run-time between using the internal software measurements and the external \[hardware\] measurements is not supported.
 *
 * <b>Raises:</b>
 * - EVISION_LOGSEV_INFO
 * - EVISION_LOGSEV_WARNING
 * - EVISION_LOGSEV_ERROR
 */
evision_return_t evision_api_awb_run_roi(evision_awb_estimator_t* const self,
    const evision_image_t* const image, const evision_roi_array_t* const roi_array,
    uint8_t use_ext_meas, double ext_meas[EVISION_AWB_EXT_MEAS_SIZE]);
#endif

#endif /* EVISION_API_AWB_H_ */
