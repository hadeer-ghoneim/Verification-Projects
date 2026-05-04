vlib work
vlog -f scr_files.list
vsim -voptargs=+acc work.spi_slave_top -classdebug -uvmcontrol=all
add wave /spi_slave_top/spi_if/*
run -all

coverage save spi_slave_coverage.ucdb
vcover report -html -htmldir coverage_html spi_slave_coverage.ucdb
vcover report -details -file coverage_report.txt spi_slave_coverage.ucdb

# Write functional coverage to file
coverage report -file functional_coverage.txt -byfile -detail -cvg
