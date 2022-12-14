transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/ram.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/z.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/tr.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/top.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/r.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/pc.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/ir.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/dr.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/cpu.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/control.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/ar.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/alu.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/ac.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/light_show.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/clk_div.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/CPU_Controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/rtl/qtsj.v}

vlog -vlog01compat -work work +incdir+C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/simulation/modelsim {C:/Users/HP/Desktop/aaa/test/PCO_complex_stu/simulation/modelsim/top.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  top_vlg_tst

add wave *
view structure
view signals
run -all
