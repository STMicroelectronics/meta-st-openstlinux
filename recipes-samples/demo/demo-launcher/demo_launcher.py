#!/usr/bin/python3

# Copyright (c) 2019 STMicroelectronics. All rights reserved.
#
# This software component is licensed by ST under BSD 3-Clause license,
# the "License"; You may not use this file except in compliance with the
# License. You may obtain a copy of the License at:
#                        opensource.org/licenses/BSD-3-Clause

# to debug this script:
#      python3 -m pdb ./demo_launcher.py
#
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from gi.repository import GObject
from gi.repository import Gdk
from gi.repository import GLib
from gi.repository import GdkPixbuf
from gi.repository import Pango

import yaml

import subprocess
import random
import math
import os
import glob
import socket
import fcntl
import struct
import string
import random
from collections import deque
from time import sleep, time
import threading

import importlib
#
# For simulating UI on PC , please use
# the variable SIMULATE = 1
# If SIMULATE = 1 then
#    the picture/icon must be present on pictures directory
#
SIMULATE = 0


if SIMULATE > 0:
    #DEMO_PATH = os.environ['HOME']+"/Desktop/launcher"
    DEMO_PATH = "./"
else:
    DEMO_PATH = "/usr/local/demo"

lock = threading.Lock()

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# CONSTANT VALUES
#
SIMULATE_SCREEN_SIZE_WIDTH  = 800
SIMULATE_SCREEN_SIZE_HEIGHT = 480

def popenAndCall(onExit, *popenArgs, **popenKWArgs):
    """
    Runs a subprocess.Popen, and then calls the function onExit when the
    subprocess completes.

    Use it exactly the way you'd normally use subprocess.Popen, except include a
    callable to execute as the first argument. onExit is a callable object, and
    *popenArgs and **popenKWArgs are simply passed up to subprocess.Popen.
    """
    def runInThread(onExit, popenArgs, popenKWArgs):
        process = subprocess.Popen(*popenArgs, **popenKWArgs)
        process.wait()
        onExit()
        return

    thread = threading.Thread(target=runInThread,
                              args=(onExit, popenArgs, popenKWArgs))
    thread.start()

    return thread # returns immediately after the thread starts

# -------------------------------------------------------------------
# -------------------------------------------------------------------
ICON_SIZE_720 = 180
ICON_SIZE_480 = 128
def get_screen_size_management_type(width, height):
    minsize =  min(width, height)
    if minsize == 720:
        return 720
    elif minsize == 480:
        return 480
    return 480
def get_icon_size_from_screen_size(width, height):
    minsize =  min(width, height)
    if minsize == 720:
        return ICON_SIZE_720
    elif minsize == 480:
        return ICON_SIZE_480

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# Back video view
class BackVideoWindow(Gtk.Dialog):
    def __init__(self, parent):
        Gtk.Dialog.__init__(self, "Wifi", parent, 0)
        self.previous_click_time=time()
        self.maximize()
        self.set_decorated(False)
        self.set_name("backed_bg")
        self.show_all()

# Info view
class InfoWindow(Gtk.Dialog):
    def __init__(self, parent):
        Gtk.Dialog.__init__(self, "Wifi", parent, 0)
        self.previous_click_time=time()
        self.maximize()
        self.set_decorated(False)
        self.set_name("backed_bg")

        mainvbox = self.get_content_area()

        page_info = Gtk.VBox()
        page_info.set_border_width(10)

        title = Gtk.Label()
        title.set_markup("<span font='30' color='#FFFFFFFF'><b>About the application</b></span>")
        page_info.add(title)

        label1 = Gtk.Label()
        label1.set_markup("<span font='15' color='#FFFFFFFF'>\n\nTo get control of video playback and camera preview,\nSimple tap: pause/resume\nDouble tap: exit from demos\n\nAI demo: draw character on touchscreen to launch action</span>")
        label1.set_justify(Gtk.Justification.LEFT)
        page_info.add(label1)

        mainvbox.pack_start(page_info, False, False, 3)
        self.connect("button-release-event", self.on_page_press_event)
        self.show_all()

    def on_page_press_event(self, widget, event):
        self.click_time = time()
        print(self.click_time - self.previous_click_time)
        # TODO : a fake click is observed, workaround hereafter
        if (self.click_time - self.previous_click_time) < 0.01:
            self.previous_click_time = self.click_time
        elif (self.click_time - self.previous_click_time) < 0.3:
            print ("double click")
            self.destroy()
        else:
            print ("simple click")
            self.previous_click_time = self.click_time

