env:
	vlib work
	vmap work work
clean:
	rm -rf transcript work modelsim.ini
compile:
	vlog -sv -f filelist.f
run:
	vsim -c -novopt ${top}
help:
	cat Makefile
