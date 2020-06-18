import time
import pexpect
import sys
import re
import pickle

##############################
# bluetoothctl tool wrapper
##############################

__all__ = ["wrapper_blctl"]


device = re.compile(r"Device\s(?P<mac_address>([0-9 A-F][0-9 A-F]:){5}[0-9 A-F][0-9 A-F])(?P<name>.+)$")

re_device_notvalid = [
   re.compile(r"CHG"),
   re.compile(r"NEW"),
   re.compile(r"DEL")
]

def read_prompt():
    try:
      f = open('/tmp/list_prompt', 'rb')
    except IOError as e:
        print("Cant not open the file : /tmp/list_prompt\n")
        return None
    else:
        s = pickle.load(f)
        f.close()
        return s

def write_prompt(prt):
    with open('/tmp/list_prompt', 'wb') as f:
        pickle.dump(prt,f)


class blctl_error(Exception):
    pass


class wrapper_blctl:

    def __init__(self):
        self.blctl_session = pexpect.spawn("bluetoothctl", echo = False, maxread = 3000)

        #no prompt expected because a BT device can be connected automatically
        prompt_expect = self.blctl_session.expect([pexpect.EOF, pexpect.TIMEOUT], timeout = 1)
        str_out = str(self.blctl_session.before,"utf-8")
        l_out = str_out.split("\r\n")

        self.prompt = read_prompt()
        if self.prompt == None:
            self.prompt= ["\[bluetooth\]", pexpect.EOF]
        #print(self.prompt)

    #execute a bluetoothctl command and return the result as a list of lines
    #no status cmd expected
    def blctl_command(self, command, pause = 0):
        #print("blctl_command : " + command)
        self.blctl_session.send(command + "\n")
        time.sleep(pause)

        prompt_expect = self.blctl_session.expect(self.prompt)

        if (prompt_expect > (len(self.prompt) - 1) or (prompt_expect < 0)):
           raise blctl_error("The bluetoothctl command " + command  + " failed")

        str_output = str(self.blctl_session.before,"utf-8")
        output_array = str_output.split("\r\n")

        return output_array

    #execute a bluetoothctl command with status expected
    def blctl_command_with_status(self, command, status_expected, pause = 0):
        print("blctl_command_with_status : " + command + "\n")
        status = status_expected
        status.extend([pexpect.EOF])
        #print("prompt_status : %s\n", status)

        self.blctl_session.send(command + "\n")
        time.sleep(pause)

        res = self.blctl_session.expect(status)

        return res

    def close(self):
        write_prompt(self.prompt)
        self.blctl_session.close()

    #build the list of bluetoothctl prompts
    def set_prompt(self, prompt):
        prpt = "\["+prompt+"\]"
        if prpt not in self.prompt:
            self.prompt.insert(0, prpt)

    #bluetoothctl command : scan on
    def blctl_scan_on(self):
        try:
           cmd_res = self.blctl_command("scan on")
        except blctl_error as ex:
           print(ex)
           return None

    #bluetoothctl command : scan off
    def blctl_scan_off(self):
        try:
           cmd_res = self.blctl_command("scan off")
        except blctl_error as ex:
           print(ex)
           return None

    #make a dic (mac_address, name) from result of bluetoothctl command devices
    def parse_info(self, device_info):
        dev = {}
        info_isnot_valid = None
        for reg in re_device_notvalid:
            info_isnot_valid = reg.search(device_info)
            if info_isnot_valid is not None:
                break

        if info_isnot_valid is None:
            result = device.search(device_info)
            if result is not None:
               dev = result.groupdict()
               name_tmp = dev['name'].strip()
               dev['name'] = name_tmp
        return dev

    #bluetoothctl command : devices
    #return a list of dic {mac_address, name}
    def blctl_devices(self):
        try:
            cmd_res = self.blctl_command("devices")
        except blctl_error as ex:
            print(ex)
            return None
        else:
            list_devices = []
            for line in cmd_res:
                device = self.parse_info(line)
                if device:
                    list_devices.append(device)

            return list_devices

    #bluetoothctl command : paired-devices
    #return a list of dic {mac_address, name}
    def blctl_paired_devices(self):
        try:
            cmd_res = self.blctl_command("paired-devices")
        except blctl_error as ex:
            print(ex)
            return None
        else:
            list_devices = []
            for line in cmd_res:
                device = self.parse_info(line)
                if device:
                    list_devices.append(device)

            return list_devices

    #bluetoothctl command : info <mac_address>
    def blctl_info(self, mac_address):
        try:
            cmd_res = self.blctl_command("info " + mac_address)
        except blctl_error as ex:
            print(ex)
            return None
        else:
            return cmd_res

    #bluetoothctl command : pair <mac_address>
    def blctl_pair(self, mac_address):
        cmd_res = self.blctl_command_with_status("pair " + mac_address, ["confirmation", "Pairing successful", "not available", "Failed to pair"], pause=4)
        return cmd_res

    #bluetoothctl command : connect <mac_address>
    def blctl_connect(self, mac_address):
        cmd_res = self.blctl_command_with_status("connect " + mac_address, ["Failed to connect", "Connection successful"], pause=2)
        passed = True if cmd_res == 1 else False
        return passed

    #bluetoothctl command : disconnect <mac_address>
    def blctl_disconnect(self, mac_address):
        cmd_res = self.blctl_command_with_status("disconnect " + mac_address, ["Failed to disconnect", "Successful disconnected"], pause=2)
        passed = True if cmd_res == 1 else False
        return passed

    #bluetoothctl command : remove <mac_address>
    def blctl_remove(self, mac_address):
        cmd_res = self.blctl_command_with_status("remove " + mac_address, ["not available", "Failed to remove", "Device has been removed"], pause=3)
        passed = True if cmd_res == 2 else False
        return passed
