env:
	vlib work
	vmap work work
compile:
	vlog -sv -f files_exe.f -timescale "10ns/10ps" +cover=sbcf
run:
	vsim -c -novopt -coverage ${top}
clean:
	rm -rf work modelsim.ini out.mem
