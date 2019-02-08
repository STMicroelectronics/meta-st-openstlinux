#!/usr/bin/python3

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from gi.repository import GObject
from gi.repository import Gdk
import cairo

import random
import math
from collections import deque
import os

#for testing on PC without sensors, put REAL to 0
MAKE_REAL_MESUREMENT = 1

NUM_SAMPLES = 112
HMARGIN = 20
VMARGIN = 10
CHARTHEIGHT = 40

GRAPH_V_PADDING = 4
GRAPH_H_PADDING = 4

#TIME_UPATE = 5000
TIME_UPATE = 1000


# example of orientation
# https://github.com/hadess/iio-sensor-proxy/blob/master/src/test-orientation-gtk.c
ORIENTATION_UNDEFINED   = 0
ORIENTATION_NORMAL      = 1
ORIENTATION_BOTTOM_UP   = 2
ORIENTATION_LEFT_UP     = 3
ORIENTATION_RIGHT_UP    = 4

def _load_image_on_button(parent, filename, label_text):
    # Create box for xpm and label
    box1 = Gtk.HBox(False, 0)
    box1.set_border_width(2)
    # Now on to the image stuff
    image = Gtk.Image()
    image.set_from_file(filename)

    # Create a label for the button
    label = Gtk.Label(label_text)

    # Pack the pixmap and label into the box
    box1.pack_start(image, True, False, 3)
    #box1.pack_start(label, False, False, 3)

    image.show()
    label.show()
    return box1

