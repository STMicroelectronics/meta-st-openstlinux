#!/usr/bin/python3
# Copyright (c) 2019 STMicroelectronics. All rights reserved.
#
# This software component is licensed by ST under BSD 3-Clause license,
# the "License"; You may not use this file except in compliance with the
# License. You may obtain a copy of the License at:
#                        opensource.org/licenses/BSD-3-Clause


import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from gi.repository import Gdk
from gi.repository import GLib

import re
import os
import subprocess
import pexpect
from time import sleep, time

try:
    from application.bluetooth.wrap_blctl import wrapper_blctl as Bluetoothctl
except ModuleNotFoundError:
    from wrap_blctl import wrapper_blctl as Bluetoothctl

# -------------------------------------------------------------------
# -------------------------------------------------------------------
SUBMODULE_PATH = "application/bluetooth"
DEMO_PATH = "/usr/local/demo"
# -------------------------------------------------------------------
# -------------------------------------------------------------------
ICON_SIZE_720 = 180
ICON_SIZE_480 = 128
ICON_SIZE_272 = 48

TREELIST_HEIGHT_720 = 400
TREELIST_HEIGHT_480 = 160
TREELIST_HEIGHT_272 = 68

# return format:
# [ icon_size, font_size, treelist_height, button_height ]
SIZES_ID_ICON_SIZE = 0
SIZES_ID_FONT_SIZE = 1
SIZES_ID_TREELIST_HEIGHT = 2
SIZES_ID_BUTTON_HEIGHT = 3
def get_sizes_from_screen_size(width, height):
    minsize =  min(width, height)
    icon_size = None
    font_size = None
    treelist_height = None
    button_height = None
    if minsize == 720:
        icon_size = ICON_SIZE_720
        font_size = 25
        treelist_height = TREELIST_HEIGHT_720
        button_height = 60
    elif minsize == 480:
        icon_size = ICON_SIZE_480
        font_size = 20
        treelist_height = TREELIST_HEIGHT_480
        button_height = 60
    elif minsize == 272:
        icon_size = ICON_SIZE_272
        font_size = 15
        treelist_height = TREELIST_HEIGHT_272
        button_height = 25
    return [icon_size, font_size, treelist_height, button_height]

def get_treelist_height_from_screen_size(width, height):
    minsize =  min(width, height)
    if minsize == 720:
        return TREELIST_HEIGHT_720
    elif minsize == 480:
        return TREELIST_HEIGHT_480
    elif minsize == 272:
        return TREELIST_HEIGHT_272

# -------------------------------------------------------------------
# -------------------------------------------------------------------

SCAN_DURATION_IN_S  = 15

regexps_audio = [
   re.compile(r"00001108-(?P<Headset>.+)$"),
   re.compile(r"0000110b-(?P<AudioSink>.+)$"),
]

re_connected = re.compile(r"Connected:(?P<Connected>.+)$")

re_paired = re.compile(r"Paired:(?P<Paired>.+)$")

Item_info_dev = ['Headset', 'AudioSink', 'Connected', 'Paired']

regexps_devinfo = [
   re.compile(r"00001108-(?P<Headset>.+)$"),
   re.compile(r"0000110b-(?P<AudioSink>.+)$"),
   re.compile(r"Connected:(?P<Connected>.+)$"),
   re.compile(r"Paired:(?P<Paired>.+)$"),
]
########################################
#pactl (pulseaudio controller) wrapper
########################################
#for parse_sinks
re_sink = re.compile(r"^Sink #(?P<Ident>.+)$")
re_prop_sink = [
   re.compile(r"State:(?P<State>.+)$"),
   re.compile(r"Description:\s+(?P<Name>.+)$")
]

#for parse_streams
re_stream = re.compile(r"^Sink Input #(?P<Ident>.+)$")
re_prop_stream = [
   re.compile(r"Sink:\s+(?P<Sink>.+)$"),
   re.compile(r"media\.name\s=\s(?P<Name>.+)$")
]
# id_str : ident of the stream, id_sink : ident of the sink
def audiosink_set(id_str, id_sink):
    print("audiosink_set ")
    #print("id_str : %d", id_str)
    #print("id_sink : %d", id_sink)
    cmd = ["/usr/bin/pactl", "move-sink-input",  id_str, id_sink]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    res = proc.stdout.read().decode('utf-8')
    return res

def scan_streams():
    cmd = ["/usr/bin/pactl", "list",  "sink-inputs"]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    res = proc.stdout.read().decode('utf-8')
    return res

def parse_streams(streams):
    streams_lines = streams.split('\n')
    l_streams = []
    for line in streams_lines:
       line = line.strip()
       elt = re_stream.search(line)
       if elt is not None:
           l_streams.append(elt.groupdict())
           continue
       for reg in re_prop_stream:
           res = reg.search(line)
           if res is not None:
              l_streams[-1].update(res.groupdict())
    return l_streams


