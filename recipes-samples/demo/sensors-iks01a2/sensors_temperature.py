#!/usr/bin/python3
# to debug this script:
#      python3 -m pdb ./sensors_temperature.py
#
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from gi.repository import GObject
from gi.repository import Gdk
from gi.repository import GLib
from gi.repository import GdkPixbuf
import cairo

import random
import math
import os
import socket
from collections import deque
from time import sleep, time

#
# For simulating the presence of sensor, please use
# the variable SIMULATE_SENSORS = 1
# If SIMULATE_SENSORS = 1 then
#    the picture/icon must be present on pictures directory
#
SIMULATE_SENSORS = 0

ICON_PICTURES_PATH = "/usr/local/demo/pictures"

WITH_PRESSURE = 0
WITH_GYRO = 1

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# CONSTANT VALUES
#
SIMULATE_SCREEN_SIZE_WIDTH  = 480
SIMULATE_SCREEN_SIZE_HEIGHT = 800
DEFAULT_SCREEN_WIDTH = 400
DEFAULT_SCREEN_HEIGHT = 600

# time between each sensor mesearuement (1s)
TIME_UPATE = 2000

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# SPLASH SCREEN class
#    the splash screen display a logo and the different step of boot
#
class SplashScreen():
    def __init__(self, picture_filename, timeout):
        #DONT connect 'destroy' event here!
        self.window = Gtk.Window()
        self.window.set_title('Sensor IKS01A2')
        self.window.set_position(Gtk.WindowPosition.CENTER)
        self.window.set_decorated(False)
        if SIMULATE_SENSORS > 0:
            screen_width = SIMULATE_SCREEN_SIZE_WIDTH
            screen_height = SIMULATE_SCREEN_SIZE_HEIGHT
        else:
            self.window.fullscreen()
            #self.maximize()
            screen_width = self.window.get_screen().get_width()
            screen_height = self.window.get_screen().get_height()

        self.window.set_default_size(screen_width, screen_height)
        self.window.set_border_width(1)

        # Add Vbox with image and label
        main_vbox = Gtk.VBox(False, 1)
        self.window.add(main_vbox)
        # load picture
        print("[DEBUG] Splash screen with picture: %s" % picture_filename)
        if os.path.exists(picture_filename):
            pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                filename=picture_filename,
                width=400, # TODO: change size
                height=600, # TODO: change size
                preserve_aspect_ratio=True)
            image = Gtk.Image.new_from_pixbuf(pixbuf)
            main_vbox.pack_start(image, True, True, 0)

        #self.lbl = Gtk.Label("Init: splash screen")
        #self.lbl.set_alignment(0, 0.5)
        #main_vbox.pack_start(self.lbl, True, True, 0)

        self.window.set_auto_startup_notification(False)
        self.window.show_all()
        self.window.set_auto_startup_notification(True)

        # Ensure the splash is completely drawn before moving on
        GLib.timeout_add(1000, self.loop)
        self.loops = 0
        self.loops_timeout = timeout
        self.loops_break = 0

    def update_text(self, text):
        self.lbl.set_text(text)

    def loop_stop(self):
        self.loops_break = 1

    def loop(self):
        global var
        var = time ()
        print ("[DEBUG] ",  var)
        self.loops += 1
        if self.loops_break or self.loops == self.loops_timeout:
            Gtk.main_quit()
            self.window.destroy()
            return False
        return True

# -------------------------------------------------------------------
# -------------------------------------------------------------------
def _load_image_on_button(parent, filename, label_text, scale_w, scale_h):
    # Create box for xpm and label
    box1 = Gtk.HBox(homogeneous=False, spacing=0)
    box1.set_border_width(2)
    # Now on to the image stuff
    #image = Gtk.Image()
    #image.set_from_file(filename)
    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
            filename=filename,
            width=scale_w,
            height=scale_h,
            preserve_aspect_ratio=True)
    image = Gtk.Image.new_from_pixbuf(pixbuf)

    # Create a label for the button
    label = Gtk.Label(label_text)

    # Pack the pixmap and label into the box
    box1.pack_start(image, True, False, 3)
    #box1.pack_start(label, False, False, 3)

    image.show()
    label.show()
    return box1
