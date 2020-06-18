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
        rscale=`cat $d/in_accel_scale`

        xraw=`cat $d/in_accel_x_raw`
        yraw=`cat $d/in_accel_y_raw`
        zraw=`cat $d/in_accel_z_raw`

        printf "Value read: X (raw/scale)  %d / %.06f \n" $xraw $rscale
        printf "Value read: Y (raw/scale)  %d / %.06f \n" $yraw $rscale
        printf "Value read: Z (raw/scale)  %d / %.06f \n" $zraw $rscale

        factor=`echo "scale=2;256.0 / 9.81" | bc`
        xval=`echo "scale=2;$xraw*$rscale*$factor" | bc`
        yval=`echo "scale=2;$yraw*$rscale*$factor" | bc`
        zval=`echo "scale=2;$zraw*$rscale*$factor" | bc`

        printf "Accelerometer value: [ %.02f, %.02f, %.02f ]\n" $xval $yval $zval
    fi

    # for lsm6dsl: gyroscope
    if grep -q lsm6dsl_gyro $d/name ;
    then
        echo "============================="
        echo "===      LSM6DSL          ==="
        echo "===    (gyroscope)        ==="
        echo "============================="
        rscale=`cat $d/in_anglvel_scale`
        xraw=`cat $d/in_anglvel_x_raw`
        yraw=`cat $d/in_anglvel_y_raw`
        zraw=`cat $d/in_anglvel_z_raw`

        printf "Value read: X (raw/scale)  %d / %.06f \n" $xraw $rscale
        printf "Value read: Y (raw/scale)  %d / %.06f \n" $yraw $rscale
        printf "Value read: Z (raw/scale)  %d / %.06f \n" $zraw $rscale

        factor=`echo "scale=2;256.0 / 9.81" | bc`
        xval=`echo "scale=2;$xraw*$rscale*$factor" | bc`
        yval=`echo "scale=2;$yraw*$rscale*$factor" | bc`
        zval=`echo "scale=2;$zraw*$rscale*$factor" | bc`

        printf "Gyroscope value: [ %.02f, %.02f, %.02f ]\n" $xval $yval $zval
    fi
done
