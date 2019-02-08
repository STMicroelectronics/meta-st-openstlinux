How to deploy demonstration:
----------------------------
Materials:
 * Nucleo extension board with mems, here IKS01A2
 * connection between extension board and stm32mp15 board.

Pre-requisite:
--------------
1. Kernel:
 You need to configure the kernel to support the Nucleo extension
 board with the devitree configuration and the kernel configuration.

1.1 DeviceTree:
 * Enable the sensor on I2C
   For Discovery board (stm32mp157c-dk2), the sensors are linked on ic25.
   Add the following line on your devicetree associateds to the board

&i2c5 {
	pinctrl-names = "default", "sleep";
	pinctrl-0 = <&i2c5_pins_a>;
	pinctrl-1 = <&i2c5_pins_sleep_a>;
	i2c-scl-rising-time-ns = <124>;
	i2c-scl-falling-time-ns = <3>;
	/delete-property/dmas;
	/delete-property/dma-names;

	status = "okay";

	hts221@5f {
		compatible = "st,hts221";
		reg = <0x5f>;
	};
	lsm6dsl@6b {
		compatible = "st,lsm6dsl";
		reg = <0x6b>;
	};
};

NOTE: the i2c depend of the pin-muxing of the board and could be different of
 i2c5.

1.2 Kernel configuration:
 Add the following config on your kernel configuraturation
 (best way are via a new fragment)
CONFIG_IIO_BUFFER=y
CONFIG_IIO_KFIFO_BUF=y
CONFIG_IIO_TRIGGERED_BUFFER=y
CONFIG_HTS221=y
CONFIG_IIO_ST_PRESS=y
CONFIG_IIO_ST_LSM6DSX=y
CONFIG_IIO_ST_LSM6DSX_I2C=y

2. Software
 You need to have some framework available on the board for executing the
 python script:

List of packages already present on st-example-image-weston:
 weston
 gtk+3
 python3 and several python3 addons

Execution of script on board:
-----------------------------
Files:
/usr/local/demo/
/usr/local/demo/sensors_temperature.py

Put the files on board and launch the python script:
  BOARD > /usr/local/demo/sensors_temperature.py

To quit the application, just click on ST logo.