# -------------------------------------------------------------------
# -------------------------------------------------------------------
def _load_image_eventBox(parent, filename, label_text1, label_text2, scale_w, scale_h):
    # Create box for xpm and label
    box = Gtk.VBox(homogeneous=False, spacing=0)
    # Create an eventBox
    eventBox = Gtk.EventBox()
    # Now on to the image stuff
    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
            filename=filename,
            width=scale_w,
            height=scale_h,
            preserve_aspect_ratio=True)
    image = Gtk.Image.new_from_pixbuf(pixbuf)

    label = Gtk.Label()
    label.set_markup("<span font='15' color='#39A9DCFF'>%s\n</span>"
                     "<span font='15' color='#002052FF'>%s</span>" % (label_text1, label_text2))
    label.set_justify(Gtk.Justification.CENTER)
    label.set_line_wrap(True)

    # Pack the pixmap and label into the box
    box.pack_start(image, True, False, 0)
    box.pack_start(label, True, False, 0)

    # Add the image to the eventBox
    eventBox.add(box)

    return eventBox

def _load_image_Box(parent, mp1filename, infofilename, label_text, scale_w, scale_h):
    box = Gtk.VBox(homogeneous=False, spacing=0)
    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
            filename=mp1filename,
            width=scale_w,
            height=scale_h,
            preserve_aspect_ratio=True)
    image = Gtk.Image.new_from_pixbuf(pixbuf)

    # Create a label for the button
    label0 = Gtk.Label() #for padding
    label1 = Gtk.Label()
    label1.set_markup("<span font='14' color='#FFFFFFFF'><b>%s</b></span>\n"
                      "<span font='10' color='#FFFFFFFF'>Dual Arm&#174; Cortex&#174;-A7</span>\n"
                      "<span font='10' color='#FFFFFFFF'>+</span>\n"
                      "<span font='10' color='#FFFFFFFF'>Copro Arm&#174; Cortex&#174;-M4</span>\n" % label_text)
    label1.set_justify(Gtk.Justification.CENTER)
    label1.set_line_wrap(True)

    eventBox = Gtk.EventBox()
    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
        filename=infofilename,
        width=scale_w,
        height=(scale_h/4),
        preserve_aspect_ratio=True)
    info = Gtk.Image.new_from_pixbuf(pixbuf)
    eventBox.add(info)
    eventBox.connect("button_release_event", parent.info_event)
    eventBox.connect("button_press_event", parent.highlight_eventBox)

    label3 = Gtk.Label()
    label3.set_markup("<span font='10' color='#FFFFFFFF'><b>Python GTK launcher</b></span>\n")
    label3.set_justify(Gtk.Justification.CENTER)
    label3.set_line_wrap(True)

    # Pack the pixmap and label into the box
    box.pack_start(label0, True, False, 0)
    box.pack_start(image, True, False, 0)
    box.pack_start(label1, True, False, 0)
    box.pack_start(eventBox, True, False, 0)
    box.pack_start(label3, True, False, 0)

    return box

def _load_image_on_button(parent, filename, label_text, scale_w, scale_h):
    # Create box for xpm and label
    box = Gtk.HBox(homogeneous=False, spacing=0)
    box.set_border_width(2)
    # print("[DEBUG] image: %s " % filename)
    # Now on to the image stuff
    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
            filename=filename,
            width=scale_w,
            height=scale_h,
            preserve_aspect_ratio=True)
    image = Gtk.Image.new_from_pixbuf(pixbuf)

    # Create a label for the button
    label = Gtk.Label.new(label_text)

    # Pack the pixmap and label into the box
    box.pack_start(image, True, False, 3)

    image.show()
    label.show()
    return box
