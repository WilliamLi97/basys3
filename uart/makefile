RTL_SRC = $(shell find src -type f -name "*.sv")
SIM_SRC = verif/uart_tx_tb.sv
SIM_DIR = sim
BUILD_DIR = build
REPORTS_DIR = reports
SCRIPTS_DIR = scripts

sim: $(SIM_DIR)/sim.vcd

waveform: $(SIM_DIR)/sim.vcd
	@gtkwave $(SIM_DIR)/sim.vcd

lint: $(RTL_SRC)
	@mkdir -p $(BUILD_DIR)
	@vivado -mode batch -source $(SCRIPTS_DIR)/lint.tcl -log $(BUILD_DIR)/lint.log -nojournal

elaborate:
	@mkdir -p $(BUILD_DIR)
	@vivado -mode batch -source $(SCRIPTS_DIR)/elaborate.tcl -log $(BUILD_DIR)/elaborate.log -nojournal

synthesis: $(BUILD_DIR)/synthesis.dcp

place: $(BUILD_DIR)/place.dcp

route: $(BUILD_DIR)/route.dcp

bitstream: $(BUILD_DIR)/bitstream.bit

program: $(BUILD_DIR)/bitstream.bit
	@vivado -mode batch -source $(SCRIPTS_DIR)/program.tcl -log $(BUILD_DIR)/program.log -nojournal

$(SIM_DIR)/sim.vcd: $(RTL_SRC) $(SIM_SRC)
	@mkdir -p $(SIM_DIR)
	@iverilog -g2012 -o $(SIM_DIR)/sim -D 'DUMPFILE_NAME="$(SIM_DIR)/sim.vcd"' $(SIM_SRC) $(RTL_SRC)
	@vvp $(SIM_DIR)/sim

$(BUILD_DIR)/synthesis.dcp: $(RTL_SRC)
	@mkdir -p $(BUILD_DIR)
	@mkdir -p $(REPORTS_DIR)
	@vivado -mode batch -source $(SCRIPTS_DIR)/synthesis.tcl -log $(BUILD_DIR)/synthesis.log -nojournal

$(BUILD_DIR)/place.dcp: $(BUILD_DIR)/synthesis.dcp
	@vivado -mode batch -source $(SCRIPTS_DIR)/place.tcl -log $(BUILD_DIR)/place.log -nojournal

$(BUILD_DIR)/route.dcp: $(BUILD_DIR)/place.dcp
	@vivado -mode batch -source $(SCRIPTS_DIR)/route.tcl -log $(BUILD_DIR)/route.log -nojournal

$(BUILD_DIR)/bitstream.bit: $(BUILD_DIR)/route.dcp
	@vivado -mode batch -source $(SCRIPTS_DIR)/bitstream.tcl -log $(BUILD_DIR)/bitstream.log -nojournal

clean_sim:
	@rm -rf sim

clean_logs:
	@rm -f build/*.log

clean_build:
	@rm -rf build

clean_reports:
	@rm -rf reports

.PHONY:
clean:
	@rm -rf build reports sim
