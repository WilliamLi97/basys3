# Seven-Segment Display
This is an implementation of a seven-segment display for the Basys 3. In this implementation, the display will support all hexadecimal digits. A simple counter that increments on push of the center button is included to ensure the display is working properly.

The four digits of the seven-segment display on the Basys 3 share a common anode and common cathodes. This means if we want to display four different digits, we have to cycle through each of the digits one by one. Consequently, this also means that we will need a refresh time that is quick enough for the LEDs to dim significantly (otherwise there will be flickering). The Basys 3 documentation suggests a refresh frequency between 1 kHz and 60 Hz (or a refresh every 1 to 16 ms). Additionally, all signals are active low.

## Seven-Segment Top (ss_top)
The top-level module is responsible for routing the I/O signals, generating a clock enable.

In this project, we need to manage the signals for the clock (`clk`), display (anodes `an`, and segments `seg`), button for incremeneting the value displayed (the center button `btnC`), and the reset switch (SW15 `sw`).

The main clock on the Basys 3 operates at 100 MHz. This is substantially faster than the suggested 60 Hz to 1 kHz range, and operating the seven-segment display at 100 MHz seems to make it extremely bright. I decided to play it safe and introduce a clock enable generator that pulses approximately once every millisecond.

The (output) display signals can be directly routed to the controller.

The button and reset switches, however, are asynchronous signals, and we would like to keep things synchronous, so we will use synchronizers (the same ones for CDCs) to get synchronous versions of these signals. There is also the issue of button debouncing: when a button is pushed, the signal might bounce between high and low a number of times before it stabilizes, and if the clock (and therefore sampling rate) is fast enough, it will cause a rising edge to be detected multiple times.

## Clock Enable Generator (clk_en_generator)
To go from 1 MHz down to 1 kHz (or lower), the clock frequency needs to be divided by a factor of 100,000. One way we could approach this is by using a clock divider. However, this is not ideal as we would be undoing all clock optimizations made by the manufacturer, and if the hardware is not designed in a way to allow for register clock pins to be re-routed, we would be using LUTs to simulate registers. Instead, the approach taken was to use a clock enable; instead of generating a new ~1 kHz clock signal, we will use the original 100 MHz clock, but signal to the registers to only respond to 1 clock cycle every 100,000 cycles. This way, we still only have one clock edge every ~1 ms. 

$\lceil\log_2{100000}\rceil = 17$, so we will need a 17 bit counter (which results in around 763 Hz). We then check the value in the counter, and if it is a particular value (could be any variety of values depending on whether it is a up-counter, down-counter, etc.), and it would require a 17-bit comparator. Alternatively, we can check for the 0-to-1 transition (or 1-to-0 transition) of the counter's MSB. This transition only occurs once per full range of values, and would avoid the large comparator for the price of a register, an AND gate, and a NOT gate (the gates can be implemented as a LUT2). To give some concrete numbers, the synthesis reports state that the edge detection method resulted in 1 more register, and 3 less LUTs. The downside is now we have to open up an extra port on the modules that use the slower clock rather than just replacing their clock signals. 

There is an additional consideration when using an edge detector rather than a comparator: when using a comparator and the reset is high, we can initialize the counter to the value the comparator is looking for, allowing all synchronous logic to continue propagating signals when the clock enable experiences a reset. This is important if using synchronous resets, as registers must continue being sensitive to the clock, otherwise the registers will not be reset.

## Synchronizer (synchronizer)
The synchronizer is just a simple flip-flop chain to debounce asynchronous inputs (such as the button and the switch), and to reduce the possibility of metastability (similar to CDCs). The chain lengths are only two flip-flops long, which should be sufficient to handle metastability issues.

The synchronizer module also contains a clock enable port so the effective clock speed can be reduced. This is for button debouncing, which wants a slower clock frequency so the fluctuations do not get sampled. The clock enable is used for the button, but not for the switch (reset signal). This is because the clock enable generator is also sensitive to the reset signal (otherwise we would have an unknown initial counter state - although this technically is not much of an issue when implemented in real circuitry). If the reset synchronizer was also sensitive to the clock enable signal, when the reset signal goes high, the clock enable would go to zero (because we are implementing the clock enable using an edge detector), causing even the reset circuit to effectively receive no clock signal, and when the reset signal goes low, the reset synchronizer does not update. If we do not address this, the end result is whenever SW15 is switched on, the circuit will enter a reset state, but will not be able to come out of it once switched off. 