# -------------------------------------------------------------------
# -------------------------------------------------------------------
def read_board_compatibility_name():
    if SIMULATE > 0:
        return "all"
    else:
        try:
            with open("/proc/device-tree/compatible") as fp:
                string = fp.read()
                return string.split(',')[-1]
        except:
            return "all"
# -------------------------------------------------------------------
# -------------------------------------------------------------------

class ScriptWindow(Gtk.Dialog):
    def __init__(self, parent, name, script):
        Gtk.Dialog.__init__(self, name, parent, 0)

        self.maximize()
        self.set_decorated(False)
        self.set_name("transparent_bg")

        self.previous_click_time=time()
        self.stream_is_paused=0
        self.script_is_started=False

        self.connect("button-press-event", self.on_script_press_event)
        self.process_pipe_read, self.process_pipe_write =  os.pipe()
        cmd = [os.path.join(DEMO_PATH,script)]
        self.proc = popenAndCall(self.on_script_on_exit, cmd, stdin =self.process_pipe_read, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)

    def on_script_on_exit(self):
        if self:
            self.destroy()

    def on_script_press_event(self, widget, event):
        self.click_time = time()
        print("click delay: ", self.click_time - self.previous_click_time)
        if (self.click_time - self.previous_click_time) > 3:
            self.script_is_started=True
        if (self.script_is_started):
            # TODO : a fake click is observed, workaround hereafter
            if (self.click_time - self.previous_click_time) < 0.01:
                self.previous_click_time = self.click_time
            elif (self.click_time - self.previous_click_time) < 0.3:
                print("double click", self.click_time - self.previous_click_time)
                os.write(self.process_pipe_write, b"q")
                os.close(self.process_pipe_write)
                self.destroy()
            else:
                self.previous_click_time = self.click_time
                os.write(self.process_pipe_write, b"p")
                if (self.stream_is_paused == 1):
                    self.stream_is_paused = 0
                else:
                    self.stream_is_paused = 1

# -------------------------------------------------------------------
# -------------------------------------------------------------------

def import_module_by_name(module_name):
    ''' module example:0application.netdata.netdata
        (corresponding to application/netdata/netdata.py file)
    '''
    try:
        print("[DEBUG] module_name=>%s<" % module_name)
        imported = importlib.import_module(module_name)
    except Exception as e:
        print("Module Load, error: ", e)
        return None
    return imported

