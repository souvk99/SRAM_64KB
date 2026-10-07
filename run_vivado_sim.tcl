open_project [file normalize "SRAM_64KB.xpr"]
set_property top sram_64kb [get_filesets sources_1]
set_property top tb_sram_64kb [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
add_wave -r /
run all
save_wave_config [file normalize "sram_64kb.wcfg"]