To solve this, we can constantly pull the reset synchronizer's clock enable pin high. This reverses the efforts to debounce the signal, but the reset and clock enable signals are no longer co-dependent, and so the circuit can recover from the reset state. This should be okay because even if we do get debouncing, once the first rising edge comes in, the circuit should be entering a known state, and it does not really matter how many times it enters this state, as long as it has at least once. When testing the design on the board, the reset worked as expected, and it appears the lack of debouncing on the reset is acceptable.

The button signal does not have this problem, and so we can use the clock enable without issue. Debouncing involves slowing down the sampling rate of the registers capturing the input signal so we do not see multiple rising edges in the synchronizer output. Because the clock enable signal is already at around 763 Hz, it can be used to avoid introducing another counter. Testing on the board suggests that this sampling rate is slow enough.

## Edge Detector (edge_detector)
Suppose we press and hold the center button. Once the signal propagates through the synchronizer, the signal will be constantly high and the counter will keep increasing. However, we want the button to only increment once per push. Therefore, we must introduce a block that generates a one cycle pulse only when it observes a rising edge.

The solution is very simple: we just need to pipe the signal into an extra register (saving the state of the signal from the previous clock), and comparing it with the current state of the signal. If the previous state was 0, and the current state is 1, we know a rising edge just occurred. We can also use the comparisons between the two states to determine if a falling edge occurred, or if the signal is being held high or low.

## Seven-Segment Controller (ss_controller)
The controller has to determine which digit is to be updated, with what value, and determine which cathodes should be on or off to represent that value on the display. 

To determine which digit is to be updated, a ring counter is used. This is convenient becuase we can set up the counter such that the 4-bit value can be directly used as the anode signal.

To determine which of the four 4-bit values is to be used in the current cycle, we can use a mux with the anode index as the select signal. There is a slight problem, though: the ring counter is a 4-bit value and we have to convert it into a 2-bit binary value representing the index of the current digit. Luckily, this is a pretty small set of values, and can be easily solved on a piece of paper using K-maps:

$1110 \rightarrow 00$  
$1101 \rightarrow 01$  
$1011 \rightarrow 10$  
$0111 \rightarrow 11$  

Note that the anode values are active low, and any entries not listed are don't cares (we should never have a situation where there is not only one 0 in the anode bits). Solving the K-maps results in:
```verilog
index[1] = anode_bits_o[1] & anode_bits_o[0];
index[0] = anode_bits_o[2] & anode_bits_o[0];
```

The conversion from binary to the corresponding cathode bits of the hexadecimal symbol can be represented as a decoder / series of LUTs.

## Ring Counter (ring_counter)
This ring counter is used to cycle through the digits of the display.

There a couple ways to implement a ring counter. One way is to use to do the following:
```verilog
out <= in << NUM_SHIFT | in >> (NUM_BITS - NUM_SHIFT);
```

While this approach is simple and works for a one-hot ring counter, the anodes are active low, meaning we actually want all bits to be high except for one. We would need to do a bit-wise AND instead of the bit-wise OR in the Verilog above.

However, ideally we want to use a shift register as it requires no additional logic (we need only the registers), and we just need to load a one-cold pattern on reset. We can accomplish this by using the following:
```verilog
if (reset) out <= INIT_PATTERN;
else for (int i = 0; i < NUM_BITS; i++) out[i] <= i == 0 ? out[NUM_BITS-1] : out[i-1];
```

Checking elaboration confirms that this is recognized as a shift register, and we no longer require the additional logic.

## Binary-to-Seven-Segment Decoder (bss_decoder)
This module is just a 4-to-7 decoder, where the input is a 4-bit binary value, and the output is a 7-bit value of the corresponding symbol. This value can then be sent to the cathode ports.
