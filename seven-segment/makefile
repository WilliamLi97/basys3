RTL_SRC = $(shell find src -type f -name "*.sv")
BUILD_DIR = build
REPORTS_DIR = reports
SCRIPTS_DIR = scripts

lint: $(BUILD_DIR)
	@vivado -mode batch -source $(SCRIPTS_DIR)/lint.tcl -log $(BUILD_DIR)/lint.log -nojournal

elaborate: $(BUILD_DIR)
	@vivado -mode batch -source $(SCRIPTS_DIR)/elaborate.tcl -log $(BUILD_DIR)/elaborate.log -nojournal

synthesis: $(BUILD_DIR)/synthesis.dcp

place: $(BUILD_DIR)/place.dcp

route: $(BUILD_DIR)/route.dcp

bitstream: $(BUILD_DIR)/bitstream.bit

program: $(BUILD_DIR)/bitstream.bit
	@vivado -mode batch -source $(SCRIPTS_DIR)/program.tcl -log $(BUILD_DIR)/program.log -nojournal

$(BUILD_DIR):
	@mkdir $(BUILD_DIR)

$(REPORTS_DIR):
	@mkdir $(REPORTS_DIR)

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

clean_reports:
	@rm -rf reports

clean_logs:
	@rm -f build/*.log

clean_build:
	@rm -rf build

.PHONY:
clean:
	@rm -rf build reports
