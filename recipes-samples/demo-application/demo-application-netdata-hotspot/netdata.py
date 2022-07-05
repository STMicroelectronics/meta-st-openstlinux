#!/usr/bin/python3

import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
from gi.repository import GObject
from gi.repository import Gdk
from gi.repository import GLib
from gi.repository import GdkPixbuf

import os
import socket
import fcntl
import struct
import string
import random
import math
import subprocess
from time import sleep, time
import threading

SIMULATE = 0

# -------------------------------------------------------------------
# -------------------------------------------------------------------
SUBMODULE_PATH = "application/netdata"
DEMO_PATH = "/usr/local/demo"
# -------------------------------------------------------------------
# -------------------------------------------------------------------

WIFI_LINUX_INTERFACE_NAME = "wlan0"
WIFI_HOTSPOT_IP="192.168.72.1"

WIFI_DEFAULT_SSID="STDemoNetwork"
WIFI_DEFAULT_PASSWD="stm32mp1"

if SIMULATE > 0:
    WIFI_LINUX_INTERFACE_NAME = "wlp8s0"

# -------------------------------------------------------------------
# -------------------------------------------------------------------
ICON_SIZE_720 = 160
ICON_SIZE_480 = 160
ICON_SIZE_272 = 48

# return format:
# [ icon_size, font_size ]
SIZES_ID_ICON_SIZE = 0
SIZES_ID_FONT_SIZE = 1
def get_sizes_from_screen_size(width, height):
    minsize =  min(width, height)
    icon_size = None
    font_size = None
    if minsize == 720:
        icon_size = ICON_SIZE_720
        font_size = 25
    elif minsize == 480:
        icon_size = ICON_SIZE_480
        font_size = 20
    elif minsize == 272:
        icon_size = ICON_SIZE_272
        font_size = 10
    return [icon_size, font_size]

def get_icon_size_from_screen_size(width, height):
    minsize =  min(width, height)
    if minsize == 720:
        return ICON_SIZE_720
    elif minsize == 480:
        return ICON_SIZE_480
    elif minsize == 272:
        return ICON_SIZE_272

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# Get the ip address of board
def get_ip_address(ifname):
    ip = "NA"
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        ip = socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            0x8915,  # SIOCGIFADDR
            struct.pack('256s', bytes(ifname[:15], 'utf-8'))
        )[20:24])
    except socket.error:
        pass
    return ip
# -------------------------------------------------------------------
# -------------------------------------------------------------------
def _load_image_wlan_eventBox(parent, filename, label_text1, label_text2, scale_w, scale_h):
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
    label.set_markup("<span font='10' color='#FFFFFFFF'>%s\n</span>"
                     "<span font='10' color='#FFFFFFFF'>%s</span>" % (label_text1, label_text2))
    #label.set_justify(Gtk.Justification.LEFT)
    label.set_line_wrap(True)

    # Pack the pixmap and label into the box
    box.pack_start(image, True, False, 0)
    box.pack_start(label, True, False, 0)

    # Add the image to the eventBox
    eventBox.add(box)

    return eventBox

# -------------------------------------------------------------------
# -------------------------------------------------------------------
def id_generator(size=6, chars=string.ascii_lowercase + string.digits):
    return "".join(random.choice(chars) for _ in range(size))
# -------------------------------------------------------------------
# -------------------------------------------------------------------