def scan_sinks():
    cmd = ["/usr/bin/pactl", "list", "sinks"]
    proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    res = proc.stdout.read().decode('utf-8')
    return res

def parse_sinks(sinks):
    sinks_lines=sinks.split('\n')
    l_sinks =[]
    for line in sinks_lines:
       line = line.strip()
       elt = re_sink.search(line)
       if elt is not None:
           l_sinks.append(elt.groupdict())
           continue
       for reg in re_prop_sink:
           res = reg.search(line)
           if res is not None:
              l_sinks[-1].update(res.groupdict())
    return l_sinks



def status_playback(self):
    sink_ident = []
    stream_ident = None

    list_sinks = scan_sinks()
    sinks = parse_sinks(list_sinks)
    #print("refresh label_audio\n")
    #print(sinks)
    mess_bt = ""
    if sinks != []:
       for sk in sinks:
          for bt_dev_conn in self.list_dev_connect:
              if sk['Name'] == bt_dev_conn['name']:
                  if mess_bt != "":
                      mess_bt = mess_bt + "\n"
                  mess_bt = mess_bt + "The audio BT device " + sk['Name'] + " is connected"
                  sink_ident.append({'name': sk['Name'], 'ident': sk['Ident']})

    if mess_bt == "":
        mess_bt = "Device not connected"

    self.label_audio.set_markup("<span font='20' color='#000000'>%s</span>" % mess_bt)
    self.label_audio.set_justify(Gtk.Justification.LEFT)
    self.label_audio.set_line_wrap(True)
    return [stream_ident, sink_ident]


def get_device_info(bl, macadr):
    #print("get_device_info")
    info_dev = bl.blctl_info(macadr)
    dict_info = {}
    for elt in Item_info_dev:
        dict_info[elt] = ''
    for reelt in regexps_devinfo:
        for elt in info_dev:
            result = reelt.search(elt)
            if result is not None:
                dict_info.update(result.groupdict())
                break
    return(dict_info)


def list_devices(self, paired = False):
    #print("list_devices")
    if self.locked_devices == False:
       self.locked_devices = True
       self.bluetooth_liststore.clear()
       self.current_devs=[]
       i=0
       if paired == True:
          devs = self.bl.blctl_paired_devices()
       else:
          devs = self.bl.blctl_devices()
       for elt in devs:
          elt_info = get_device_info(self.bl, elt['mac_address'])
          #print("name===" , elt['name'].encode('utf-8').strip())
          if elt['name'] == "RSSI is nil":
              continue
          if elt['name'] == "TxPower is nil":
              continue
          #do not list device without real name
          if elt['mac_address'].replace(':','') != elt['name'].replace('-',''):
              i=i+1
              self.current_devs.append(elt['mac_address'])
              #print(elt_info)
              l_elt = []
              l_elt.append(i)
              l_elt.append(elt['name'])
              l_elt.append(elt_info['Connected'])
              if elt_info['Headset'] != '' or elt_info['AudioSink'] != '':
                  l_elt.append('yes')
              else:
                  l_elt.append('no')

              if elt_info['Connected'] == " yes":
                  if elt not in self.list_dev_connect:
                     self.list_dev_connect.insert(0,elt)
                     self.bl.set_prompt(elt['name'])
              self.bluetooth_liststore.append(l_elt)

       self.locked_devices = False


def device_connected(bl, macadr):
    info_dev=bl.blctl_info(macadr)
    if info_dev is not None:
        for elt in info_dev:
            result = re_connected.search(elt)
            if result is not None:
               l_info_dev = result.groupdict()
               if l_info_dev["Connected"] == " yes":
                   return True
    return False


def device_paired(bl, macadr):
    info_dev=bl.blctl_info(macadr)
    if info_dev is not None:
        for elt in info_dev:
            result = re_paired.search(elt)
            if result is not None:
               l_info_dev = result.groupdict()
               if l_info_dev["Paired"] == " yes":
                   return True
    return False


def device_audio(bl, macadr):
    info_dev=bl.blctl_info(macadr)
    for reelt in regexps_audio:
        for elt in info_dev:
            result = reelt.search(elt)
            if result is not None:
                return True
    return False

# -------------------------------------------------------------------
# -------------------------------------------------------------------
def gtk_style():
        css = b"""

.widget .grid .label {
    background-color: rgba (31%, 32%, 32%, 0.9);
}
.textview {
    color: gray;
}
.label {
    color: black;
}
.switch {
    min-height: 44px;
}
        """
        style_provider = Gtk.CssProvider()
        style_provider.load_from_data(css)

        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            style_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