class ApplicationButton():
    def __init__(self, parent, yaml_file, icon_size):
        self.event_box = None
        self.yaml_configuration = None
        self.icon_size = icon_size
        self._parent = parent
        self._compatible = True

        with open(yaml_file) as fp:
            self.yaml_configuration = yaml.load(fp, Loader=yaml.FullLoader)
        #print(self.yaml_configuration)
        #print("Name ", self.yaml_configuration["Application"]["Name"])

        if self.yaml_configuration:
            # check board if it's compatible
            if (self._is_compatible(self.yaml_configuration["Application"]["Board"])):
                self._compatible = True
                self.event_box = _load_image_eventBox(self, "%s/%s" % (DEMO_PATH, self.yaml_configuration["Application"]["Icon"]),
                                                  self.yaml_configuration["Application"]["Name"],
                                                  self.yaml_configuration["Application"]["Description"],
                                                  -1, self.icon_size)
                if (self.yaml_configuration["Application"]["Type"].rstrip() == "script"):
                    self.event_box.connect("button_release_event", self.script_handle)
                    self.event_box.connect("button_press_event", self._parent.highlight_eventBox)
                elif (self.yaml_configuration["Application"]["Type"].rstrip() == "python"):
                    self.event_box.connect("button_release_event", self.python_start)
                    self.event_box.connect("button_press_event", self._parent.highlight_eventBox)
            else:
                self._compatible = False
                print("     %s NOT compatible" % self.yaml_configuration["Application"]["Name"])


    def is_exist(self, data):
        try:
            #print("[DEBUG][is_exist] ", data)
            if (data):
                for masterkey in data:
                    #print("[DEBUG][is_exist] key available: ", masterkey)
                    if masterkey == "Exist":
                        for key in data["Exist"]:
                            #print("[DEBUG][is_exist] key detected: %s" % key)
                            if key == "File" and len(data["Exist"]["File"].rstrip()):
                                if (os.path.exists(data["Exist"]["File"].rstrip())):
                                    return True
                                else:
                                    return False
                            elif (key == "Command" and len(data["Exist"]["Command"].rstrip())):
                                retcode = subprocess.call(data["Exist"]["Command"].rstrip(), shell=True);
                                if (int(retcode) == 0):
                                    return True
                                else:
                                    return False
                return True
            else:
                return True
        except:
            print("is_exist exception return true")
            return True

    def exist_MSG_present(self, data):
        try:
            #print("[DEBUG][is_exist] ", data)
            if (data):
                for masterkey in data:
                    #print("[DEBUG][is_exist] key available: ", masterkey)
                    if masterkey == "Exist":
                        for key in data["Exist"]:
                            #print("[DEBUG][is_exist] key detected: %s" % key)
                            if key == "Msg_false" and len(data["Exist"]["Msg_false"].rstrip()):
                                return True
                return False
        except:
            return False


    def is_compatible(self):
        return self._compatible
    def _is_compatible(self, data):
        board_compatibility_name = read_board_compatibility_name()
        try:
            if (data):
                for key in data:
                    if key == "List" and len(data["List"].rstrip()):
                        if data["List"].find('all') > -1:
                            return True
                        if data["List"].find(board_compatibility_name) > -1:
                            return True
                        return False
                    elif key == "NotList" and len(data["NotList"].rstrip()):
                        if data["NotList"].find(board_compatibility_name):
                            return False
                        return True
            else:
                return True
        except Exception as e:
            print("is_compatible exception return true ", e)
            return True
        return True

    def get_event_box(self):
        return self.event_box

    def python_start(self, widget, event):
        print("Python module =>", self.yaml_configuration["Application"]["Python"]["Module"], "<<<")
        if (self.is_exist(self.yaml_configuration["Application"]["Python"])):
            if (self.yaml_configuration["Application"]["Python"]["Module"] and
                len(self.yaml_configuration["Application"]["Python"]["Module"].rstrip()) > 0):
                module_imported = import_module_by_name(self.yaml_configuration["Application"]["Python"]["Module"].rstrip())
                if (module_imported):
                    print("[Python_event start]")
                    module_imported.create_subdialogwindow(self._parent)
                    print("[Python_event stop]\n")
                    widget.set_name("transparent_bg")
                    self._parent.button_exit.show()
        elif (self.exist_MSG_present(self.yaml_configuration["Application"]["Python"])):
            print("[WARNING] %s not detected\n" % self.yaml_configuration["Application"]["Python"]["Exist"]["Msg_false"])
            self._parent.display_message("<span font='15' color='#FFFFFFFF'>%s\n</span>" % self.yaml_configuration["Application"]["Python"]["Exist"]["Msg_false"])
        widget.set_name("transparent_bg")
        self._parent.button_exit.show()

    def script_start(self):
        global lock
        with lock:
            print("Lock Acquired")
            backscript_window = BackVideoWindow(self._parent)
            backscript_window.show_all()

            print("[DEBUG][ApplicationButton][script_handle]:")
            print("    Name: ", self.yaml_configuration["Application"]["Name"])
            print("    Start script: ", self.yaml_configuration["Application"]["Script"]["Start"])

            script_window = ScriptWindow(self._parent, self.yaml_configuration["Application"]["Name"], self.yaml_configuration["Application"]["Script"]["Start"])
            script_window.show_all()
            response = script_window.run()
            script_window.destroy()
            backscript_window.destroy()
            print("Lock Released")

    def script_handle(self, widget, event):
        if (self.is_exist(self.yaml_configuration["Application"]["Script"])):
            print("Acquiring lock")
            self.script_start()

        elif (self.exist_MSG_present(self.yaml_configuration["Application"]["Script"])):
            print("[WARNING] %s not detected\n" % self.yaml_configuration["Application"]["Script"]["Exist"]["Msg_false"])
            self._parent.display_message("<span font='15' color='#FFFFFFFF'>%s\n</span>" % self.yaml_configuration["Application"]["Script"]["Exist"]["Msg_false"])

        print("[script_event stop]\n")
        widget.set_name("transparent_bg")
        self._parent.button_exit.show()