class NetdataWebserver(Gtk.Dialog):
    def __init__(self, parent):
        Gtk.Dialog.__init__(self, "Wifi", parent, 0)

        if SIMULATE > 0:
            self.screen_width = 800
            self.screen_height = 480
            self.set_default_size(self.screen_width, self.screen_height)
        else:
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

        self.icon_size = get_icon_size_from_screen_size(self.screen_width, self.screen_height)
        sizes = get_sizes_from_screen_size(self.screen_width, self.screen_height)
        self.font_size = sizes[SIZES_ID_FONT_SIZE]

        self.set_decorated(False)
        rgba = Gdk.RGBA(0.31, 0.32, 0.31, 0.8)
        self.override_background_color(0,rgba)

        mainvbox = self.get_content_area()

        self.page_ip = Gtk.VBox(homogeneous=False, spacing=0)
        self.page_ip.set_border_width(10)
        self.set_border_width(10)

        self.title = Gtk.Label()
        self.title.set_markup("<span font='%d' color='#FFFFFFFF'><b>Access information to netdata</b></span>" % (self.font_size+5))
        self.page_ip.add(self.title)
        self.label_eth = Gtk.Label()
        self.label_eth.set_markup("<span font='%d' color='#FFFFFFFF'>netdata over Ethernet:</span>" % self.font_size)
        self.label_eth.set_xalign (0.0)
        self.label_ip_eth0 = Gtk.Label()
        #self.label_ip_eth0.set_xalign (0.0)
        self.label_wifi = Gtk.Label()
        self.label_wifi.set_markup("<span font='%d' color='#FFFFFFFF'>netdata over Wifi:</span>" % self.font_size)
        self.label_wifi.set_xalign (0.0)
        self.label_ip_wlan0 = Gtk.Label()
        #self.label_ip_wlan0.set_xalign (0.0)
        self.label_hotspot = Gtk.Label()
        self.label_hotspot.set_xalign (0.0)

        self.previous_click_time=0
        self.wifi_ssid=WIFI_DEFAULT_SSID
        self.wifi_passwd=WIFI_DEFAULT_PASSWD

        self.info_grid = Gtk.Grid()
        self.info_grid.set_column_spacing(2)
        self.info_grid.set_row_spacing(2)

        self.info_grid.attach(self.label_eth, 0, 1, 1, 1)
        self.info_grid.attach(self.label_ip_eth0, 1, 1, 1, 1)

        if self.is_wifi_available():
            print ("wlan0 is available")
            self.hotspot_switch = Gtk.Switch()

            # set wlan switch state on first execution
            ip_wlan0 = get_ip_address('wlan0')
            if ip_wlan0 == WIFI_HOTSPOT_IP:
                self.hotspot_switch.set_active(True)
            else:
                self.hotspot_switch.set_active(False)

            self.hotspot_switch.connect("notify::active", self.on_switch_activated)
            self.info_grid.attach(self.label_wifi, 0, 2, 1, 1)
            self.info_grid.attach(self.hotspot_switch, 0, 3, 1, 1)
            self.info_grid.attach(self.label_hotspot, 1, 3, 1, 1)

        else:
            print ("wlan0 interface not available")
            self.info_grid.attach(self.label_hotspot, 0, 3, 1, 1)

        self.page_ip.add(self.info_grid)
        self.refresh_network_page()
        self.connect("button-release-event", self.on_page_press_event)

        mainvbox.pack_start(self.page_ip, False, True, 3)
        self.show_all()

    def is_wifi_available(self):
        if WIFI_LINUX_INTERFACE_NAME in open('/proc/net/dev').read():
            return True
        return False

    def get_wifi_config(self):
        filepath = "/etc/default/hostapd"
        if os.path.isfile(filepath):
            file = open(filepath, "r")
            i=0
            for line in file:
                if "HOSTAPD_SSID" in line:
                    self.wifi_ssid = (line.split('=')[1]).rstrip('\r\n')
                    i+=1
                if "HOSTAPD_PASSWD" in line:
                    self.wifi_passwd=(line.split('=')[1]).rstrip('\r\n')
                    i+=1
            file.close()
            if (i==2):
                print("[Wifi: use hostapd configuration: ssid=%s, passwd=%s]\n" %(self.wifi_ssid, self.wifi_passwd))
            else:
                self.wifi_ssid=WIFI_DEFAULT_SSID
                self.wifi_passwd=WIFI_DEFAULT_PASSWD
                print("[Wifi: use default configuration: ssid=%s, passwd=%s]\n" %(self.wifi_ssid, self.wifi_passwd))
        else:
            print("[Wifi: use default configuration: ssid=%s, passwd=%s]\n" %(self.wifi_ssid, self.wifi_passwd))

    def set_random_wifi_config(self):
        self.wifi_ssid="ST-" + id_generator()
        #self.wifi_passwd=id_generator(6, string.ascii_lowercase)
        self.set_wifi_config(self.wifi_ssid, self.wifi_passwd)

    def set_wifi_config(self, ssid, password):
        filepath = "/tmp/hostapd"
        file = open(filepath, "w")
        print ("[Wifi: set hostapd config: ssid=%s, passwd=%s]" %(ssid, password))
        file.write('HOSTAPD_SSID=%s\nHOSTAPD_PASSWD=%s\n' %(ssid, password))
        file.close()
        os.system('su -c \"cp /tmp/hostapd /etc/default/hostapd\"')


    def refresh_network_page(self):
        print("[Refresh network page]\n")

        ip_eth0 = get_ip_address('eth0')
        if ip_eth0 != "NA":
            eth0_status = "<span font='%d' color='#FFFFFFFF'>  http://%s:19999</span>" % (self.font_size, ip_eth0)
        else:
            eth0_status = "<span font='%d' color='#FF0000FF'>  No Ethernet connection</span>"  % self.font_size
        self.label_ip_eth0.set_markup(eth0_status)

        if self.is_wifi_available():
            print ("wlan0 is available")
            ip_wlan0 = get_ip_address('wlan0')
            print("Ip address of Wlan0 are: ", ip_wlan0)
            if ip_wlan0 == "NA":
                sleep(1)
                ip_wlan0 = get_ip_address('wlan0')
                print("Ip address of Wlan0 are: ", ip_wlan0)
            if ip_wlan0 == "NA":
                hotspot_status = "<span font='%d' color='#FF0000FF'>  Wifi not started</span>" % self.font_size
                self.info_grid.remove_row(6)
            elif ip_wlan0 == WIFI_HOTSPOT_IP:
                self.get_wifi_config()
                hotspot_status = "<span font='%d' color='#00AA00FF'>  Wifi hotspot started</span>" % self.font_size

                wifi_qrcode_cmd = "WIFI:S:%s;T:WPA;P:%s;;" %(self.wifi_ssid, self.wifi_passwd)
                print("%s/bin/build_qrcode.sh" % os.path.join(DEMO_PATH,SUBMODULE_PATH), "-o /tmp/qr-code_wifi_access.png", wifi_qrcode_cmd)
                cmd = ["%s/bin/build_qrcode.sh" % os.path.join(DEMO_PATH,SUBMODULE_PATH), "-o /tmp/qr-code_wifi_access.png", wifi_qrcode_cmd]
                proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                result = proc.stdout.read().decode('utf-8')

                url_qrcode_cmd = "http://%s:19999" % ip_wlan0
                cmd2 = ["%s/bin/build_qrcode.sh" % os.path.join(DEMO_PATH,SUBMODULE_PATH), "-o /tmp/qr-code_netdata_url.png", url_qrcode_cmd]
                proc = subprocess.Popen(cmd2, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                result = proc.stdout.read().decode('utf-8')

                self.wifi_credential = _load_image_wlan_eventBox(self, "/tmp/qr-code_wifi_access.png", "ssid: %s" % self.wifi_ssid, "passwd: %s" % self.wifi_passwd, -1, self.icon_size)
                self.netdata_url = _load_image_wlan_eventBox(self, "/tmp/qr-code_netdata_url.png", "url: http://%s:19999" % ip_wlan0, "", -1, self.icon_size)
                self.info_grid.attach(self.wifi_credential, 0, 6, 1, 1)
                self.info_grid.attach(self.netdata_url, 1, 6, 1, 1)

                self.show_all()
            else:
                hotspot_status = "<span font='%d' color='#FF0000FF'>Wifi started but not configured as hotspot</span>" % self.font_size
                self.info_grid.remove_row(6)

                self.label_ip_wlan0.set_markup("<span font='%d' color='#FFFFFFFF'>NetData over Wifi: http://%s:19999</span>" % (self.font_size, ip_wlan0))
                self.info_grid.attach(self.label_ip_wlan0, 0, 6, 1, 1)
                self.show_all()
        else:
            print ("wlan0 interface not available")
            hotspot_status = "<span font='%d' color='#FF0000FF'>  Wifi not available on board</span>" % self.font_size

        self.label_hotspot.set_markup(hotspot_status)

    def on_page_press_event(self, widget, event):
        self.click_time = time()
        #print(self.click_time - self.previous_click_time)
        # TODO : a fake click is observed, workaround hereafter
        if (self.click_time - self.previous_click_time) < 0.01:
            self.previous_click_time = self.click_time
        elif (self.click_time - self.previous_click_time) < 0.3:
            print ("double click : exit")
            self.destroy()
        else:
            #print ("simple click")
            self.previous_click_time = self.click_time

    def on_switch_activated(self, switch, gparam):
        if switch.get_active():
            self.set_random_wifi_config()
            self.wifi_hotspot_start()
        else:
            self.wifi_hotspot_stop()
        self.refresh_network_page()

    def wifi_hotspot_start(self):
        print('[DEBUG]: %s/application/netdata/bin/wifi_start.sh' % DEMO_PATH)
        os.system('%s/application/netdata/bin/wifi_start.sh' % DEMO_PATH)


    def wifi_hotspot_stop(self):
        print('[DEBUG]:%s/application/netdata/bin/wifi_start.sh\"' % DEMO_PATH)
        os.system('%s/application/netdata/bin/wifi_stop.sh' % DEMO_PATH)

def create_subdialogwindow(parent):
    _window = NetdataWebserver(parent)
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