class SensorWindow(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Temperature/Humidity")
        if MAKE_REAL_MESUREMENT > 0:
            self.fullscreen()
            #self.maximize()
            screen_width = self.get_screen().get_width()
            screen_height = 600
        else:
            screen_width = 400
            screen_height = 600

        self.temperature_prefix_path = self.found_iio_device("in_temp_raw")
        self.humidity_prefix_path = self.found_iio_device("in_humidityrelative_raw")
        self.accelerometer_prefix_path = self.found_iio_device("in_accel_x_raw")

        #screen_height = self.get_screen().get_height()

        self.set_default_size(screen_width, screen_height)

        # current, Max, Min
        self.temperature_max = 0.0
        self.temperature_min = 35.0
        self.humidity_max = 0.0
        self.humidity_min = 35.0

        '''
            0: "undefined"
            1: "normal"
            2: "bottom-up",
            3: "left-up",
            4: "right-up",
        '''
        self.previous_orientation = ORIENTATION_UNDEFINED

        ''' TreeView '''
        self.liststore = Gtk.ListStore(str, str, str, str)
        self.temperature_store = self.liststore.append([ "Temperature", "0.0", "0.0", "0.0" ])
        self.humidity_store = self.liststore.append([ "Humidity", "0.0", "0.0", "0.0" ])
        self.accel_store = self.liststore.append([ "Accelerometer", "0.0", "0.0", "0.0" ])

        self.treeview = Gtk.TreeView(model=self.liststore)

        renderer_text = Gtk.CellRendererText()
        column_text = Gtk.TreeViewColumn("Sensor", renderer_text, text=0)
        self.treeview.append_column(column_text)

        renderer_current = Gtk.CellRendererText()
        column_cur = Gtk.TreeViewColumn("Current", renderer_current, text=1)
        self.treeview.append_column(column_cur)

        renderer_max = Gtk.CellRendererText()
        column_max = Gtk.TreeViewColumn("Max", renderer_max, text=2)
        self.treeview.append_column(column_max)

        renderer_min = Gtk.CellRendererText()
        column_min = Gtk.TreeViewColumn("Min", renderer_min, text=3)
        self.treeview.append_column(column_min)

        # Add a timer callback to update
        # this takes 2 args: (how often to update in millisec, the method to run)
        self.timer = GObject.timeout_add(TIME_UPATE, self.update_ui, None)

        ''' DrawView '''
        self.drawarea = Gtk.DrawingArea()

        self.drawing_area_width = screen_width
        self.drawing_area_height = screen_height/2

        self.drawarea.set_size_request(self.drawing_area_width, self.drawing_area_height)
        self.drawarea.connect("draw", self._draw_event)
        self._axis_ranges = {}  # {axis_num: [min_seen, max_seen]}
        self._axis_values = {}  # {axis_num: deque([val0, ..., valN])}

        ''' spinner '''
        # add scale
        grid_scale_hor = Gtk.Grid()
        grid_scale_hor.set_column_spacing(10)
        grid_scale_hor.set_column_homogeneous(True)

        self.x_adj = Gtk.Adjustment(0, -256, 256, 2, 2, 0)
        self.x_scale = Gtk.Scale(orientation=Gtk.Orientation.VERTICAL)
        self.x_scale.set_orientation(Gtk.Orientation.VERTICAL)
        self.x_scale.set_adjustment(self.x_adj)
        self.x_scale.set_digits(0)
        self.x_scale.set_draw_value(True)
        self.x_scale.set_vexpand(True)
        grid_scale_hor.attach(self.x_scale, 0, 0, 1, 1)

        self.y_adj = Gtk.Adjustment(0, -256, 256, 2, 2, 0)
        self.y_scale = Gtk.Scale()
        self.y_scale.set_orientation(Gtk.Orientation.VERTICAL)
        self.y_scale.set_adjustment(self.y_adj)
        self.y_scale.set_digits(0)
        self.y_scale.set_draw_value(True)
        self.y_scale.set_vexpand(True)
        grid_scale_hor.attach_next_to(self.y_scale, self.x_scale, Gtk.PositionType.RIGHT, 1, 1)

        self.z_adj = Gtk.Adjustment(0.0, -256.0, 256.0, 2.0, 2.0, 0.0)
        self.z_scale = Gtk.Scale()
        self.z_scale.set_orientation(Gtk.Orientation.VERTICAL)
        self.z_scale.set_adjustment(self.z_adj)
        self.z_scale.set_digits(0)
        self.z_scale.set_draw_value(True)
        self.z_scale.set_vexpand(True)
        grid_scale_hor.attach_next_to(self.z_scale, self.y_scale, Gtk.PositionType.RIGHT, 1, 1)

        self.orientation = Gtk.Label("Orientation")
        #grid_scale_hor.attach_next_to(self.orientation, self.z_scale, Gtk.PositionType.RIGHT, 1, 1)
        grid_scale_hor.attach(self.orientation, 0, 1, 2, 1)

        ''' button '''
        lastbutton = Gtk.Button()
        lastbutton.connect("clicked", self.destroy)
        if MAKE_REAL_MESUREMENT > 0:
            image_to_add = _load_image_on_button(self, "/home/root/stlogo.png", "Quit")
        else:
            image_to_add = _load_image_on_button(self, "./stlogo.png", "Quit")
        lastbutton.add(image_to_add)
        lastbutton.show()

        """
        UI:
            ---------------------------------------------------
            |                              |                   |
            |  DrawingArea with two graph  |    Treeview       |
            |                              |                   |
            ---------------------------------------------------
            |                              |                   |
            | Spinner for accelerometer    |  Button with      |
            |                              |   ST image        |
            ---------------------------------------------------
        """
        box_outer = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
        self.add(box_outer)

        # to activate draw area
        boxdraw_vert = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        boxdraw_vert.pack_start(self.drawarea, False, True, 0)
        boxdraw_vert.pack_start(grid_scale_hor, True, True, 0)

        box_outer.pack_start(boxdraw_vert, False, True, 0)

        box_vert = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)

        self.tree_frame = Gtk.Frame(label="Temperature & Humidity")
        box_vert.pack_start(self.tree_frame, True, True, 0)
        self.tree_frame.add(self.treeview)

        box_vert.pack_start(lastbutton, True, True, 0)

        box_outer.pack_start(box_vert, True, True, 0)

    def destroy(self, widget, data=None):
        Gtk.main_quit()

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

    def _draw_cb(self, drawingarea, ctx):
        width = self.drawing_area_width
        height = self.drawing_area_height

        axis_ids = set(self._axis_ranges.keys())
        axis_ids.intersection_update(set(self._axis_values.keys()))
        for i in sorted(axis_ids):
            if i == 1:
                # temperature value

                #draw rectangle
                ctx.set_source_rgb(0.8, 0.8, 0.8)
                ctx.rectangle(0, 0, width, height/2)
                ctx.fill()

                #draw axes
                ctx.set_source_rgb(0, 1, 1)
                ctx.move_to(30 + 0.5, height/4)
                ctx.line_to(width - 0.5, height/4)
                ctx.stroke()

                # value (text)
                ctx.select_font_face("sans-serif")
                ctx.set_font_size(20.0)
                ctx.set_source_rgb(0, 0, 0)
                ctx.move_to(0, 20)
                ctx.show_text("T (°C)")
                ctx.set_font_size(10.0)
                ctx.move_to(0, height/4 + 4)
                ctx.show_text("20 °C")
                # temperateure between 0 and 40
                values = self._axis_values[i]
                ctx.set_source_rgb(0, 0, 0)
                for x, v in enumerate(values):
                    val = 30 + x*GRAPH_H_PADDING
                    ctx.move_to(val, height/2)
                    ctx.line_to(val, (40.0 - v) * height/80)
                    ctx.stroke()

            if i == 2:
                # Humidity values

                offset = 10
                #draw rectangle
                ctx.set_source_rgb(0.8, 0.8, 0.8)
                ctx.rectangle(0, height/2 + offset, width, height/2)
                ctx.fill()

                #draw axes
                ctx.set_source_rgb(0, 1, 1)
                ctx.move_to(25 + 0.5, height/2 + offset + height/4)
                ctx.line_to(width - 0.5, height/2 + offset + height/4)
                ctx.stroke()

                # value (text)
                ctx.select_font_face("sans-serif")
                ctx.set_font_size(20.0)
                ctx.set_source_rgb(0, 0, 0)
                ctx.move_to(0, height/2 + offset + 20)
                ctx.show_text("H (%)")
                ctx.set_font_size(10.0)
                ctx.set_source_rgb(0, 0, 0)
                ctx.move_to(0, height/2 + offset + height/4 + 4)
                ctx.show_text("50 %")

                values = self._axis_values[i]
                ctx.set_source_rgb(0, 0, 0)
                for x, v in enumerate(values):
                    val = 25 + x*GRAPH_H_PADDING
                    ctx.move_to(val, height/2 + offset + height/2)
                    ctx.line_to(val, height/2 + offset + (100.0 - v) * height/200)
                    ctx.stroke()
        return False

    def _orientation_calc(self, x, y, z):
        rotation = round( math.atan(x / math.sqrt(y * y + z * z)) * 180.0 * math.pi)
        if abs(rotation) > 35:
            ''' (rotation > 0) ? ORIENTATION_LEFT_UP : ORIENTATION_RIGHT_UP;'''
            if self.previous_orientation == ORIENTATION_LEFT_UP or self.previous_orientation == ORIENTATION_NORMAL:
                if abs(rotation) < 5:
                    self.update_movement(self.previous_orientation)
            else:
                if rotation > 0:
                    self.update_movement(ORIENTATION_LEFT_UP)
                else:
                    self.update_movement(ORIENTATION_RIGHT_UP)
        else:
            rotation = round( math.atan(y / math.sqrt(x * x + z * z)) * 180.0 * math.pi)
            if abs(rotation) > 35:
                '''ret = (rotation > 0) ? ORIENTATION_BOTTOM_UP : ORIENTATION_NORMAL;'''
                if self.previous_orientation == ORIENTATION_BOTTOM_UP or self.previous_orientation == ORIENTATION_NORMAL:
                    if abs(rotation) < 5:
                        self.update_movement(self.previous_orientation)
                else:
                    if rotation > 0:
                        self.update_movement(ORIENTATION_BOTTOM_UP)
                    else:
                        self.update_movement(ORIENTATION_NORMAL)

    def orientation_calc(self, x, y, z):
        rotation = round( math.atan(x / math.sqrt(y * y + z * z)) * 180.0 * math.pi)

        if abs(rotation) > 35:
            ''' (rotation > 0) ? ORIENTATION_LEFT_UP : ORIENTATION_RIGHT_UP;'''
            if rotation > 0:
                self.update_movement(ORIENTATION_LEFT_UP)
            else:
                self.update_movement(ORIENTATION_RIGHT_UP)
        else:
            rotation = round( math.atan(y / math.sqrt(x * x + z * z)) * 180.0 * math.pi)
            if abs(rotation) > 35:
                '''ret = (rotation > 0) ? ORIENTATION_BOTTOM_UP : ORIENTATION_NORMAL;'''
                if rotation > 0:
                    self.update_movement(ORIENTATION_BOTTOM_UP)
                else:
                    self.update_movement(ORIENTATION_NORMAL)

    def udate_temperature(self, cur_val):
        self.liststore[self.temperature_store][1] = '%.2f' % cur_val
        if cur_val > self.temperature_max:
            self.temperature_max = cur_val
        if cur_val < self.temperature_min:
            self.temperature_min = cur_val
        self.liststore[self.temperature_store][2] = '%.2f' % self.temperature_max
        self.liststore[self.temperature_store][3] = '%.2f' % self.temperature_min

        ''' for drawing '''
        values = self._axis_values.get(1, None)
        if values is None:
            values = deque(maxlen=NUM_SAMPLES)
            self._axis_values[1] = values
        if len(list(values)) > (NUM_SAMPLES - 1):
            values. popleft()
        values.append(cur_val)
        self._axis_ranges[1] = (0.0, 60.0)

        #print("TEMPERATURE: cur_val = %0.2f Max: %0.2f" % (cur_val, self.temperature_max))
        #print(self.liststore[self.temperature_store][0:])

    def udate_humidity(self, cur_val):
        self.liststore[self.humidity_store][1] = '%.2f' % cur_val
        if cur_val > self.humidity_max:
            self.humidity_max = cur_val
        if cur_val < self.humidity_min:
            self.humidity_min = cur_val
        self.liststore[self.humidity_store][2] = '%.2f' % self.humidity_max
        self.liststore[self.humidity_store][3] = '%.2f' % self.humidity_min

        ''' for drawing '''
        values = self._axis_values.get(2, None)
        if values is None:
            values = deque(maxlen=NUM_SAMPLES)
            self._axis_values[2] = values
        values.append(cur_val)
        self._axis_ranges[2] = (0.0, 60.0)

    def update_accel(self, x, y, z):
        self.liststore[self.accel_store][1] = '%d' % x
        self.liststore[self.accel_store][2] = '%d' % y
        self.liststore[self.accel_store][3] = '%d' % z
        self.x_adj.set_value(x)
        self.y_adj.set_value(y)
        self.z_adj.set_value(z)

    def update_movement(self, m):
        self.previous_orientation = m
        if m == ORIENTATION_UNDEFINED:
            self.orientation.set_text("undefined")
        elif m == ORIENTATION_NORMAL:
            self.orientation.set_text("normal")
        elif m == ORIENTATION_BOTTOM_UP:
            self.orientation.set_text("bottom-up")
        elif m == ORIENTATION_LEFT_UP:
            self.orientation.set_text("left-up")
        elif m == ORIENTATION_RIGHT_UP:
            self.orientation.set_text("right-up")
        else:
            self.orientation.set_text("undefined")

    def read_temperature(self):
        offset = 0.0
        raw = 0.0
        scale = 0.0
        temp = 0.0
        if MAKE_REAL_MESUREMENT > 0:
            if self.temperature_prefix_path:
                with open(self.temperature_prefix_path + 'in_temp_offset', 'r') as f:
                    offset = float(f.read())
                with open(self.temperature_prefix_path + 'in_temp_raw', 'r') as f:
                    raw = float(f.read())
                with open(self.temperature_prefix_path + 'in_temp_scale', 'r') as f:
                    scale = float(f.read())
                temp = (offset + raw) * scale
                self.udate_temperature(temp)
            else:
                # randomly generated
                self.udate_temperature(random.uniform(18.0, 35.0))
        else:
            # randomly generated
            self.udate_temperature(random.uniform(18.0, 35.0))

    def read_humidity(self):
        offset = 0.0
        raw = 0.0
        scale = 0.0
        temp = 0.0
        if MAKE_REAL_MESUREMENT > 0:
            if self.humidity_prefix_path:
                with open(self.humidity_prefix_path + 'in_humidityrelative_offset', 'r') as f:
                    offset = float(f.read())
                with open(self.humidity_prefix_path + 'in_humidityrelative_raw', 'r') as f:
                    raw = float(f.read())
                with open(self.humidity_prefix_path + 'in_humidityrelative_scale', 'r') as f:
                    scale = float(f.read())
                temp = (offset + raw) * scale
                self.udate_humidity(temp)
            else:
                # randomly generated
                self.udate_humidity(random.uniform(18.0, 35.0))
        else:
            # randomly generated
            self.udate_humidity(random.uniform(18.0, 35.0))

    def read_accel(self):
        raw = 0.0
        scale = 0.0
        in_x = 0.0
        in_y = 0.0
        in_z = 0.0
        if MAKE_REAL_MESUREMENT > 0:
            if self.accelerometer_prefix_path:
                with open(self.accelerometer_prefix_path + 'in_accel_x_raw', 'r') as f:
                    scale = float(f.read())
                with open(self.accelerometer_prefix_path + 'in_accel_x_scale', 'r') as f:
                    raw = float(f.read())
                in_x = int(raw * scale * 256.0 / 9.81)
                with open(self.accelerometer_prefix_path + 'in_accel_y_raw', 'r') as f:
                    scale = float(f.read())
                with open(self.accelerometer_prefix_path + 'in_accel_y_scale', 'r') as f:
                    raw = float(f.read())
                in_y = int(raw * scale * 256.0 / 9.81)
                with open(self.accelerometer_prefix_path + 'in_accel_z_raw', 'r') as f:
                    scale = float(f.read())
                with open(self.accelerometer_prefix_path + 'in_accel_z_scale', 'r') as f:
                    raw = float(f.read())
                in_z = int(raw * scale * 256.0 / 9.81)
                self.update_accel(in_x, in_y, in_z)
            else:
                in_x = random.randint(-256, 256)
                in_y = random.randint(-256, 256)
                in_z = random.randint(-256, 256)
                self.update_accel(in_x, in_y, in_z)
        else:
            in_x = random.randint(-256, 256)
            in_y = random.randint(-256, 256)
            in_z = random.randint(-256, 256)
            self.update_accel(in_x, in_y, in_z)

        self.orientation_calc(in_x, in_y, in_z)

    def _draw_event(self, drawingarea, user_data):
        win = self.drawarea.get_window()
        ctx = win.cairo_create()
        self._draw_cb(win, ctx)

    def update_ui(self, user_data):
        self.read_temperature()
        self.read_humidity()
        self.read_accel()

        win = self.drawarea.get_window()
        ctx = win.cairo_create()
        self._draw_cb(win, ctx)

        # As this is a timeout function, return True so that it
        # continues to get called
        return True

win = SensorWindow()
win.connect("delete-event", Gtk.main_quit)
win.show_all()
Gtk.main()