# -------------------------------------------------------------------
# -------------------------------------------------------------------
def gtk_style():
        css = b"""

.widget .grid .label {
    background-color: rgba (100%, 100%, 100%, 1.0);
}
.textview {
    color: gray;
}
#normal_bg {
    background-color: rgba (100%, 100%, 100%, 1.0);
}

#transparent_bg {
    background-color: rgba (0%, 0%, 0%, 0.0);
}
#highlight_bg {
    background-color: rgba (0%, 0%, 0%, 0.1);
}
#logo_bg {
    background-color: rgba (31%, 32%, 31%, 1.0);
}
#backed_bg {
    background-color: rgba (31%, 32%, 31%, 0.8);
}

        """
        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(css)

        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

# -------------------------------------------------------------------
# -------------------------------------------------------------------
class MainUIWindow(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Demo Launcher")
        self.set_decorated(False)
        gtk_style()
        if SIMULATE > 0:
            self.screen_width = SIMULATE_SCREEN_SIZE_WIDTH
            self.screen_height = SIMULATE_SCREEN_SIZE_HEIGHT
        else:
            #self.fullscreen()
            self.maximize()
            try:
                display = Gdk.Display.get_default()
                monitor = display.get_primary_monitor()
                geometry = monitor.get_geometry()
                scale_factor = monitor.get_scale_factor()
                self.screen_width = scale_factor * geometry.width
                self.screen_height = scale_factor * geometry.height
            except:
                self.screen_width = self.get_screen().get_width()
                self.screen_height = self.get_screen().get_height()

        self.board_name = "STM32MP board"

        self.icon_size = get_icon_size_from_screen_size(self.screen_width, self.screen_height)

        self.set_default_size(self.screen_width, self.screen_height)
        print("[DEBUG] screen size: %dx%d" % (self.screen_width, self.screen_height))
        self.set_position(Gtk.WindowPosition.CENTER)
        self.connect('destroy', Gtk.main_quit)

        self.previous_click_time=time()

        self.application_file = os.path.join(DEMO_PATH,"./application/application.yaml.saved")
        self.application_path = os.path.join(DEMO_PATH,"./application/")

        # page for basic information
        self.create_page_icon_autodetected()

    def display_message(self, message):
        dialog = Gtk.Dialog("Error", self, 0, (Gtk.STOCK_OK, Gtk.ResponseType.OK))
        dialog.set_decorated(False)
        width, height = self.get_size()
        dialog.set_default_size(width, height)
        dialog.set_name("backed_bg")

        label0 = Gtk.Label() #for padding

        label1 = Gtk.Label()
        label1.set_markup(message)
        label1.set_justify(Gtk.Justification.CENTER)
        label1.set_line_wrap(True)

        label2 = Gtk.Label() #for padding

        # Create a centering alignment object
        align = Gtk.Alignment()
        align.set(0.5, 0, 0, 0)

        dialog.vbox.pack_start(label0, True, False, 0)
        dialog.vbox.pack_start(label1, True, True,  0)
        dialog.vbox.pack_start(align,  True, True,  0)
        dialog.vbox.pack_start(label2, True, False, 0)

        dialog.action_area.reparent(align)
        dialog.show_all()

        dialog.run()
        print("INFO dialog closed")

        dialog.destroy()


    def info_event(self, widget, event):
        print("[info_event start]");
        info_window = InfoWindow(self)
        info_window.show_all()
        response = info_window.run()
        info_window.destroy()
        print("[info_event stop]\n");
        widget.set_name("transparent_bg")
        self.button_exit.show()


    # Button event of main screen
    def highlight_eventBox(self, widget, event):
        ''' highlight the eventBox widget '''
        print("[highlight_eventBox start]")
        widget.set_name("highlight_bg")
        self.button_exit.hide()
        print("[highlight_eventBox stop]\n")

    def create_page_icon_autodetected(self):
        self.yaml_application_list = None
        self.application_list = []
        self.application_eventbox_list = []
        self.application_start_previous = 0
        self.application_start_next = 0
        self.application_end = 0

        self.page_main = Gtk.HBox(homogeneous=False, spacing=0)
        self.page_main.set_border_width(0)

        # create a grid of icon
        self.icon_grid = Gtk.Grid(column_homogeneous=True, row_homogeneous=True)
        self.icon_grid.set_column_spacing(20)
        self.icon_grid.set_row_spacing(20)

        # STM32MP1 Logo and info area
        self.logo_info_area = _load_image_Box(self, "%s/pictures/ST11249_Module_STM32MP1_alpha.png" % DEMO_PATH, "%s/pictures/ST13340_Info_white.png" % DEMO_PATH, self.board_name, -1, 160)
        self.logo_info_area.set_name("logo_bg")
        self.icon_grid.attach(self.logo_info_area, 3, 0, 1, 2)

        self.back_box = self.create_eventbox_back_next(1)
        self.next_box = self.create_eventbox_back_next(0)

        number_of_application = 0
        for file in sorted(os.listdir(self.application_path)):
            if os.path.isfile(os.path.join(self.application_path, file)) and file.endswith(".yaml"):
                print("[DEBUG] create event box for ", file)
                application_button = ApplicationButton(self, os.path.join(self.application_path, file), self.icon_size)
                if application_button.is_compatible():
                    self.application_list.append(os.path.join(self.application_path, file))
                    self.application_eventbox_list.append(application_button.get_event_box())
                number_of_application = number_of_application + 1
        print("[DEBUG] there is %d application(s) detected " % number_of_application)
        if number_of_application == 0:
            self.set_default_size(self.screen_width, self.screen_height)
            self.display_message("<span font='15' color='#FFFFFFFF'>There is no application detected\n</span>")
            self.destroy()

        self.application_end = len(self.application_list)

        #print("[DEBUG] application list:\n", self.application_list)
        self.create_page_icon_by_page(0)
        self.page_main.add(self.icon_grid)

        overlay = Gtk.Overlay()
        overlay.add(self.page_main)
        self.button_exit = Gtk.Button()
        self.button_exit.connect("clicked", Gtk.main_quit)
        self.button_exit_image = _load_image_on_button(self, "%s/pictures/close_70x70_white.png" % DEMO_PATH, "Exit", -1, 50)
        self.button_exit.set_halign(Gtk.Align.END)
        self.button_exit.set_valign(Gtk.Align.START)
        self.button_exit.add(self.button_exit_image)
        self.button_exit.set_relief(Gtk.ReliefStyle.NONE)
        overlay.add_overlay(self.button_exit)
        self.add(overlay)

        self.show_all()

    def create_page_icon_by_page(self, app_start):
        '''
            --------------------------------------------------------------
            |  0,0: app1 |  1,0: app2 |  2,0: app2 |  3,0: information   |
            --------------------------------------------------------------
            |  0,1: app1 |  1,1: app2 |  2,1: app2 |  3,1: information   |
            --------------------------------------------------------------
            '''
        for ind in range(0,self.application_end):
            if (self.application_eventbox_list[ind]):
                self.icon_grid.remove(self.application_eventbox_list[ind])
        self.icon_grid.remove(self.back_box)
        self.icon_grid.remove(self.next_box)

        #print("[ICON DEBUG] app_start ", app_start)
        # calculate next and previous
        if app_start > 0:
            if (app_start % 5) == 0:
                self.application_start_previous = app_start - 5
            else:
                self.application_start_previous = app_start - 4
            if self.application_start_previous < 0:
                self.application_start_previous = 0
            self.application_start_next = app_start + 4
        else:
            self.application_start_previous = 0
            self.application_start_next = 5
        #print("[ICON DEBUG] previous ", self.application_start_previous)
        #print("[ICON DEBUG] next ", self.application_start_next)

        if app_start != 0:
            ''' add previous button '''
            index = app_start
            # 0, 0
            self.icon_grid.attach(self.back_box, 0, 0, 1, 1)
            # 1, 0
            if self.application_eventbox_list[index]:
                self.icon_grid.attach(self.application_eventbox_list[index], 1, 0, 1, 1)
            index = index + 1
        else:
            index = app_start
            self.application_start_previous = app_start - 4
            if self.application_start_previous < 0:
                self.application_start_previous = 0
            # 0, 0
            if self.application_eventbox_list[index]:
                self.icon_grid.attach(self.application_eventbox_list[index], 0, 0, 1, 1)
            index = index + 1
            # 1, 0
            if (index < self.application_end) and self.application_eventbox_list[index]:
                self.icon_grid.attach(self.application_eventbox_list[index], 1, 0, 1, 1)
            else:
                self.icon_grid.show_all()
                return
            index = index + 1
        # 2, 0
        if (index < self.application_end) and self.application_eventbox_list[index]:
            self.icon_grid.attach(self.application_eventbox_list[index], 2, 0, 1, 1)
        else:
            self.icon_grid.show_all()
            return
        index = index + 1
        # 0, 1
        if (index < self.application_end) and self.application_eventbox_list[index]:
            self.icon_grid.attach(self.application_eventbox_list[index], 0, 1, 1, 1)
        else:
            self.icon_grid.show_all()
            return
        index = index + 1
        # 1, 1
        if (index < self.application_end) and self.application_eventbox_list[index]:
            self.icon_grid.attach(self.application_eventbox_list[index], 1, 1, 1, 1)
        else:
            self.icon_grid.show_all()
            return
        index = index + 1
        # 2, 1
        if ((index+1) < self.application_end) and self.application_eventbox_list[index]:
            ''' add next button '''
            self.icon_grid.attach(self.next_box, 2, 1, 1, 1)
        else:
            if (index < self.application_end) and self.application_eventbox_list[index]:
                self.icon_grid.attach(self.application_eventbox_list[index], 2, 1, 1, 1)
        self.icon_grid.show_all()


    def create_eventbox_back_next(self,back):
        if back > 0:
            back_eventbox = _load_image_eventBox(self, "%s/pictures/ST10261_back_button_medium_grey.png" % DEMO_PATH, "BACK", "menu", -1, self.icon_size)
            back_eventbox.connect("button_release_event", self.on_back_menu_event)
            back_eventbox.connect("button_press_event", self.highlight_eventBox)
            return back_eventbox
        else:
            next_eventbox = _load_image_eventBox(self, "%s/pictures/ST10261_play_button_medium_grey.png" % DEMO_PATH, "NEXT", "menu", -1, self.icon_size)
            next_eventbox.connect("button_release_event", self.on_next_menu_event)
            next_eventbox.connect("button_press_event", self.highlight_eventBox)
            return next_eventbox

    def on_back_menu_event(self, widget, event):
        self.create_page_icon_by_page(self.application_start_previous)
        widget.set_name("normal_bg")
        widget.set_name("transparent_bg")
        self.button_exit.show()
    def on_next_menu_event(self, widget, event):
        self.create_page_icon_by_page(self.application_start_next)
        widget.set_name("normal_bg")
        widget.set_name("transparent_bg")
        self.button_exit.show()

# -------------------------------------------------------------------
# Managment of lock file to have only excution of this script as same time
lock_handle = None
lock_file_path = '/var/lock/demo_launcher.lock'

def file_is_locked(file_path):
    global lock_handle
    lock_handle= open(file_path, 'w')
    try:
        fcntl.lockf(lock_handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return False
    except IOError:
        return True

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# Main
if __name__ == "__main__":
    # add signal to catch CRTL+C
    import signal
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    if file_is_locked(lock_file_path):
        print("[ERROR] another instance is running exiting now\n")
        exit(0)
    try:
        win = MainUIWindow()
        win.connect("delete-event", Gtk.main_quit)
        win.show_all()
        Gtk.main()
    except Exception as exc:
        print("Main Exception: ", exc )

