# test configuration of uart connection to ensure reliable data transfer

import serial
import time

# Windows can get reliable data transfer at 4 Mbaud with 1 stop bit
# WSL can get reliable data transfer at 4 Mbaud with 1.5 stop bits
uart = serial.Serial(port="/dev/ttyUSB1", baudrate=4000000, bytesize=serial.EIGHTBITS, parity=serial.PARITY_NONE, stopbits=serial.STOPBITS_ONE_POINT_FIVE)

for _ in range(0, 100):
    print(f"sending 0 - 255")
    for i in range(0, 256):
        uart.write(bytes([i]))

    time.sleep(0.1)                             # wait for all data to echo back
    print(f"expecting 256 echoes, got {uart.in_waiting}")
    assert uart.in_waiting == 256

    for i in range(0, 256):
        res = uart.read(1)
        print(f"expecting {bytes([i])}, got {res}")
        assert res == bytes([i])

    # data corruption in Windows, works on WSL
    uart.write(b"Hello World!")

    # reliable on Windows, also works on WSL
    # uart.write(b"H")
    # uart.write(b"e")
    # uart.write(b"l")
    # uart.write(b"l")
    # uart.write(b"o")
    # uart.write(b" ")
    # uart.write(b"W")
    # uart.write(b"o")
    # uart.write(b"r")
    # uart.write(b"l")
    # uart.write(b"d")
    # uart.write(b"!")

    time.sleep(0.1)
    print(uart.in_waiting)
    print(f"expecting 12 echoes, got {uart.in_waiting}")
    assert uart.in_waiting == 12
    print(uart.read_all())