# -------------------------------------------------------------------
# -------------------------------------------------------------------
def _load_image(parent, filename_without_prefix):
    img = Gtk.Image()
    img.set_from_file("%s/%s" % (ICON_PICTURES_PATH, filename_without_prefix))
    return img

# scale_width and scale_height are sht siez disired after scale,
# It can be -1 for no scale on one value
def _load_image_constrained(parent, filename_without_prefix, scale_width, scale_height):
    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
            filename="%s/%s" % (ICON_PICTURES_PATH, filename_without_prefix),
            width=scale_width,
            height=scale_height,
            preserve_aspect_ratio=True)
    image = Gtk.Image.new_from_pixbuf(pixbuf)
    return image

# -------------------------------------------------------------------
# -------------------------------------------------------------------
class Sensors():
    key_temperature = 'temp'
    key_humidity    = 'humidity'
    key_pressure    = 'pressure'

    key_accelerometer = 'accel'
    key_gyroscope     = 'gyro'
    key_magnetometer  = 'magneto'

    driver_name_temperature   = 'driver_temp'
    driver_name_humidity      = 'driver_humidity'
    driver_name_pressure      = 'driver_pressure'
    driver_name_accelerometer = 'driver_accel'
    driver_name_gyroscope     = 'driver_gyro'
    driver_name_magnetometer  = 'driver_magneto'


    prefix_temp     = "in_temp_"
    prefix_humidity = "in_humidityrelative_"
    prefix_pressure = "in_pressure_"

    prefix_accel   = "in_accel_"
    prefix_gyro    = "in_anglvel_"
    prefix_magneto = "in_magn_"    # TODO: verify

    def __init__(self):
        ''' '''
        self.sensor_dictionnary = {}

    def init_pressure_sampling_frequency(self):
        if not self.sensor_dictionnary[self.key_pressure] is None and len(self.sensor_dictionnary[self.key_pressure]) > 5:
            with open(self.sensor_dictionnary[self.key_pressure] + 'sampling_frequency', 'w') as f:
                f.write('10')

    def found_iio_device(self, data):
        prefix = "/sys/bus/iio/devices/"
        try:
            for filefolder in os.listdir(prefix):
                if os.path.exists(prefix + '/' + filefolder + '/' + data):
                    ''' return directory which contains "data" '''
                    return (prefix + '/' + filefolder + '/')
        except OSError:
            pass
        return None

    def found_iio_device_with_name(self, data, name):
        prefix = "/sys/bus/iio/devices/"
        of_name = 'OF_NAME=' + name
        try:
            for filefolder in os.listdir(prefix):
                with open(prefix + '/' + filefolder + '/uevent') as f:
                    for line in f:
                        if line.split('\n')[0] == of_name:
                            ''' return directory which contains "data" '''
                            if os.path.exists(prefix + '/' + filefolder + '/' + data):
                                return (prefix + '/' + filefolder + '/')
        except OSError:
            pass
        except Exception as exc:
            pass
        return None


    def driver_name_iio_device(self, key):
        if SIMULATE_SENSORS > 0:
            val_name = "-Simulated-"
        else:
            if self.sensor_dictionnary[key] == None:
                val_name = "-Not present / Simulated-"
            else:
                try:
                    with open(self.sensor_dictionnary[key] + "name", 'r') as f:
                        val_name = f.read()
                except Exception as exc:
                    val_name = "-Not present-"
        return val_name

    def found_all_sensor_path(self):
        self.sensor_dictionnary[self.key_temperature] = self.found_iio_device_with_name("in_temp_raw", "hts221")
        self.sensor_dictionnary[self.key_humidity]    = self.found_iio_device("in_humidityrelative_raw")
        self.sensor_dictionnary[self.key_pressure]    = self.found_iio_device("in_pressure_raw")

        self.sensor_dictionnary[self.key_accelerometer] = self.found_iio_device("in_accel_x_raw")
        if WITH_GYRO:
            self.sensor_dictionnary[self.key_gyroscope] = self.found_iio_device("in_anglvel_x_raw")
        else:
            self.sensor_dictionnary[self.key_gyroscope] = ""

        self.sensor_dictionnary[self.key_magnetometer] = "" #TODO

        self.sensor_dictionnary[self.driver_name_temperature] = self.driver_name_iio_device(self.key_temperature)
        self.sensor_dictionnary[self.driver_name_humidity]    = self.driver_name_iio_device(self.key_humidity)
        self.sensor_dictionnary[self.driver_name_pressure]    = self.driver_name_iio_device(self.key_pressure)

        self.sensor_dictionnary[self.driver_name_accelerometer] = self.driver_name_iio_device(self.key_accelerometer)
        self.sensor_dictionnary[self.driver_name_gyroscope]     = self.driver_name_iio_device(self.key_gyroscope)
        self.sensor_dictionnary[self.driver_name_magnetometer]  = self.driver_name_iio_device(self.key_magnetometer)

        self.init_pressure_sampling_frequency()
        print("[DEBUG] " , self.key_temperature, " -> ", self.sensor_dictionnary[self.key_temperature], "<")
        print("[DEBUG] " , self.key_humidity, " -> ", self.sensor_dictionnary[self.key_humidity], "<")
        print("[DEBUG] " , self.key_pressure, " -> ", self.sensor_dictionnary[self.key_pressure], "<")
        print("[DEBUG] " , self.key_accelerometer, " -> ", self.sensor_dictionnary[self.key_accelerometer], "<")
        print("[DEBUG] " , self.key_gyroscope, " -> ", self.sensor_dictionnary[self.key_gyroscope], "<")
        print("[DEBUG] " , self.key_magnetometer, " -> ", self.sensor_dictionnary[self.key_magnetometer], "<")


    def read_sensor_basic(self, key, prefix):
        if SIMULATE_SENSORS > 0:
            if self.key_temperature == key:
                return random.uniform(0.0, 50.0)
            elif self.key_humidity == key:
                return random.uniform(0.0, 100.0)
            else:
                return random.uniform(800.0, 1200.0)
        else:
            if self.sensor_dictionnary[key] is None or len(self.sensor_dictionnary[key]) < 5:
                return 0.0
            try:
                with open(self.sensor_dictionnary[key] + prefix + 'raw', 'r') as f:
                    raw = float(f.read())
            except Exception as exc:
                print("[ERROR] read %s " % self.sensor_dictionnary[key] + prefix + 'raw', exc)
                raw = 0.0
            try:
                with open(self.sensor_dictionnary[key] + prefix + 'scale', 'r') as f:
                    scale = float(f.read())
            except Exception as exc:
                print("[ERROR] read %s " % self.sensor_dictionnary[key] + prefix + 'scale', exc)
                scale = 0.0
            if self.key_pressure != key:
                try:
                    with open(self.sensor_dictionnary[key] + prefix + 'offset', 'r') as f:
                        offset = float(f.read())
                except Exception as exc:
                    print("[ERROR] read %s " % self.sensor_dictionnary[key] + prefix + 'offset', exc)
                    offset = 0.0
            else:
                offset = 0.0
                scale = scale * 10

            temp = (offset + raw) * scale
            #print("[DEBUG] [%s] %f" % (key, temp))
            return temp
    def read_sensor_move(self, key, prefix):
        if SIMULATE_SENSORS > 0:
            in_x = random.randint(-180, 180)
            in_y = random.randint(-180, 180)
            in_z = random.randint(-180, 180)
            return [in_x, in_y, in_z]
        else:
            if self.sensor_dictionnary[key] is None or len(self.sensor_dictionnary[key]) < 5:
                return [0, 0, 0]
            try:
                with open(self.sensor_dictionnary[key] + prefix + 'x_raw', 'r') as f:
                    scale = float(f.read())
                with open(self.sensor_dictionnary[key] + prefix + 'x_scale', 'r') as f:
                    raw = float(f.read())
                in_x = int(raw * scale * 256.0 / 9.81)
                with open(self.sensor_dictionnary[key] + prefix + 'y_raw', 'r') as f:
                    scale = float(f.read())
                with open(self.sensor_dictionnary[key] + prefix + 'y_scale', 'r') as f:
                    raw = float(f.read())
                in_y = int(raw * scale * 256.0 / 9.81)
                with open(self.sensor_dictionnary[key] + prefix + 'z_raw', 'r') as f:
                    scale = float(f.read())
                with open(self.sensor_dictionnary[key] + prefix + 'z_scale', 'r') as f:
                    raw = float(f.read())
                in_z = int(raw * scale * 256.0 / 9.81)
            except Exception as exc:
                print("[ERROR] read %s " % self.sensor_dictionnary[key] + prefix + '[x_ , y_ , z_ ]', exc)
                return [0, 0, 0]
            return [in_x, in_y, in_z]

    def read_temperature(self):
        return self.read_sensor_basic(self.key_temperature, self.prefix_temp)
    def read_humidity(self):
        return self.read_sensor_basic(self.key_humidity, self.prefix_humidity)
    def read_pressure(self):
        return self.read_sensor_basic(self.key_pressure, self.prefix_pressure)

    def read_accelerometer(self):
        return self.read_sensor_move(self.key_accelerometer, self.prefix_accel)
    def read_gyroscope(self):
        return self.read_sensor_move(self.key_gyroscope, self.prefix_gyro)
    def read_magnetometer(self):
        return self.read_sensor_move(self.key_magnetometer, self.prefix_magneto)

    def get_driver_name_temperature(self):
        return self.sensor_dictionnary[self.driver_name_temperature]
    def get_driver_name_humidity(self):
        return self.sensor_dictionnary[self.driver_name_humidity]
    def get_driver_name_pressure(self):
        return self.sensor_dictionnary[self.driver_name_pressure]
    def get_driver_name_accelerometer(self):
        return self.sensor_dictionnary[self.driver_name_accelerometer]
    def get_driver_name_gyroscope(self):
        return self.sensor_dictionnary[self.driver_name_gyroscope]
    def get_driver_name_magnetometer(self):
        return self.sensor_dictionnary[self.driver_name_magnetometer]

    def calculate_imu(self, accel):
        x = accel[0]
        y = accel[1]
        z = accel[2]
        if x == 0 and y == 0 and z == 0:
            return [0, 0, 0]
        pitch = round(math.atan(x / math.sqrt(y * y + z * z)) * (180.0 / math.pi))
        roll  = round(math.atan(y / math.sqrt(x * x + z * z)) * (180.0 / math.pi))
        yaw   = round(math.atan(z / math.sqrt(x * x + z * z)) * (180.0 / math.pi))

        return [pitch, roll, yaw]
    def get_imu_orientation(self, pitch, roll):
        if abs(pitch) > 35:
            ''' (rotation > 0) ? ORIENTATION_LEFT_UP : ORIENTATION_RIGHT_UP;'''
            if pitch > 0:
                return "left-up"
            else:
                return "right-up"
        else:
            if abs(roll) > 35:
                '''ret = (rotation > 0) ? ORIENTATION_BOTTOM_UP : ORIENTATION_NORMAL;'''
                if roll > 0:
                    return "bottom-up"
                else:
                    return "normal"

