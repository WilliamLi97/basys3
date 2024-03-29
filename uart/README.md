# UART Controller
The Basys 3 has a USB UART bridge, allowing the micro-USB connection to be used to program the board as well as for UART communication. The goal of this project is to set up UART receiver and transmitter modules capable of reliable data communication. The design simply echoes back the incoming data from the host.

The original goal was to start with 9600 baud and as such, the testbenches were designed specifically for 9600 baud. With some minor changes, however, the board seems to reliably handle 4 Mbaud. In PuTTY (Windows), and `screen` (WSL), no data corruption was detected using 8 data bits, no parity bit, and 1 stop bit (8-N-1) at 4 Mbaud. 

However, more interestingly, I wanted to make sure the performance could be replicated using Python (I want to programmatically send and receive data in future projects). Unfortunately, data transfer was not reliable using the same parameters and the `pyserial` library in WSL. Instead, a number of stop bits greater than 1 was necessary to achieve reliable data transfer. The `pyserial` library allows the specification of 1.5 stop bits, resulting in a ~5% increase in the time required to transmit a byte of data. The exact cause of this issue is unknown. I suspect it may have been an issue with the timing of state changes, or with a particular nuance of the `pyserial`. Interestingly, the when using `pyserial` in Windows, reliable data transfer was achieved with just 1 stop bit. This leads me to believe the issue may be related to having to pass the connection through Windows into WSL. Even if an additional stop bit is required to ensure reliable operation, the throughput at 4 Mbaud greatly exceeded my original plan of running at 9600 baud. To test reliability, a Python script is included (`/validation/echo.py`). Note that the port name may need to be changed depending on the the physical USB port being used on the host system, and whether a Windows or Linux system is being used (e.g., the Windows port name would something like `COM4`, whereas the Linux port name would be something like `/dev/ttyUSB1`). Additionally, the `pyserial` does not come with Python by default and can be installed using `pip`:

```
pip install pyserial
```

In the future, I plan using (asynchronous) FIFOs to buffer the data. If there is an issue with incoming data being dumped due to the tranmitter being busy, this may fix the issue with data loss.

## UART Top (`uart_top`)
The top-level UART module includes some logic to echo the received data and display the last received byte in binary using LEDs 7 down to 0. It also contains a synchronizer for the RX signal. This is necessary because the RX signal is asynchronous and (as is usually the case with asynchronous operation,) the signals must be synchronized to the destination clock (otherwise there will be issues with metastability). With no synchronizer, an incorrect value was echoed every ~30 bytes sent through PuTTY. Using a synchronizer with chain length of 2, there were no longer any incorrect values echoed through PuTTY. 

## UART Transmitter (`uart_tx`)
This module implements the transmitter using as an FSM with states `IDLE`, `START`, `DATA`, and `STOP`. A shift register is used to place the appropriate bit on the transmit line. A write enable is used to signal when the input data byte should be captured for transmission. Because the data needs to be manipulated (i.e., shifted), the data byte is copied to the internal shift register, allowing the input byte signal to change after a write enable is received. During transmission, the transmitter busy signal will be raised.

## UART Receiver (`uart_rx`)
This module operates similarly to the transmitter (similar FSM), but instead of controlling a serial line, it is sampling one. Sampling is offset such that each data bit is sampled in the middle of the bit rather than near the beginning / end. This results in the highest probability that value sampled is correct. Once all data bits are sampled and shifted into their appropriate locations (this occurs following the transition from the `DATA` state to the `STOP` state), `valid` is raised to signal that the data byte is ready to be read.