class BluetoothWindow(Gtk.Dialog):
    def __init__(self, parent):
        Gtk.Dialog.__init__(self, "Wifi", parent, 0)
        self.maximize()
        self.set_decorated(False)

        gtk_style()
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
        self.treelist_height = get_treelist_height_from_screen_size(self.screen_width, self.screen_height)
        sizes = get_sizes_from_screen_size(self.screen_width, self.screen_height)
        self.font_size = sizes[SIZES_ID_FONT_SIZE]
        self.button_height = sizes[SIZES_ID_BUTTON_HEIGHT]

        self.connect("button-release-event", self.on_page_press_event)
        mainvbox = self.get_content_area()

        self.dev_selected = {'mac_address':'', 'name':''}
        self.audio_bt_sink = []
        self.list_dev_connect = []
        self.current_devs = []
        self.locked_devices = False
        self.scan_done = False
        self.previous_click_time=0

        self.page_bluetooth = Gtk.VBox()
        self.page_bluetooth.set_border_width(15)

        self.title = Gtk.Label()
        self.title.set_markup("<span font='%d' color='#00000000'>Connect bluetooth headset</span>" % (self.font_size+5))
        self.page_bluetooth.add(self.title)

        self.ButtonBox = Gtk.HBox(homogeneous=True)

        self.lb_button_scan = Gtk.Label()
        self.lb_button_scan.set_markup("<span font='%d'>start scan</span>" % self.font_size)
        self.button_scan = Gtk.Button()
        self.button_scan.set_property("height-request", self.button_height)
        self.button_scan.add(self.lb_button_scan)
        self.button_scan.connect("clicked", self.on_selection_scan_clicked)
        self.ButtonBox.add(self.button_scan)

        self.lb_button_connect = Gtk.Label()
        self.lb_button_connect.set_markup("<span font='%d' color='#88888888'>connect</span>" % self.font_size)
        self.button_connect = Gtk.Button()
        self.button_connect.add(self.lb_button_connect)
        self.button_connect.connect("clicked", self.on_selection_connect_clicked)
        self.ButtonBox.add(self.button_connect)

        self.page_bluetooth.add(self.ButtonBox)

        self.progress_vbox = Gtk.VBox()
        self.scan_progress = Gtk.ProgressBar()
        self.scan_progress.set_fraction(0.0)
        self.progress_vbox.pack_start(self.scan_progress, False, False, 3)
        self.page_bluetooth.add(self.progress_vbox)

        self.tree_list_vbox = Gtk.VBox(homogeneous=True)

        self.bluetooth_liststore = Gtk.ListStore(int, str, str, str)
        self.bluetooth_treeview = Gtk.TreeView(self.bluetooth_liststore)

        l_col = ["n°", "name", "connected", "Audio"]
        for i, column_title in enumerate(l_col):
            renderer = Gtk.CellRendererText()
            renderer.set_property('font', "%d" % self.font_size)
            column = Gtk.TreeViewColumn(column_title, renderer, text=i)
            self.bluetooth_treeview.append_column(column)
        self.bluetooth_treeview.get_selection().connect("changed", self.on_changed)

        self.scroll_treelist = Gtk.ScrolledWindow()
        self.scroll_treelist.set_vexpand(False)
        self.scroll_treelist.set_hexpand(False)
        self.scroll_treelist.set_property("min-content-height", self.treelist_height)
        self.scroll_treelist.add(self.bluetooth_treeview)
        self.tree_list_vbox.pack_start(self.scroll_treelist, True, True, 3)

        self.page_bluetooth.add(self.tree_list_vbox)

        self.label_audio = Gtk.Label()
        self.label_audio.set_markup("<span font='%d' color='#FFFFFFFF'> </span>" % self.font_size)
        self.label_audio.set_justify(Gtk.Justification.LEFT)
        self.label_audio.set_line_wrap(True)
        self.page_bluetooth.add(self.label_audio)

        mainvbox.pack_start(self.page_bluetooth, False, True, 3)
        self.show_all()

        # enable bluetooth
        os.system('su -c \"hciconfig hci0 up\"')
        #self.bluetooth_state = os.system('hciconfig hci0 up')
        self.bl = Bluetoothctl()

        list_devices(self, paired=True)
        self.audio_bt_sink = status_playback(self)


    def display_message(self, message):
        dialog = Gtk.Dialog("Error", self, 0, (Gtk.STOCK_OK, Gtk.ResponseType.OK))
        dialog.set_decorated(False)
        width, height = self.get_size()
        dialog.set_default_size(width, height)
        rgba = Gdk.RGBA(0.31, 0.32, 0.31, 0.8)
        dialog.override_background_color(0,rgba)

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


    def on_page_press_event(self, widget, event):
        self.click_time = time()
        #print(self.click_time - self.previous_click_time)
        # TODO : a fake click is observed, workaround hereafter
        if (self.click_time - self.previous_click_time) < 0.01:
            self.previous_click_time = self.click_time
        elif (self.click_time - self.previous_click_time) < 0.3:
            print ("BluetoothWindow double click : exit")
            self.bl.close()
            self.destroy()
        else:
            #print ("simple click")
            self.previous_click_time = self.click_time


    def delayed_status_playback(self, user_data):
        self.audio_bt_sink = status_playback(self)
        return False

    def progress_timeout(self, user_data):
        new_val=self.scan_progress.get_fraction() + 0.01
        if new_val > 1:
           self.scan_progress.set_fraction(0.0)
           self.bl.blctl_scan_off()
           self.lb_button_scan.set_markup("<span font='%d'>start scan</span>" % self.font_size)
           self.scan_done = True
           self.update_display()
           return False

        self.scan_progress.set_fraction(new_val)
        self.scan_progress.set_text(str(new_val*100) + " % completed")
        return True

    def on_changed(self, selection):
        (model, iter) = selection.get_selected()
        #print("on_changed")
        if iter is not None:
            self.audio_bt_sink = status_playback(self)
            #print(self.audio_bt_sink)
            self.dev_selected.update({'mac_address':self.current_devs[model[iter][0]-1], 'name':model[iter][1]})
            if model[iter][2] == " yes":
                self.lb_button_connect.set_markup("<span font='%d'>disconnect</span>" % self.font_size)
            else:
                if self.label_audio.get_text() == "Device not connected":
                    self.lb_button_connect.set_markup("<span font='%d'>connect</span>" %  self.font_size)
                else:
                    self.lb_button_connect.set_markup("<span font='%d' color='#88888888'>connect</span>" % self.font_size)
        return True

    def connect_process(self, dev):
        if device_connected(self.bl, dev['mac_address']):
            self.lb_button_connect.set_markup("<span font='%d'>disconnect</span>" % self.font_size)
            self.update_display()
        else:
            connect_res=self.bl.blctl_connect(dev['mac_address'])
            if connect_res == True:
                self.lb_button_connect.set_markup("<span font='%d' color='#88888888'>disconnect</span>" % self.font_size)
                self.update_display()
        # refresh status_playback after 2,5s because pulseaudio takes some time to update its status
        timer_update_dev = GLib.timeout_add(2500, self.delayed_status_playback, None)
        #In some cases, 2.5s is still not enough
        timer_update_dev = GLib.timeout_add(4000, self.delayed_status_playback, None)

    def on_selection_connect_clicked(self, widget):
        if self.dev_selected['mac_address'] != '':
            device = self.dev_selected
            if self.lb_button_connect.get_text() == "connect":
                if self.label_audio.get_text() == "Device not connected":
                    self.bl.set_prompt(device['name'])
                    if device_paired(self.bl, device['mac_address']) == False:
                        pairing_res=self.bl.blctl_pair(device['mac_address'])
                        if pairing_res == 0:
                            self.bl.blctl_session.send("no\n")
                        else:
                            if pairing_res == 1:
                                sleep(5)
                                self.connect_process(device)
                    else:
                        self.connect_process(device)
                else:
                    print("[WARNING] A BT device is already connected :\ndisconnect it before connecting a new device\n")
                    self.display_message("<span font='15' color='#000000'>A BT device is already connected :\nPlease disconnect it before connecting a new device\n</span>")
            else:
                connect_res=self.bl.blctl_disconnect(device['mac_address'])
                self.lb_button_connect.set_markup("<span font='%d' color='#88888888'>connect</span>" % self.font_size)
                self.update_display()
        else:
            print("[WARNING] Select the BT device to connect\n")
            self.display_message("<span font='15' color='#000000'>Please select a device in the list\n</span>")

    def on_selection_scan_clicked(self, widget):
        if self.lb_button_scan.get_text() == "start scan":
           self.bl.blctl_scan_on()
           timer_scan = GLib.timeout_add(SCAN_DURATION_IN_S * 10, self.progress_timeout, None)
           self.lb_button_scan.set_markup("<span font='%d'>scan progress</span>"% self.font_size)

    def update_display(self):
        if (self.scan_done == True):
            list_devices(self, False)
        else:
            list_devices(self, True)
        self.dev_selected.update({'mac_address':'', 'name':''})
        self.audio_bt_sink = status_playback(self)

# -------------------------------------------------------------------
# -------------------------------------------------------------------
def create_subdialogwindow(parent):
    _window = BluetoothWindow(parent)
    _window.show_all()
    response = _window.run()
    _window.destroy()


# -------------------------------------------------
# -------------------------------------------------
#               test submodule
class TestUIWindow(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Test Launcher")
        create_subdialogwindow(self)
        self.show_all()

if __name__ == "__main__":
    win = TestUIWindow()
    win.connect("delete-event", Gtk.main_quit)
    win.show_all()