# -------------------------------------------------------------------
# -------------------------------------------------------------------
class MainUIWindow(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Sensor usage")
        self.set_decorated(False)
        if SIMULATE_SENSORS > 0:
            self.screen_width = SIMULATE_SCREEN_SIZE_WIDTH
            self.screen_height = SIMULATE_SCREEN_SIZE_HEIGHT
        else:
            self.fullscreen()
            #self.maximize()
            self.screen_width = self.get_screen().get_width()
            self.screen_height = self.get_screen().get_height()

        self.set_default_size(self.screen_width, self.screen_height)
        print("[DEBUG] screen size: %dx%d" % (self.screen_width, self.screen_height))
        self.set_position(Gtk.WindowPosition.CENTER)
        self.connect('destroy', Gtk.main_quit)

        # search sensor interface
        self.sensors = Sensors()
        self.sensors.found_all_sensor_path()

        # variable for sensor
        self._axis_ranges = {}  # {axis_num: [min_seen, max_seen]}
        self._axis_values = {}  # {axis_num: deque([val0, ..., valN])}
        # create nodebook
        self.notebook = Gtk.Notebook()
        self.add(self.notebook)

        # page for basic information
        # current temperature / Humidity / Pressure
        self.create_notebook_page_basic_sensor()

        # page for accel / gyro / magentic
        self.create_notebook_page_basic_accel()

        # page for IMU
        self.create_notebook_page_imu()

        # page sensor information
        self.create_notebook_page_sensor_information()

        # page for quitting application
        self.create_notebook_page_exit()

        # Add a timer callback to update
        # this takes 2 args: (how often to update in millisec, the method to run)
        self.timer = GObject.timeout_add(TIME_UPATE, self.update_ui, None)
        self.timer_enable = True

        self.show_all()

    def _set_basic_temperature(self, val):
        self.temperature_basic_label.set_markup("<span font_desc='LiberationSans 25'>%.02f °C</span>" % val)
        #self.temperature_basic_label.set_text("%.02f °C" % val)
    def _set_basic_humidity(self, val):
        self.humidity_basic_label.set_markup("<span font_desc='LiberationSans 25'>%.02f %c</span>" % (val, '%'))
        #self.humidity_basic_label.set_text("%.02f %c" % (val, '%'))
    def _set_basic_pressure(self, val):
        self.pressure_basic_label.set_markup("<span font_desc='LiberationSans 25'>%.02f hP</span>" % val)
        #self.pressure_basic_label.set_text("%.02f hP" % val)
    def _set_basic_accelerometer(self, x, y, z):
        self.liststore[self.accel_store][1] = '%d' % x
        self.liststore[self.accel_store][2] = '%d' % y
        self.liststore[self.accel_store][3] = '%d' % z
    def _set_basic_gyroscope(self, x, y, z):
        self.liststore[self.gyro_store][1] = '%d' % x
        self.liststore[self.gyro_store][2] = '%d' % y
        self.liststore[self.gyro_store][3] = '%d' % z
    def _set_basic_magnetometer(self, x, y, z):
        self.liststore[self.magneto_store][1] = '%d' % x
        self.liststore[self.magneto_store][2] = '%d' % y
        self.liststore[self.magneto_store][3] = '%d' % z
    def _set_imu_roll(self, val):
        self.imu_liststore[self.roll_store][1] = '%d' % val
    def _set_imu_pitch(self, val):
        self.imu_liststore[self.pitch_store][1] = '%d' % val
    def _set_imu_yaw(self, val):
        self.imu_liststore[self.yaw_store][1] = '%d' % val
    def _update_orientation(self, val):
        self.orientation_label.set_markup("<span font_desc='LiberationSans 25'>Orientation: %s</span>" % val)

    def create_notebook_page_basic_sensor(self):
        '''
        create notebook page for displaying basic current
        sensor information: temperature, humidity, pressure
        '''
        page_basic = Gtk.HBox(homogeneous=False, spacing=0)
        page_basic.set_border_width(10)

        # temperature
        temp_box = Gtk.VBox(homogeneous=False, spacing=0)
        temp_image = _load_image_constrained(self, "RS1069_climate_change_light_blue.png", -1, 100)
        self.temperature_basic_label = Gtk.Label('--.-- °C')
        temp_image.show()
        self.temperature_basic_label.show()
        temp_box.pack_start(temp_image, True, False, 1)
        temp_box.add(self.temperature_basic_label)
        # humidity
        humidity_box = Gtk.VBox(homogeneous=False, spacing=0)
        humidity_image = _load_image_constrained(self, "RS1902_humidity_light_blue.png", -1, 100)
        self.humidity_basic_label = Gtk.Label('--.-- °C')
        humidity_image.show()
        self.humidity_basic_label.show()
        humidity_box.pack_start(humidity_image, True, False, 1)
        humidity_box.add(self.humidity_basic_label)
        # Pressure
        if WITH_PRESSURE:
            pressure_box = Gtk.VBox(homogeneous=False, spacing=0)
            pressure_image = _load_image_constrained(self, "RS6355_FORCE_PRESSURE_light_blue.png", -1, 100)
            self.pressure_basic_label = Gtk.Label('--.-- °C')
            pressure_image.show()
            self.pressure_basic_label.show()
            pressure_box.pack_start(pressure_image, True, False, 1)
            pressure_box.add(self.pressure_basic_label)

        page_basic.add(temp_box)
        page_basic.add(humidity_box)
        if WITH_PRESSURE:
            page_basic.add(pressure_box)
        notebook_title =  Gtk.Label()
        notebook_title.set_markup("<span font_desc='LiberationSans 25'>Sensors</span>")
        self.notebook.append_page(page_basic, notebook_title)

    def create_notebook_page_basic_accel(self):
        '''
        create notebook page for displaying movement
        sensor information: accellerometer, gyroscope, magentometer
        '''
        page_basic_movement = Gtk.Box()
        page_basic_movement.set_border_width(10)

        self.liststore = Gtk.ListStore(str, str, str, str)
        self.accel_store = self.liststore.append([ "Accelerometer", "0.0", "0.0", "0.0" ])
        if WITH_GYRO:
            self.gyro_store = self.liststore.append([ "Gyroscope", "0.0", "0.0", "0.0" ])
        #if WITH_MAGNETO:
        #    self.magneto_store = self.liststore.append([ "Magnetometer", "0.0", "0.0", "0.0" ])
        treeview = Gtk.TreeView(model=self.liststore)

        renderer_text = Gtk.CellRendererText()
        column_text = Gtk.TreeViewColumn("Sensor", renderer_text, text=0)
        treeview.append_column(column_text)

        renderer_x = Gtk.CellRendererText()
        column_x = Gtk.TreeViewColumn("X", renderer_x, text=1)
        treeview.append_column(column_x)

        renderer_y = Gtk.CellRendererText()
        column_y = Gtk.TreeViewColumn("Y", renderer_y, text=2)
        treeview.append_column(column_y)

        renderer_z = Gtk.CellRendererText()
        column_z = Gtk.TreeViewColumn("Z", renderer_z, text=3)
        treeview.append_column(column_z)

        page_basic_movement.add(treeview)
        notebook_title =  Gtk.Label()
        notebook_title.set_markup("<span font_desc='LiberationSans 25'>Move</span>")
        self.notebook.append_page(page_basic_movement, notebook_title)


    def create_notebook_page_imu(self):
        '''
            display the IMU: Inertial Measurement Unit
            Roll(X-axis), Pitch(Y-axis) and Yaw(Z-axis).
        '''
        page_imu_all = Gtk.VBox(homogeneous=False, spacing=0)
        imu_frame = Gtk.Frame(label="IMU")
        orientation_frame = Gtk.Frame(label="Orientation")

        page_imu = Gtk.VBox(homogeneous=False, spacing=0)

        #page_imu_all.add(page_imu)
        page_imu_all.add(imu_frame)
        page_imu_all.add(orientation_frame)

        page_imu.set_border_width(10)
        # explanation
        imu_label = Gtk.Label()
        imu_label.set_markup("<span font_desc='LiberationSans 25'>Inertial Measurement Unit</span>")

        page_imu.add(imu_label)

        imu_h_box = Gtk.HBox(homogeneous=False, spacing=0)
        # picture which describe IMU
        picture_filename = "%s/RS10670_Aereo-lpr.jpg" % ICON_PICTURES_PATH
        image_imu = _load_image(self, "RS10670_Aereo-lpr.jpg")

        imu_h_box.pack_start(image_imu, True, True, 10)
        # add tree view with roll, picth, yaw
        self.imu_liststore = Gtk.ListStore(str, str)
        self.roll_store  = self.imu_liststore.append([ "Roll  (X-axis)", "0.0"])
        self.pitch_store = self.imu_liststore.append([ "Pitch (Y-axis)", "0.0"])
        self.yaw_store   = self.imu_liststore.append([ "Yaw   (Z-axis)", "0.0"])
        imu_treeview = Gtk.TreeView(model=self.imu_liststore)
        imu_h_box.add(imu_treeview)
        page_imu.add(imu_h_box)
        imu_frame.add(page_imu)

        self.orientation_label = Gtk.Label()
        self.orientation_label.set_markup("<span font_desc='LiberationSans 25'>Orientation: --none--</span>")
        orientation_frame.add(self.orientation_label)

        renderer_text = Gtk.CellRendererText()
        #renderer_text.set_property("size", 18)
        column_imu_text = Gtk.TreeViewColumn('Type', renderer_text, text=0)
        imu_treeview.append_column(column_imu_text)
        renderer_val = Gtk.CellRendererText()
        column_val = Gtk.TreeViewColumn("Value", renderer_val, text=1)
        imu_treeview.append_column(column_val)

        notebook_title =  Gtk.Label()
        notebook_title.set_markup("<span font_desc='LiberationSans 25'>IMU</span>")
        self.notebook.append_page(page_imu_all, notebook_title)

    def _create_frame_with_image_and_label(self, title, img_file_name, label_text):
        frame = Gtk.Frame(label=title)
        box   = Gtk.VBox(homogeneous=False, spacing=0)
        img   = _load_image(self, img_file_name)
        img   = _load_image_constrained(self, img_file_name, -1, 100)
        label = Gtk.Label()
        label.set_markup("<span font_desc='LiberationSans 18'>%s</span>" % label_text)
        box.add(img)
        box.add(label)
        frame.add(box)
        return frame

    def create_notebook_page_sensor_information(self):
        ''' Display all the sensor used for this demo '''
        page_sensor_info = Gtk.Grid()

        frame_temp = self._create_frame_with_image_and_label(
            "%25s" % "Temperature",
            "RS1069_climate_change_light_blue.png",
            self.sensors.get_driver_name_temperature()
        )
        frame_humidity = self._create_frame_with_image_and_label(
            "%25s" % "Humidity",
            "RS1902_humidity_light_blue.png",
            self.sensors.get_driver_name_humidity()
        )
        if WITH_PRESSURE:
            frame_pressure = self._create_frame_with_image_and_label(
                "%25s" % "Pressure",
                "RS6355_FORCE_PRESSURE_light_blue.png",
                self.sensors.get_driver_name_pressure()
            )
        frame_accel = self._create_frame_with_image_and_label(
            "%25s" % "Accelerometer",
            "RS1761_MEMS_accelerometer_light_blue.png",
            self.sensors.get_driver_name_accelerometer()
        )
        if WITH_GYRO:
            frame_gyro = self._create_frame_with_image_and_label(
                "%25s" % "Gyroscope",
                 "RS1760_MEMS_gyroscope_light_blue.png",
                 self.sensors.get_driver_name_gyroscope()
            )
        #if WITH_MAGNETO:
        #    frame_magneto = self._create_frame_with_image_and_label(
        #        "%25s" % "Magnetometer",
        #        "RS1762_MEMS_compass_light_blue.png",
        #        self.sensors.get_driver_name_magnetometer()
        #    )

        page_sensor_info.set_column_spacing(2)
        page_sensor_info.set_row_spacing(2)

        page_sensor_info.attach(frame_temp, 1, 1, 3, 1)
        page_sensor_info.attach_next_to(frame_humidity, frame_temp,
                                        Gtk.PositionType.RIGHT, 1, 1)
        if WITH_PRESSURE:
            page_sensor_info.attach_next_to(frame_pressure, frame_humidity,
                                            Gtk.PositionType.RIGHT, 1, 1)
        page_sensor_info.attach_next_to(frame_accel, frame_temp,
                                        Gtk.PositionType.BOTTOM, 1, 1)
        if WITH_GYRO:
            page_sensor_info.attach_next_to(frame_gyro, frame_accel,
                                            Gtk.PositionType.RIGHT, 1, 1)
        #if WITH_MAGNETO:
        #    page_sensor_info.attach_next_to(frame_magneto, frame_gyro,
        #                                    Gtk.PositionType.RIGHT, 1, 1)

        #self.notebook.append_page(page_sensor_info,
        #                          Gtk.Image.new_from_icon_name(
        #        "dialog-information",
        #        Gtk.IconSize.MENU
        #        ))
        notebook_title =  Gtk.Label()
        notebook_title.set_markup("<span font_desc='LiberationSans 25'>Infos</span>")
        self.notebook.append_page(page_sensor_info, notebook_title)

    def create_notebook_page_exit(self):
        ''' notebook page for quitting application '''
        page = Gtk.VBox(homogeneous=False, spacing=0)
        page.set_border_width(10)
        ''' button '''
        lastbutton = Gtk.Button()
        lastbutton.connect("clicked", self.destroy)
        image_to_add = _load_image_on_button(self, "%s/RS70_ST_Logo_Qi.png" % ICON_PICTURES_PATH, "Quit", -1, 200)
        lastbutton.add(image_to_add)
        lastbutton.show()

        page.pack_start(lastbutton, True, True, 0)
        exit_label = Gtk.Label()
        exit_label.set_markup("<span font_desc='LiberationSans 25'>To exit, click on logo.</span>")
        page.pack_start(exit_label, False, False, 0)

        notebook_title =  Gtk.Label()
        notebook_title.set_markup("<span font_desc='LiberationSans 25'>EXIT</span>")

        self.notebook.append_page(page, notebook_title)
    def destroy(self, widget, data=None):
        Gtk.main_quit()

    def rearm_timer(self):
        if self.timer_enable:
            self.timer = GObject.timeout_add(TIME_UPATE, self.update_ui, None)

    def update_ui(self, user_data):
        if False == self.timer_enable:
            return False;

        # temperature
        temp = self.sensors.read_temperature()
        self._set_basic_temperature(temp)
        # humidity
        hum = self.sensors.read_humidity()
        self._set_basic_humidity(hum)
        # pressure
        if WITH_PRESSURE:
            press = self.sensors.read_pressure()
            self._set_basic_pressure(press)

        # accel
        accel = self.sensors.read_accelerometer()
        self._set_basic_accelerometer(accel[0], accel[1], accel[2])
        # gyro
        if WITH_GYRO:
            gyro = self.sensors.read_gyroscope()
            self._set_basic_gyroscope(gyro[0], gyro[1], gyro[2])
        # magneto
        #if WITH_MAGNETO:
        #    magneto = self.sensors.read_magnetometer()
        #    self._set_basic_magnetometer(magneto[0], magneto[1], magneto[2])

        # imu
        pitch, roll, yaw = self.sensors.calculate_imu(accel)
        self._set_imu_pitch(pitch)
        self._set_imu_roll(roll)
        self._set_imu_yaw(yaw)
        self._update_orientation(self.sensors.get_imu_orientation(pitch, roll))

        #print("[DEBUG] visibility: ", self.get_property("visible"))

        # As this is a timeout function, return True so that it
        # continues to get called
        return True

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# Main
if __name__ == "__main__":
    # add signal to catch CRTL+C
    import signal
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    try:
        #splScr = SplashScreen("%s/RS70_ST_Logo_Qi.png" % ICON_PICTURES_PATH, 5)
        #Gtk.main()

        win = MainUIWindow()
        win.connect("delete-event", Gtk.main_quit)
        win.show_all()
    except Exception as exc:
        print("Main Exception: ", exc )

    Gtk.main()
