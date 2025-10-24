# clock
create_clock -period 5.000 [get_ports sys_clk_clk_p]
set_property PACKAGE_PIN R4 [get_ports sys_clk_clk_p]
set_property IOSTANDARD DIFF_SSTL15 [get_ports sys_clk_clk_p]

# led g
set_property PACKAGE_PIN H15 [get_ports led_g]
set_property IOSTANDARD LVCMOS33 [get_ports led_g]

# led r
set_property PACKAGE_PIN J15 [get_ports led_r]
set_property IOSTANDARD LVCMOS33 [get_ports led_r]

##btn0
set_property PACKAGE_PIN P15 [get_ports btn0]
set_property IOSTANDARD LVCMOS33 [get_ports btn0]

#TX TO USB 232 IC RX ######################################
set_property PACKAGE_PIN R18 [get_ports rs232_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports rs232_rxd]

#RX TO USB 232 IC TX ######################################
set_property PACKAGE_PIN T18 [get_ports rs232_txd]
set_property IOSTANDARD LVCMOS33 [get_ports rs232_txd]

# I2C SCL - E22 pin, pull-up enabled
set_property PACKAGE_PIN E22 [get_ports iic0_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic0_scl_io]
set_property PULLUP true [get_ports iic0_scl_io]

# I2C SDA - D22 pin, pull-up enabled
set_property PACKAGE_PIN D22 [get_ports iic0_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic0_sda_io]
set_property PULLUP true [get_ports iic0_sda_io]

#HDMI IN RESET
set_property PACKAGE_PIN F15 [get_ports hdmirst1]
set_property IOSTANDARD LVCMOS33 [get_ports hdmirst1]

# I2C SDA OUT
set_property PACKAGE_PIN L19 [get_ports iic1_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic1_scl_io]
set_property PULLUP true [get_ports iic1_scl_io]

# I2C SCL OUT 
set_property PACKAGE_PIN L20 [get_ports iic1_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports iic1_sda_io]
set_property PULLUP true [get_ports iic1_sda_io]

#HDMI IN RESET
set_property PACKAGE_PIN K18 [get_ports hdmirst2]
set_property IOSTANDARD LVCMOS33 [get_ports hdmirst2]

set_property PACKAGE_PIN J20 [get_ports hdmi_out_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports hdmi_out_vsync]
set_property PACKAGE_PIN J21 [get_ports sil9022_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sil9022_clk]
set_property IOSTANDARD LVCMOS33 [get_ports hdmi_out_active_video]
set_property IOSTANDARD LVCMOS33 [get_ports hdmi_out_hsync]
set_property PACKAGE_PIN J19 [get_ports hdmi_out_hsync]
set_property PACKAGE_PIN H19 [get_ports hdmi_out_active_video]
set_property PACKAGE_PIN H13 [get_ports {hdmi_out_data[0]}]
set_property PACKAGE_PIN G13 [get_ports {hdmi_out_data[1]}]
set_property PACKAGE_PIN G15 [get_ports {hdmi_out_data[2]}]
set_property PACKAGE_PIN G16 [get_ports {hdmi_out_data[3]}]
set_property PACKAGE_PIN J14 [get_ports {hdmi_out_data[4]}]
set_property PACKAGE_PIN H14 [get_ports {hdmi_out_data[5]}]
set_property PACKAGE_PIN G17 [get_ports {hdmi_out_data[6]}]
set_property PACKAGE_PIN G18 [get_ports {hdmi_out_data[7]}]
set_property PACKAGE_PIN H17 [get_ports {hdmi_out_data[8]}]
set_property PACKAGE_PIN H18 [get_ports {hdmi_out_data[9]}]
set_property PACKAGE_PIN J22 [get_ports {hdmi_out_data[10]}]
set_property PACKAGE_PIN H22 [get_ports {hdmi_out_data[11]}]
set_property PACKAGE_PIN H20 [get_ports {hdmi_out_data[12]}]
set_property PACKAGE_PIN G20 [get_ports {hdmi_out_data[13]}]
set_property PACKAGE_PIN K21 [get_ports {hdmi_out_data[14]}]
set_property PACKAGE_PIN K22 [get_ports {hdmi_out_data[15]}]
set_property PACKAGE_PIN L18 [get_ports {hdmi_out_data[16]}]
set_property PACKAGE_PIN M18 [get_ports {hdmi_out_data[17]}]
set_property PACKAGE_PIN N18 [get_ports {hdmi_out_data[18]}]
set_property PACKAGE_PIN N19 [get_ports {hdmi_out_data[19]}]
set_property PACKAGE_PIN N20 [get_ports {hdmi_out_data[20]}]
set_property PACKAGE_PIN M20 [get_ports {hdmi_out_data[21]}]
set_property PACKAGE_PIN K13 [get_ports {hdmi_out_data[22]}]
set_property PACKAGE_PIN K14 [get_ports {hdmi_out_data[23]}]
set_property IOSTANDARD LVCMOS33 [get_ports {hdmi_out_data[*]}]
