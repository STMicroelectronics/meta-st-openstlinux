#!/bin/sh

for d in `ls -d1 /sys/bus/iio/devices/*device*`;
do
    # for hts221: Temperature + Humidity
    if grep -q hts221 $d/name ;
    then
        echo "============================="
        echo "===       HTS221          ==="
        echo "===    (temperature)      ==="
        echo "============================="
        raw=`cat $d/in_temp_raw`
        offset=`cat $d/in_temp_offset`
        scale=`cat $d/in_temp_scale`

        printf "Value read: raw         %0f\n" $raw
        printf "Value read: offset      %0f\n" $offset
        printf "Value read: scale       %0f\n" $scale

        temperature=`echo "scale=2;$raw*$scale + $offset*$scale" | bc`

        echo "Temperature $temperature"
        printf "Temperature %.02f\n" $temperature

        echo "============================="
        echo "===       HTS221          ==="
        echo "===    (humidity)         ==="
        echo "============================="
        raw=`cat $d/in_humidityrelative_raw`
        offset=`cat $d/in_humidityrelative_offset`
        scale=`cat $d/in_humidityrelative_scale`

        printf "Value read: raw         %0f\n" $raw
        printf "Value read: offset      %0f\n" $offset
        printf "Value read: scale       %0f\n" $scale

        humidity=`echo "scale=2;$raw*$scale + $offset*$scale" | bc`

        echo "Humidity $humidity"
        printf "Humidity %.02f\n" $humidity
    fi

    # for lsm6dsl: accelerometer
    if grep -q lsm6dsl_accel $d/name ;
    then
        echo "============================="
        echo "===      LSM6DSL          ==="
        echo "===    (accelerometer)    ==="
        echo "============================="
        xraw=`cat $d/in_accel_x_raw`
        xscale=`cat $d/in_accel_x_scale`

        yraw=`cat $d/in_accel_y_raw`
        yscale=`cat $d/in_accel_y_scale`

        zraw=`cat $d/in_accel_z_raw`
        zscale=`cat $d/in_accel_z_scale`

        printf "Value read: X (raw/scale)  %d / %.06f \n" $xraw $xscale
        printf "Value read: Y (raw/scale)  %d / %.06f \n" $yraw $yscale
        printf "Value read: Z (raw/scale)  %d / %.06f \n" $zraw $zscale

        factor=`echo "scale=2;256.0 / 9.81" | bc`
        xval=`echo "scale=2;$xraw*$xscale*$factor" | bc`
        yval=`echo "scale=2;$yraw*$yscale*$factor" | bc`
        zval=`echo "scale=2;$zraw*$zscale*$factor" | bc`

        printf "Accelerometer value: [ %.02f, %.02f, %.02f ]\n" $xval $yval $zval
    fi

    # for lsm6dsl: gyroscope
    if grep -q lsm6dsl_gyro $d/name ;
    then
        echo "============================="
        echo "===      LSM6DSL          ==="
        echo "===    (gyroscope)        ==="
        echo "============================="
        xraw=`cat $d/in_anglvel_x_raw`
        xscale=`cat $d/in_anglvel_x_scale`

        yraw=`cat $d/in_anglvel_y_raw`
        yscale=`cat $d/in_anglvel_y_scale`

        zraw=`cat $d/in_anglvel_z_raw`
        zscale=`cat $d/in_anglvel_z_scale`

        printf "Value read: X (raw/scale)  %d / %.06f \n" $xraw $xscale
        printf "Value read: Y (raw/scale)  %d / %.06f \n" $yraw $yscale
        printf "Value read: Z (raw/scale)  %d / %.06f \n" $zraw $zscale

        factor=`echo "scale=2;256.0 / 9.81" | bc`
        xval=`echo "scale=2;$xraw*$xscale*$factor" | bc`
        yval=`echo "scale=2;$yraw*$yscale*$factor" | bc`
        zval=`echo "scale=2;$zraw*$zscale*$factor" | bc`

        printf "Gyroscope value: [ %.02f, %.02f, %.02f ]\n" $xval $yval $zval
    fi
done
