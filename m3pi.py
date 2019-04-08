import serial
import RPi.GPIO as GPIO
import time
import struct

SEND_SIGNATURE = b'\x81'
SEND_RAW_SENSOR_VALUES = b'\x86'
SEND_TRIMPOT = b'\xB0'
SEND_BATTERY_MILLIVOLTS = b'\xB1'
PI_CALIBRATE = b'\xB4'
LINE_SENSORS_RESET_CALIBRATION = b'\xB5'
SEND_LINE_POSITION = b'\xB6'
AUTO_CALIBRATE = b'\xBA'
SET_PID = b'\xBB'
STOP_PID = b'\xBC'
M1_FORWARD = b'\xC1'
M1_BACKWARD = b'\xC2'
M2_FORWARD = b'\xC5'
M2_BACKWARD = b'\xC6'

SEND_M1_ENCODER_COUNT = b'\xD1'
SEND_M2_ENCODER_COUNT = b'\xD2'
SEND_M1_ENCODER_ERROR = b'\xD3'
SEND_M2_ENCODER_ERROR = b'\xD4'

DRIVE_STRAIGHT = b'\xE1'
DRIVE_STRAIGHT_DISTANCE = b'\xE2'
ROTATE_DEGREES = b'\xE3'

DRIVE_STRAIGHT_DISTANCE_BLOCKING = b'\xE4'
ROTATE_DEGREES_BLOCKING = b'\xE5'

MIN_SPEED = 0
MAX_SPEED = 127
MAX_REVERSE = -127

class m3pi():
    def __init__(self, reset_pin):
        self.ser = serial.Serial('/dev/serial0', 115200)
        self.reset_pin = reset_pin
        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(reset_pin, GPIO.OUT)

    def reset(self):
        GPIO.output(self.reset_pin, GPIO.LOW);
        time.sleep(0.01)
        GPIO.output(self.reset_pin, GPIO.HIGH);
        time.sleep(0.1)

    def motor(self, motor, speed):
        opcode = b'\x00'
        if (speed > 0):
            if (motor==1):
                opcode = M2_FORWARD;
            else:
                opcode = M1_FORWARD;
        else:
            speed *= -1
            if (motor==1):
                opcode = M2_BACKWARD;
            else:
                opcode = M1_BACKWARD;
        output = opcode+bytes([speed])
        self.ser.write(output)

    def left_motor(self, speed):
        self.motor(0, speed)

    def right_motor(self, speed):
        self.motor(1, speed)

    def forward(self, speed):
        self.motor(0, speed)
        self.motor(1, speed)

    def backwards(self, speed):
        self.motor(0, -1*speed)
        self.motor(1, -1*speed)

    def left(self, speed):
        self.motor(0, speed)
        self.motor(1, -1*speed)

    def right(self, speed):
        self.motor(0, -1*speed)
        self.motor(1, speed)

    def stop(self):
        self.motor(0, 0)
        self.motor(1, 0)

    def battery(self):
        self.ser.write(SEND_BATTERY_MILLIVOLTS)
        raw_val = self.ser.read(2)
        return struct.unpack("<H", raw_val)[0]/1000

    def line_position(self):
        self.ser.write(SEND_LINE_POSITION)
        raw_value = self.ser.read(2)
        value = struct.unpack("<H", raw_val)[0]
        return (value - 2048) / 2048

    def sensor_auto_calibrate(self):
        self.ser.write(AUTO_CALIBRATE)
        return self.ser.read()

    def calibrate(self):
        self.ser.write(PI_CALIBRATE)

    def reset_calibration(self):
        self.ser.write(LINE_SENSORS_RESET_CALIBRATION)

    def PID_start(self, max_speed, a, b, c, d):
        output = bytes([max_speed, a, b, c, d])
        self.ser.write(output)

    def PID_stop(self):
        self.ser.write(STOP_PID)

    def pot_voltage(self):
        self.ser.write(SEND_TRIMPOT)
        raw_val = self.ser.read(2)
        return struct.unpack("<H", raw_val)[0]

    def _print(self, text):
        assert isinstance(text, str)
        for char in text:
            self.ser.write(bytes(char))

    def m1_encoder_count(self):
        self.ser.write(SEND_M1_ENCODER_COUNT)
        raw_val = self.ser.read(2)
        return struct.unpack("<H", raw_val)[0]


    def m2_encoder_count(self):
        self.ser.write(SEND_M2_ENCODER_COUNT)
        raw_val = self.ser.read(2)
        return struct.unpack("<H", raw_val)[0]

    def m1_encoder_error(self):
        self.ser.write(SEND_M1_ENCODER_ERROR)
        return self.ser.read()

    def m2_encoder_error(self):
        self.ser.write(SEND_M2_ENCODER_ERROR)
        return self.ser.read()

    def rotate_degrees(self, degrees, direction, speed):
        direction = direction % 256
        output = struct.pack('<cccc', ROTATE_DEGREES, bytes([degrees]), bytes([direction]), bytes([speed]))
        self.ser.write(output)

    def rotate_degrees_blocking(self, degrees, direction, speed):
        direction = direction % 256
        output = struct.pack('<cccc', ROTATE_DEGREES_BLOCKING, bytes([degrees]), bytes([direction]), bytes([speed]))
        self.ser.write(output)
        self.ser.read()

    def move_straight_distance(self, speed, distance):
        output = struct.pack('<cch', DRIVE_STRAIGHT_DISTANCE, bytes([speed]), distance)
        self.ser.write(output)

    def move_straight_distance_blocking(self, speed, distance):
        output = struct.pack('<cch', DRIVE_STRAIGHT_DISTANCE_BLOCKING, bytes([speed]), distance)
        self.ser.write(output)
        self.ser.read()
