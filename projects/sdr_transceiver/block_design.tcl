# Create processing_system7
cell xilinx.com:ip:processing_system7:5.5 ps_0 {
  PCW_IMPORT_BOARD_PRESET cfg/red_pitaya.xml
} {
  M_AXI_GP0_ACLK ps_0/FCLK_CLK0
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {
  make_external {FIXED_IO, DDR}
  Master Disable
  Slave Disable
} [get_bd_cells ps_0]

# Create proc_sys_reset
cell xilinx.com:ip:proc_sys_reset:5.0 rst_0

############
# Receiver #
############

# Create axis_red_pitaya_adc
cell pavel-demin:user:axis_red_pitaya_adc:1.0 adc_0 {} {
  adc_clk_p adc_clk_p_i
  adc_clk_n adc_clk_n_i
  adc_dat_a adc_dat_a_i
  adc_dat_b adc_dat_b_i
  adc_csn adc_csn_o
}

# Create c_counter_binary
cell xilinx.com:ip:c_counter_binary:12.0 cntr_0 {
  Output_Width 32
} {
  CLK adc_0/adc_clk
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_0 {
  DIN_WIDTH 32 DIN_FROM 26 DIN_TO 26 DOUT_WIDTH 1
} {
  Din cntr_0/Q
  Dout led_o
}

# Create axi_cfg_register
cell pavel-demin:user:axi_cfg_register:1.0 cfg_0 {
  CFG_DATA_WIDTH 160
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins cfg_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]
set_property OFFSET 0x40000000 [get_bd_addr_segs ps_0/Data/SEG_cfg_0_reg0]

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_1 {
  DIN_WIDTH 160 DIN_FROM 0 DIN_TO 0 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_2 {
  DIN_WIDTH 160 DIN_FROM 1 DIN_TO 1 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_3 {
  DIN_WIDTH 160 DIN_FROM 2 DIN_TO 2 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_4 {
  DIN_WIDTH 160 DIN_FROM 3 DIN_TO 3 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_5 {
  DIN_WIDTH 160 DIN_FROM 4 DIN_TO 4 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_6 {
  DIN_WIDTH 160 DIN_FROM 5 DIN_TO 5 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_7 {
  DIN_WIDTH 160 DIN_FROM 6 DIN_TO 6 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_8 {
  DIN_WIDTH 160 DIN_FROM 7 DIN_TO 7 DOUT_WIDTH 1
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_9 {
  DIN_WIDTH 160 DIN_FROM 31 DIN_TO 16 DOUT_WIDTH 16
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_10 {
  DIN_WIDTH 160 DIN_FROM 61 DIN_TO 32 DOUT_WIDTH 30
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_11 {
  DIN_WIDTH 160 DIN_FROM 93 DIN_TO 64 DOUT_WIDTH 30
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_12 {
  DIN_WIDTH 160 DIN_FROM 127 DIN_TO 96 DOUT_WIDTH 32
} {
  Din cfg_0/cfg_data
}

# Create xlslice
cell xilinx.com:ip:xlslice:1.0 slice_13 {
  DIN_WIDTH 160 DIN_FROM 157 DIN_TO 128 DOUT_WIDTH 30
} {
  Din cfg_0/cfg_data
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_0

# Create axis_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_0 {} {
  S_AXIS adc_0/M_AXIS
  s_axis_aclk adc_0/adc_clk
  s_axis_aresetn const_0/dout
  m_axis_aclk ps_0/FCLK_CLK0
  m_axis_aresetn slice_1/Dout
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter:1.1 subset_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 8
  TDATA_REMAP {tdata[30:16],49'b0000000000000000000000000000000000000000000000000}
} {
  S_AXIS fifo_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_0 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 8
} {
  S_AXIS subset_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create axis_phase_generator
cell pavel-demin:user:axis_phase_generator:1.0 phase_0 {
  AXIS_TDATA_WIDTH 32
  PHASE_WIDTH 30
} {
  cfg_data slice_10/Dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_2/Dout
}

# Create cordic
cell xilinx.com:ip:cordic:6.0 cordic_0 {
  INPUT_WIDTH.VALUE_SRC USER
  PIPELINING_MODE Optimal
  PHASE_FORMAT Scaled_Radians
  INPUT_WIDTH 32
  OUTPUT_WIDTH 32
  ROUND_MODE Round_Pos_Neg_Inf
  COMPENSATION_SCALING Embedded_Multiplier
} {
  S_AXIS_CARTESIAN bcast_0/M00_AXIS
  S_AXIS_PHASE phase_0/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_1 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[63:32]}
  M01_TDATA_REMAP {tdata[31:0]}
} {
  S_AXIS cordic_0/M_AXIS_DOUT
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_1

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_0 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  FIXED_OR_INITIAL_RATE 3125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
} {
  S_AXIS_DATA bcast_1/M00_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_1 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  FIXED_OR_INITIAL_RATE 3125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
} {
  S_AXIS_DATA bcast_1/M01_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_0 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_0/M_AXIS_DATA
  S01_AXIS cic_1/M_AXIS_DATA
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler:7.2 fir_0 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-1.6477803126673e-08, -4.73241780719431e-08, -7.93893762402556e-10, 3.09352974037909e-08, 1.86287085664036e-08, 3.27498519682074e-08, -6.30103868644643e-09, -1.52285727032021e-07, -8.30466648048943e-08, 3.14547654032246e-07, 3.05634502525888e-07, -4.74191327710916e-07, -7.13516534402831e-07, 5.47346324460726e-07, 1.33466461110536e-06, -4.14159890528364e-07, -2.1505811145434e-06, -6.77370237910856e-08, 3.07556819541765e-06, 1.0370505355367e-06, -3.94449781984647e-06, -2.59199328674329e-06, 4.51552941227161e-06, 4.74797884206863e-06, -4.49299646667899e-06, -7.39848885869424e-06, 3.57228568227438e-06, 1.02898719826237e-05, -1.50387150681059e-06, -1.30212988742999e-05, -1.83214145429432e-06, 1.50786566301658e-05, 6.35486748279423e-06, -1.59062147434029e-05, -1.17328848104954e-05, 1.50114974785596e-05, 1.7372574759798e-05, -1.20947251948756e-05, -2.24676444755539e-05, 7.16993553114205e-06, 2.61041439270352e-05, -6.63532856011916e-07, -2.74301832391597e-05, -6.55092457696323e-06, 2.58651810404159e-05, 1.32048515273499e-05, -2.1317677174528e-05, -1.77907085402518e-05, 1.436676627647e-05, 1.88203678903225e-05, -6.35774583750282e-06, -1.51630391175939e-05, -6.34777143600336e-07, 6.41598241707925e-06, 4.00817100547114e-06, 6.7578664887829e-06, -1.00568533107808e-06, -2.24038826835638e-05, -1.07627151802942e-05, 3.72348184414005e-05, 3.2701655435069e-05, -4.6862352007415e-05, -6.46546125464121e-05, 4.62618689241764e-05, 0.000104405214397357, -3.05417940111896e-05, -0.00014746208007481, -4.11988278994384e-06, 0.000187192202366089, 5.94739008909315e-05, -0.000215382226866196, -0.00013430624011575, 0.000223231771512739, 0.000223842528685186, -0.00020270758420517, -0.000319634221298429, 0.000148101277087398, 0.000410063948518449, -5.75617367437652e-05, -0.000481530969730516, -6.56786076534709e-05, 0.000520268200692712, 0.000212671507961849, -0.000514635575661532, -0.000369018523112966, 0.000457482080116169, 0.000515991288315472, -0.000348488643095732, -0.000632902740484264, 0.00019565498787737, 0.000700212218756191, -1.57980429849499e-05, -0.000703228531136762, -0.000166384366137857, 0.000635864178458659, 0.000320845304353809, -0.00050382612172403, -0.000416271542916756, 0.000326578173694164, 0.000425408104410912, -0.000137467845920125, -0.000331057773200808, -1.84374581160459e-05, 0.000131957667600652, 8.89996453664623e-05, 0.000152412457008811, -2.20123592827393e-05, -0.00047912778003751, -0.000226160900022274, 0.000781626283194707, 0.000680353983714684, -0.000973879698174067, -0.0013374715808644, 0.000957544253972286, 0.00215830757707662, -0.000633087262805248, -0.00306249739852838, -8.62724802143682e-05, 0.00392762459059574, 0.00125893562455588, -0.00459335728493682, -0.00289915526565417, 0.00487097490634664, 0.00496287757956818, -0.00455803664391539, -0.00733691415380758, 0.00345728084505496, 0.00983286212154261, -0.00139823904366904, -0.0121865678116845, -0.00174040610912354, 0.014062746409744, 0.00600874643597289, -0.0150660660015954, -0.01137053420847, 0.014748826587083, 0.0176878324514315, -0.0126189063584745, -0.0247140011981246, 0.00813110931172791, 0.0320875384224486, -0.000645073733882858, -0.0393183241035692, -0.0106929061200545, 0.0457380625458776, 0.0272512703315898, -0.0503228989148367, -0.051717794358685, 0.0510207185249084, 0.0905740901172399, -0.0416086426627032, -0.163752839902141, -0.0108030211279308, 0.356394916826446, 0.554828643152604, 0.356394916826445, -0.0108030211279307, -0.163752839902141, -0.0416086426627032, 0.0905740901172398, 0.0510207185249084, -0.0517177943586849, -0.0503228989148367, 0.0272512703315898, 0.0457380625458776, -0.0106929061200545, -0.0393183241035692, -0.000645073733882855, 0.0320875384224486, 0.00813110931172788, -0.0247140011981246, -0.0126189063584744, 0.0176878324514315, 0.0147488265870829, -0.01137053420847, -0.0150660660015954, 0.00600874643597288, 0.014062746409744, -0.00174040610912354, -0.0121865678116845, -0.00139823904366905, 0.00983286212154259, 0.00345728084505496, -0.00733691415380758, -0.00455803664391539, 0.00496287757956815, 0.00487097490634665, -0.00289915526565417, -0.00459335728493682, 0.00125893562455588, 0.00392762459059574, -8.62724802143759e-05, -0.00306249739852838, -0.000633087262805254, 0.00215830757707662, 0.000957544253972288, -0.0013374715808644, -0.000973879698174062, 0.000680353983714686, 0.000781626283194706, -0.000226160900022277, -0.0004791277800375, -2.20123592827382e-05, 0.000152412457008803, 8.89996453664583e-05, 0.000131957667600656, -1.84374581160419e-05, -0.000331057773200813, -0.000137467845920129, 0.000425408104410916, 0.000326578173694167, -0.000416271542916745, -0.000503826121724035, 0.000320845304353799, 0.000635864178458661, -0.00016638436613785, -0.000703228531136761, -1.57980429849744e-05, 0.000700212218756191, 0.000195654987877385, -0.000632902740484265, -0.000348488643095741, 0.00051599128831547, 0.000457482080116171, -0.000369018523112963, -0.000514635575661537, 0.000212671507961847, 0.000520268200692713, -6.56786076534692e-05, -0.000481530969730511, -5.75617367437655e-05, 0.000410063948518448, 0.000148101277087398, -0.000319634221298427, -0.00020270758420517, 0.000223842528685188, 0.000223231771512738, -0.000134306240115752, -0.000215382226866195, 5.94739008909304e-05, 0.000187192202366089, -4.11988278994438e-06, -0.00014746208007481, -3.0541794011189e-05, 0.000104405214397356, 4.62618689241748e-05, -6.46546125464118e-05, -4.68623520074133e-05, 3.27016554350691e-05, 3.72348184413998e-05, -1.07627151802942e-05, -2.24038826835659e-05, -1.00568533107809e-06, 6.75786648878254e-06, 4.00817100547117e-06, 6.41598241707818e-06, -6.34777143600528e-07, -1.51630391175948e-05, -6.35774583750266e-06, 1.88203678903231e-05, 1.436676627647e-05, -1.77907085402514e-05, -2.13176771745279e-05, 1.32048515273498e-05, 2.58651810404156e-05, -6.55092457696207e-06, -2.74301832391597e-05, -6.63532856012472e-07, 2.61041439270352e-05, 7.16993553114219e-06, -2.24676444755538e-05, -1.20947251948757e-05, 1.73725747597979e-05, 1.50114974785595e-05, -1.17328848104953e-05, -1.5906214743403e-05, 6.35486748279425e-06, 1.50786566301659e-05, -1.83214145429435e-06, -1.30212988742996e-05, -1.50387150681058e-06, 1.02898719826235e-05, 3.57228568227438e-06, -7.3984888586941e-06, -4.49299646667903e-06, 4.74797884206855e-06, 4.51552941227162e-06, -2.59199328674326e-06, -3.94449781984647e-06, 1.03705053553668e-06, 3.07556819541762e-06, -6.77370237911482e-08, -2.15058111454339e-06, -4.1415989052838e-07, 1.33466461110535e-06, 5.47346324460698e-07, -7.13516534402833e-07, -4.74191327710884e-07, 3.05634502525885e-07, 3.14547654032223e-07, -8.30466648048881e-08, -1.52285727032016e-07, -6.30103868644584e-09, 3.27498519682033e-08, 1.86287085664046e-08, 3.0935297403796e-08, -7.93893762403235e-10, -4.7324178071939e-08, -1.64778031266738e-08}
  COEFFICIENT_WIDTH 32
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_PATHS 2
  RATESPECIFICATION Input_Sample_Period
  SAMPLEPERIOD 3125
  OUTPUT_ROUNDING_MODE Truncate_LSBs
  OUTPUT_WIDTH 32
} {
  S_AXIS_DATA comb_0/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen:8.2 bram_0 {
  MEMORY_TYPE True_Dual_Port_RAM
  USE_BRAM_BLOCK Stand_Alone
  USE_BYTE_WRITE_ENABLE true
  BYTE_SIZE 8
  WRITE_WIDTH_A 64
  WRITE_DEPTH_A 512
  WRITE_WIDTH_B 32
  WRITE_DEPTH_B 1024
  ENABLE_A Always_Enabled
  ENABLE_B Always_Enabled
  REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
}

# Create axis_bram_writer
cell pavel-demin:user:axis_bram_writer:1.0 writer_0 {
  AXIS_TDATA_WIDTH 64
  BRAM_DATA_WIDTH 64
  BRAM_ADDR_WIDTH 9
} {
  S_AXIS fir_0/M_AXIS_DATA
  BRAM_PORTA bram_0/BRAM_PORTA
  aclk ps_0/FCLK_CLK0
  aresetn slice_2/Dout
}

# Create axi_bram_reader
cell pavel-demin:user:axi_bram_reader:1.0 reader_0 {
  AXI_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  BRAM_DATA_WIDTH 32
  BRAM_ADDR_WIDTH 10
} {
  BRAM_PORTA bram_0/BRAM_PORTB
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins reader_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_reader_0_reg0]
set_property OFFSET 0x40002000 [get_bd_addr_segs ps_0/Data/SEG_reader_0_reg0]

###############
# Panadapter  #
###############


# Create axis_phase_generator
cell pavel-demin:user:axis_phase_generator:1.0 phase_1 {
  AXIS_TDATA_WIDTH 32
  PHASE_WIDTH 30
} {
  cfg_data slice_11/Dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_3/Dout
}

# Create cordic
cell xilinx.com:ip:cordic:6.0 cordic_1 {
  INPUT_WIDTH.VALUE_SRC USER
  PIPELINING_MODE Optimal
  PHASE_FORMAT Scaled_Radians
  INPUT_WIDTH 32
  OUTPUT_WIDTH 32
  ROUND_MODE Round_Pos_Neg_Inf
  COMPENSATION_SCALING Embedded_Multiplier
} {
  S_AXIS_CARTESIAN bcast_0/M01_AXIS
  S_AXIS_PHASE phase_1/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_2 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[63:32]}
  M01_TDATA_REMAP {tdata[31:0]}
} {
  S_AXIS cordic_1/M_AXIS_DOUT
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 rate_0 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_9/Dout
  aclk ps_0/FCLK_CLK0
}

# Create axis_packetizer
cell pavel-demin:user:axis_packetizer:1.0 pktzr_0 {
  AXIS_TDATA_WIDTH 16
  CNTR_WIDTH 1
  CONTINUOUS FALSE
} {
  S_AXIS rate_0/M_AXIS
  cfg_data const_1/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 rate_1 {
  AXIS_TDATA_WIDTH 16
} {
  cfg_data slice_9/Dout
  aclk ps_0/FCLK_CLK0
}

# Create axis_packetizer
cell pavel-demin:user:axis_packetizer:1.0 pktzr_1 {
  AXIS_TDATA_WIDTH 16
  CNTR_WIDTH 1
  CONTINUOUS FALSE
} {
  S_AXIS rate_1/M_AXIS
  cfg_data const_1/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_2 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 125
  MAXIMUM_RATE 1250
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_2/M00_AXIS
  S_AXIS_CONFIG pktzr_0/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_3 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Decimation
  NUMBER_OF_STAGES 6
  SAMPLE_RATE_CHANGES Programmable
  MINIMUM_RATE 125
  MAXIMUM_RATE 1250
  FIXED_OR_INITIAL_RATE 125
  INPUT_SAMPLE_FREQUENCY 125
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
  HAS_ARESETN true
} {
  S_AXIS_DATA bcast_2/M01_AXIS
  S_AXIS_CONFIG pktzr_1/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn slice_4/Dout
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_1 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_2/M_AXIS_DATA
  S01_AXIS cic_3/M_AXIS_DATA
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create fir_compiler
cell xilinx.com:ip:fir_compiler:7.2 fir_1 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-1.64776395523261e-08, -4.73223982493382e-08, -7.93114097748734e-10, 3.09341607494277e-08, 1.86268604565617e-08, 3.27485571200346e-08, -6.29908653657968e-09, -1.52279861575043e-07, -8.30460847858456e-08, 3.14535491822606e-07, 3.05626738325402e-07, -4.74172694219994e-07, -7.13495049416347e-07, 5.47323968241002e-07, 1.33462183148789e-06, -4.14140755019506e-07, -2.15051006195781e-06, -6.77410015715413e-08, 3.07546485446303e-06, 1.03702255417565e-06, -3.94436393706816e-06, -2.59191311589838e-06, 4.51537519422448e-06, 4.74782575774399e-06, -4.49284245797096e-06, -7.39824596121288e-06, 3.57216304293944e-06, 1.0289531398643e-05, -1.50382000963687e-06, -1.30208669437029e-05, -1.8320780740752e-06, 1.50781578706169e-05, 6.35464869916574e-06, -1.5905693254477e-05, -1.17324822432291e-05, 1.50110146034995e-05, 1.73719815499574e-05, -1.20943524633858e-05, -2.24668827259553e-05, 7.16974344173206e-06, 2.61032685003911e-05, -6.63576078703743e-07, -2.74292794572945e-05, -6.55062322922545e-06, 2.5864354889803e-05, 1.32043152416442e-05, -2.13170377303369e-05, -1.7790015052466e-05, 1.4366401658372e-05, 1.88196488042346e-05, -6.35769575620025e-06, -1.51624671610732e-05, -6.3454751890034e-07, 6.41574547942767e-06, 4.00779001049893e-06, 6.75760336386084e-06, -1.00538045567379e-06, -2.24030234065108e-05, -1.07626302618669e-05, 3.72333834565482e-05, 3.27008161208513e-05, -4.68605170112616e-05, -6.46526581514427e-05, 4.62599879903061e-05, 0.000104401861517261, -3.05403948192664e-05, -0.00014745720335074, -4.12013707266912e-06, 0.000187185910308468, 5.9472285269084e-05, -0.000215374917579779, -0.000134302073078784, 0.000223224152976694, 0.00022383529853513, -0.000202700646279518, -0.000319623716269056, 0.000148096208070561, 0.00041005036860653, -5.75597854424301e-05, -0.000481514995957391, -6.56763133492148e-05, 0.000520250999114949, 0.000212664164338231, -0.000514618719419215, -0.000369005842837135, 0.000457467389871147, 0.000515973656086604, -0.000348477939755869, -0.000632881279945779, 0.000195649794954827, 0.000700188749146281, -1.57992717633881e-05, -0.000703205392036612, -0.000166376697710665, 0.000635843920605569, 0.00032083226194399, -0.000503811084211153, -0.000416255319934634, 0.000326569991673316, 0.000425391875921946, -0.00013746695448704, -0.000331045335837557, -1.84322419198225e-05, 0.000131952870425038, 8.8991373620273e-05, 0.000152406451111629, -2.20059552576483e-05, -0.000479109327658611, -0.000226158943701414, 0.000781596108897923, 0.000680336287236396, -0.000973841573779158, -0.00133743086810108, 0.000957505429554979, 0.00215823795933061, -0.000633058497914659, -0.00306239583565753, -8.62773868301778e-05, 0.00392749237767837, 0.00125890086582158, -0.0045932013828814, -0.002899064621986, 0.00487080892138405, 0.00496271652177841, -0.00455788126865406, -0.00733667233358662, 0.00345716360480598, 0.00983253607996904, -0.00139819324342049, -0.0121861637129463, -0.00174034328863689, 0.014062282608939, 0.00600853672502155, -0.0150655751552465, -0.01137014160612, 0.0147483575782911, 0.0176872274320504, -0.0126185258485222, -0.0247131655485743, 0.00813090350262748, 0.0320864711007864, -0.000645151353472906, -0.0393170493516836, -0.0106924075067383, 0.0457366439777749, 0.0272501703222767, -0.0503214712404459, -0.0517158392679872, 0.0510195785361982, 0.0905708960358907, -0.0416085827802432, -0.163747940036716, -0.0107991247506511, 0.356391980570419, 0.554821620626239, 0.356391980570419, -0.0107991247506511, -0.163747940036716, -0.0416085827802432, 0.0905708960358907, 0.0510195785361982, -0.0517158392679871, -0.0503214712404459, 0.0272501703222767, 0.0457366439777748, -0.0106924075067384, -0.0393170493516836, -0.000645151353472902, 0.0320864711007864, 0.00813090350262744, -0.0247131655485743, -0.0126185258485222, 0.0176872274320504, 0.014748357578291, -0.01137014160612, -0.0150655751552464, 0.00600853672502154, 0.014062282608939, -0.00174034328863689, -0.0121861637129463, -0.0013981932434205, 0.00983253607996903, 0.00345716360480599, -0.00733667233358662, -0.00455788126865407, 0.00496271652177837, 0.00487080892138405, -0.00289906462198599, -0.0045932013828814, 0.00125890086582158, 0.00392749237767837, -8.62773868301858e-05, -0.00306239583565753, -0.000633058497914665, 0.00215823795933062, 0.000957505429554986, -0.00133743086810109, -0.00097384157377915, 0.000680336287236399, 0.000781596108897926, -0.000226158943701417, -0.000479109327658599, -2.20059552576474e-05, 0.000152406451111619, 8.89913736202697e-05, 0.000131952870425043, -1.84322419198184e-05, -0.000331045335837562, -0.000137466954487046, 0.000425391875921945, 0.000326569991673318, -0.000416255319934626, -0.000503811084211157, 0.000320832261943976, 0.000635843920605571, -0.000166376697710658, -0.000703205392036611, -1.57992717634175e-05, 0.000700188749146282, 0.000195649794954849, -0.00063288127994578, -0.000348477939755879, 0.000515973656086602, 0.000457467389871152, -0.000369005842837133, -0.00051461871941922, 0.00021266416433823, 0.00052025099911495, -6.5676313349214e-05, -0.000481514995957386, -5.75597854424309e-05, 0.00041005036860653, 0.000148096208070561, -0.000319623716269053, -0.000202700646279518, 0.00022383529853513, 0.000223224152976694, -0.000134302073078785, -0.000215374917579779, 5.94722852690836e-05, 0.000187185910308467, -4.1201370726696e-06, -0.000147457203350739, -3.05403948192655e-05, 0.00010440186151726, 4.62599879903048e-05, -6.46526581514424e-05, -4.68605170112612e-05, 3.27008161208512e-05, 3.72333834565472e-05, -1.07626302618669e-05, -2.24030234065122e-05, -1.00538045567376e-06, 6.75760336386114e-06, 4.00779001049914e-06, 6.41574547942654e-06, -6.34547518900236e-07, -1.51624671610739e-05, -6.35769575620011e-06, 1.88196488042347e-05, 1.43664016583718e-05, -1.77900150524658e-05, -2.13170377303367e-05, 1.32043152416438e-05, 2.58643548898028e-05, -6.55062322922483e-06, -2.74292794572945e-05, -6.63576078704085e-07, 2.61032685003909e-05, 7.16974344173231e-06, -2.24668827259554e-05, -1.20943524633859e-05, 1.73719815499574e-05, 1.50110146034996e-05, -1.1732482243229e-05, -1.59056932544774e-05, 6.35464869916573e-06, 1.5078157870617e-05, -1.83207807407521e-06, -1.30208669437035e-05, -1.50382000963686e-06, 1.02895313986436e-05, 3.57216304293944e-06, -7.39824596121333e-06, -4.49284245797099e-06, 4.74782575774417e-06, 4.51537519422448e-06, -2.59191311589829e-06, -3.94436393706815e-06, 1.03702255417562e-06, 3.07546485446302e-06, -6.77410015715271e-08, -2.15051006195779e-06, -4.14140755019505e-07, 1.33462183148789e-06, 5.47323968241007e-07, -7.13495049416342e-07, -4.7417269421995e-07, 3.05626738325399e-07, 3.1453549182257e-07, -8.30460847858442e-08, -1.52279861575044e-07, -6.29908653657931e-09, 3.27485571200189e-08, 1.86268604565597e-08, 3.09341607494308e-08, -7.93114097748315e-10, -4.73223982493358e-08, -1.64776395523266e-08}
  COEFFICIENT_WIDTH 32
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Decimation
  DECIMATION_RATE 2
  NUMBER_PATHS 2
  RATESPECIFICATION Input_Sample_Period
  SAMPLEPERIOD 125
  OUTPUT_ROUNDING_MODE Truncate_LSBs
  OUTPUT_WIDTH 32
} {
  S_AXIS_DATA comb_1/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_constant
cell pavel-demin:user:axis_constant:1.0 cfg_1 {
  AXIS_TDATA_WIDTH 32
} {
  cfg_data slice_12/Dout
  aclk ps_0/FCLK_CLK0
}

# Create axis_packetizer
cell pavel-demin:user:axis_packetizer:1.0 pktzr_2 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 1
  CONTINUOUS FALSE
} {
  S_AXIS cfg_1/M_AXIS
  cfg_data const_1/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_5/Dout
}

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_2 {
  CONST_WIDTH 12
  CONST_VAL 4095
}

# Create axis_packetizer
cell pavel-demin:user:axis_packetizer:1.0 pktzr_3 {
  AXIS_TDATA_WIDTH 32
  CNTR_WIDTH 12
  CONTINUOUS FALSE
} {
  S_AXIS fir_1/M_AXIS_DATA
  cfg_data const_2/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_6/Dout
}

# Create xfft
cell xilinx.com:ip:xfft:9.0 fft_0 {
  INPUT_WIDTH.VALUE_SRC USER
  TRANSFORM_LENGTH 4096
  TARGET_CLOCK_FREQUENCY 125
  TARGET_DATA_THROUGHPUT 1
  IMPLEMENTATION_OPTIONS radix_2_lite_burst_io
  RUN_TIME_CONFIGURABLE_TRANSFORM_LENGTH false
  INPUT_WIDTH 32
  PHASE_FACTOR_WIDTH 32
  SCALING_OPTIONS scaled
  ROUNDING_MODES convergent_rounding
  OUTPUT_ORDERING natural_order
  ARESETN true
} {
  S_AXIS_DATA pktzr_3/M_AXIS
  S_AXIS_CONFIG pktzr_2/M_AXIS
  aclk ps_0/FCLK_CLK0
  aresetn slice_5/Dout
}

# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen:8.2 bram_1 {
  MEMORY_TYPE True_Dual_Port_RAM
  USE_BRAM_BLOCK Stand_Alone
  USE_BYTE_WRITE_ENABLE true
  BYTE_SIZE 8
  WRITE_WIDTH_A 64
  WRITE_DEPTH_A 4096
  WRITE_WIDTH_B 32
  WRITE_DEPTH_B 8192
  ENABLE_A Always_Enabled
  ENABLE_B Always_Enabled
  REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
}

# Create axis_bram_writer
cell pavel-demin:user:axis_bram_writer:1.0 writer_1 {
  AXIS_TDATA_WIDTH 64
  BRAM_DATA_WIDTH 64
  BRAM_ADDR_WIDTH 12
} {
  S_AXIS fft_0/M_AXIS_DATA
  BRAM_PORTA bram_1/BRAM_PORTA
  aclk ps_0/FCLK_CLK0
  aresetn slice_3/Dout
}

# Create axi_bram_reader
cell pavel-demin:user:axi_bram_reader:1.0 reader_1 {
  AXI_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  BRAM_DATA_WIDTH 32
  BRAM_ADDR_WIDTH 13
} {
  BRAM_PORTA bram_1/BRAM_PORTB
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins reader_1/S_AXI]

set_property RANGE 32K [get_bd_addr_segs ps_0/Data/SEG_reader_1_reg0]
set_property OFFSET 0x40010000 [get_bd_addr_segs ps_0/Data/SEG_reader_1_reg0]

###############
# Transmitter #
###############

# Create blk_mem_gen
cell xilinx.com:ip:blk_mem_gen:8.2 bram_2 {
  MEMORY_TYPE True_Dual_Port_RAM
  USE_BRAM_BLOCK Stand_Alone
  WRITE_WIDTH_A 64
  WRITE_DEPTH_A 512
  WRITE_WIDTH_B 32
  WRITE_DEPTH_B 1024
  ENABLE_A Always_Enabled
  ENABLE_B Always_Enabled
  REGISTER_PORTB_OUTPUT_OF_MEMORY_PRIMITIVES false
}

# Create axi_bram_writer
cell pavel-demin:user:axi_bram_writer:1.0 writer_2 {
  AXI_DATA_WIDTH 32
  AXI_ADDR_WIDTH 32
  BRAM_DATA_WIDTH 32
  BRAM_ADDR_WIDTH 10
} {
  BRAM_PORTA bram_2/BRAM_PORTB
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins writer_2/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_writer_2_reg0]
set_property OFFSET 0x40003000 [get_bd_addr_segs ps_0/Data/SEG_writer_2_reg0]

# Create xlconstant
cell xilinx.com:ip:xlconstant:1.1 const_3 {
  CONST_WIDTH 9
  CONST_VAL 511
}

# Create axis_bram_reader
cell pavel-demin:user:axis_bram_reader:1.0 reader_2 {
  AXIS_TDATA_WIDTH 64
  BRAM_DATA_WIDTH 64
  BRAM_ADDR_WIDTH 9
  CONTINUOUS TRUE
} {
  BRAM_PORTA bram_2/BRAM_PORTA
  cfg_data const_3/dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_7/Dout
}

# Create xlconcat
cell xilinx.com:ip:xlconcat:2.1 concat_0 {
  NUM_PORTS 3
  IN0_WIDTH 16
  IN1_WIDTH 16
  IN2_WIDTH 16
} {
  In0 writer_0/sts_data
  In1 writer_1/sts_data
  In2 reader_2/sts_data
}

# Create axi_sts_register
cell pavel-demin:user:axi_sts_register:1.0 sts_0 {
  STS_DATA_WIDTH 64
  AXI_ADDR_WIDTH 32
  AXI_DATA_WIDTH 32
} {
  sts_data concat_0/dout
}

# Create all required interconnections
apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config {
  Master /ps_0/M_AXI_GP0
  Clk Auto
} [get_bd_intf_pins sts_0/S_AXI]

set_property RANGE 4K [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]
set_property OFFSET 0x40001000 [get_bd_addr_segs ps_0/Data/SEG_sts_0_reg0]

# Create fir_compiler
cell xilinx.com:ip:fir_compiler:7.2 fir_2 {
  DATA_WIDTH.VALUE_SRC USER
  DATA_WIDTH 32
  COEFFICIENTVECTOR {-1.6477803126673e-08, -4.73241780719431e-08, -7.93893762402556e-10, 3.09352974037909e-08, 1.86287085664036e-08, 3.27498519682074e-08, -6.30103868644643e-09, -1.52285727032021e-07, -8.30466648048943e-08, 3.14547654032246e-07, 3.05634502525888e-07, -4.74191327710916e-07, -7.13516534402831e-07, 5.47346324460726e-07, 1.33466461110536e-06, -4.14159890528364e-07, -2.1505811145434e-06, -6.77370237910856e-08, 3.07556819541765e-06, 1.0370505355367e-06, -3.94449781984647e-06, -2.59199328674329e-06, 4.51552941227161e-06, 4.74797884206863e-06, -4.49299646667899e-06, -7.39848885869424e-06, 3.57228568227438e-06, 1.02898719826237e-05, -1.50387150681059e-06, -1.30212988742999e-05, -1.83214145429432e-06, 1.50786566301658e-05, 6.35486748279423e-06, -1.59062147434029e-05, -1.17328848104954e-05, 1.50114974785596e-05, 1.7372574759798e-05, -1.20947251948756e-05, -2.24676444755539e-05, 7.16993553114205e-06, 2.61041439270352e-05, -6.63532856011916e-07, -2.74301832391597e-05, -6.55092457696323e-06, 2.58651810404159e-05, 1.32048515273499e-05, -2.1317677174528e-05, -1.77907085402518e-05, 1.436676627647e-05, 1.88203678903225e-05, -6.35774583750282e-06, -1.51630391175939e-05, -6.34777143600336e-07, 6.41598241707925e-06, 4.00817100547114e-06, 6.7578664887829e-06, -1.00568533107808e-06, -2.24038826835638e-05, -1.07627151802942e-05, 3.72348184414005e-05, 3.2701655435069e-05, -4.6862352007415e-05, -6.46546125464121e-05, 4.62618689241764e-05, 0.000104405214397357, -3.05417940111896e-05, -0.00014746208007481, -4.11988278994384e-06, 0.000187192202366089, 5.94739008909315e-05, -0.000215382226866196, -0.00013430624011575, 0.000223231771512739, 0.000223842528685186, -0.00020270758420517, -0.000319634221298429, 0.000148101277087398, 0.000410063948518449, -5.75617367437652e-05, -0.000481530969730516, -6.56786076534709e-05, 0.000520268200692712, 0.000212671507961849, -0.000514635575661532, -0.000369018523112966, 0.000457482080116169, 0.000515991288315472, -0.000348488643095732, -0.000632902740484264, 0.00019565498787737, 0.000700212218756191, -1.57980429849499e-05, -0.000703228531136762, -0.000166384366137857, 0.000635864178458659, 0.000320845304353809, -0.00050382612172403, -0.000416271542916756, 0.000326578173694164, 0.000425408104410912, -0.000137467845920125, -0.000331057773200808, -1.84374581160459e-05, 0.000131957667600652, 8.89996453664623e-05, 0.000152412457008811, -2.20123592827393e-05, -0.00047912778003751, -0.000226160900022274, 0.000781626283194707, 0.000680353983714684, -0.000973879698174067, -0.0013374715808644, 0.000957544253972286, 0.00215830757707662, -0.000633087262805248, -0.00306249739852838, -8.62724802143682e-05, 0.00392762459059574, 0.00125893562455588, -0.00459335728493682, -0.00289915526565417, 0.00487097490634664, 0.00496287757956818, -0.00455803664391539, -0.00733691415380758, 0.00345728084505496, 0.00983286212154261, -0.00139823904366904, -0.0121865678116845, -0.00174040610912354, 0.014062746409744, 0.00600874643597289, -0.0150660660015954, -0.01137053420847, 0.014748826587083, 0.0176878324514315, -0.0126189063584745, -0.0247140011981246, 0.00813110931172791, 0.0320875384224486, -0.000645073733882858, -0.0393183241035692, -0.0106929061200545, 0.0457380625458776, 0.0272512703315898, -0.0503228989148367, -0.051717794358685, 0.0510207185249084, 0.0905740901172399, -0.0416086426627032, -0.163752839902141, -0.0108030211279308, 0.356394916826446, 0.554828643152604, 0.356394916826445, -0.0108030211279307, -0.163752839902141, -0.0416086426627032, 0.0905740901172398, 0.0510207185249084, -0.0517177943586849, -0.0503228989148367, 0.0272512703315898, 0.0457380625458776, -0.0106929061200545, -0.0393183241035692, -0.000645073733882855, 0.0320875384224486, 0.00813110931172788, -0.0247140011981246, -0.0126189063584744, 0.0176878324514315, 0.0147488265870829, -0.01137053420847, -0.0150660660015954, 0.00600874643597288, 0.014062746409744, -0.00174040610912354, -0.0121865678116845, -0.00139823904366905, 0.00983286212154259, 0.00345728084505496, -0.00733691415380758, -0.00455803664391539, 0.00496287757956815, 0.00487097490634665, -0.00289915526565417, -0.00459335728493682, 0.00125893562455588, 0.00392762459059574, -8.62724802143759e-05, -0.00306249739852838, -0.000633087262805254, 0.00215830757707662, 0.000957544253972288, -0.0013374715808644, -0.000973879698174062, 0.000680353983714686, 0.000781626283194706, -0.000226160900022277, -0.0004791277800375, -2.20123592827382e-05, 0.000152412457008803, 8.89996453664583e-05, 0.000131957667600656, -1.84374581160419e-05, -0.000331057773200813, -0.000137467845920129, 0.000425408104410916, 0.000326578173694167, -0.000416271542916745, -0.000503826121724035, 0.000320845304353799, 0.000635864178458661, -0.00016638436613785, -0.000703228531136761, -1.57980429849744e-05, 0.000700212218756191, 0.000195654987877385, -0.000632902740484265, -0.000348488643095741, 0.00051599128831547, 0.000457482080116171, -0.000369018523112963, -0.000514635575661537, 0.000212671507961847, 0.000520268200692713, -6.56786076534692e-05, -0.000481530969730511, -5.75617367437655e-05, 0.000410063948518448, 0.000148101277087398, -0.000319634221298427, -0.00020270758420517, 0.000223842528685188, 0.000223231771512738, -0.000134306240115752, -0.000215382226866195, 5.94739008909304e-05, 0.000187192202366089, -4.11988278994438e-06, -0.00014746208007481, -3.0541794011189e-05, 0.000104405214397356, 4.62618689241748e-05, -6.46546125464118e-05, -4.68623520074133e-05, 3.27016554350691e-05, 3.72348184413998e-05, -1.07627151802942e-05, -2.24038826835659e-05, -1.00568533107809e-06, 6.75786648878254e-06, 4.00817100547117e-06, 6.41598241707818e-06, -6.34777143600528e-07, -1.51630391175948e-05, -6.35774583750266e-06, 1.88203678903231e-05, 1.436676627647e-05, -1.77907085402514e-05, -2.13176771745279e-05, 1.32048515273498e-05, 2.58651810404156e-05, -6.55092457696207e-06, -2.74301832391597e-05, -6.63532856012472e-07, 2.61041439270352e-05, 7.16993553114219e-06, -2.24676444755538e-05, -1.20947251948757e-05, 1.73725747597979e-05, 1.50114974785595e-05, -1.17328848104953e-05, -1.5906214743403e-05, 6.35486748279425e-06, 1.50786566301659e-05, -1.83214145429435e-06, -1.30212988742996e-05, -1.50387150681058e-06, 1.02898719826235e-05, 3.57228568227438e-06, -7.3984888586941e-06, -4.49299646667903e-06, 4.74797884206855e-06, 4.51552941227162e-06, -2.59199328674326e-06, -3.94449781984647e-06, 1.03705053553668e-06, 3.07556819541762e-06, -6.77370237911482e-08, -2.15058111454339e-06, -4.1415989052838e-07, 1.33466461110535e-06, 5.47346324460698e-07, -7.13516534402833e-07, -4.74191327710884e-07, 3.05634502525885e-07, 3.14547654032223e-07, -8.30466648048881e-08, -1.52285727032016e-07, -6.30103868644584e-09, 3.27498519682033e-08, 1.86287085664046e-08, 3.0935297403796e-08, -7.93893762403235e-10, -4.7324178071939e-08, -1.64778031266738e-08}
  COEFFICIENT_WIDTH 32
  QUANTIZATION Quantize_Only
  BESTPRECISION true
  FILTER_TYPE Interpolation
  INTERPOLATION_RATE 2
  NUMBER_PATHS 2
  RATESPECIFICATION Input_Sample_Period
  SAMPLEPERIOD 6250
  OUTPUT_ROUNDING_MODE Truncate_LSBs
  OUTPUT_WIDTH 32
} {
  S_AXIS_DATA reader_2/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_broadcaster
cell xilinx.com:ip:axis_broadcaster:1.1 bcast_3 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 8
  M_TDATA_NUM_BYTES 4
  M00_TDATA_REMAP {tdata[63:32]}
  M01_TDATA_REMAP {tdata[31:0]}
} {
  S_AXIS fir_2/M_AXIS_DATA
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_4 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Interpolation
  NUMBER_OF_STAGES 6
  FIXED_OR_INITIAL_RATE 3125
  INPUT_SAMPLE_FREQUENCY 0.04
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
} {
  S_AXIS_DATA bcast_3/M00_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create cic_compiler
cell xilinx.com:ip:cic_compiler:4.0 cic_5 {
  INPUT_DATA_WIDTH.VALUE_SRC USER
  FILTER_TYPE Interpolation
  NUMBER_OF_STAGES 6
  FIXED_OR_INITIAL_RATE 3125
  INPUT_SAMPLE_FREQUENCY 0.04
  CLOCK_FREQUENCY 125
  INPUT_DATA_WIDTH 32
  QUANTIZATION Truncation
  OUTPUT_DATA_WIDTH 32
  USE_XTREME_DSP_SLICE false
} {
  S_AXIS_DATA bcast_3/M01_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_combiner
cell  xilinx.com:ip:axis_combiner:1.1 comb_2 {
  TDATA_NUM_BYTES.VALUE_SRC USER
  TDATA_NUM_BYTES 4
} {
  S00_AXIS cic_4/M_AXIS_DATA
  S01_AXIS cic_5/M_AXIS_DATA
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create axis_phase_generator
cell pavel-demin:user:axis_phase_generator:1.0 phase_2 {
  AXIS_TDATA_WIDTH 32
  PHASE_WIDTH 30
} {
  cfg_data slice_13/Dout
  aclk ps_0/FCLK_CLK0
  aresetn slice_7/Dout
}

# Create cordic
cell xilinx.com:ip:cordic:6.0 cordic_2 {
  INPUT_WIDTH.VALUE_SRC USER
  PIPELINING_MODE Optimal
  PHASE_FORMAT Scaled_Radians
  INPUT_WIDTH 32
  OUTPUT_WIDTH 14
  ROUND_MODE Round_Pos_Neg_Inf
  COMPENSATION_SCALING Embedded_Multiplier
} {
  S_AXIS_CARTESIAN comb_2/M_AXIS
  S_AXIS_PHASE phase_2/M_AXIS
  aclk ps_0/FCLK_CLK0
}

# Create axis_subset_converter
cell xilinx.com:ip:axis_subset_converter:1.1 subset_2 {
  S_TDATA_NUM_BYTES.VALUE_SRC USER
  M_TDATA_NUM_BYTES.VALUE_SRC USER
  S_TDATA_NUM_BYTES 4
  M_TDATA_NUM_BYTES 4
  TDATA_REMAP {tdata[15:0],16'b0000000000000000}
} {
  S_AXIS cordic_2/M_AXIS_DOUT
  aclk ps_0/FCLK_CLK0
  aresetn rst_0/peripheral_aresetn
}

# Create clk_wiz
cell xilinx.com:ip:clk_wiz:5.1 pll_0 {
  PRIMITIVE PLL
  PRIM_IN_FREQ.VALUE_SRC USER
  PRIM_IN_FREQ 125.0
  CLKOUT1_USED true
  CLKOUT2_USED true
  CLKOUT1_REQUESTED_OUT_FREQ 125.0
  CLKOUT2_REQUESTED_OUT_FREQ 250.0
} {
  clk_in1 adc_0/adc_clk
}

# Create axis_clock_converter
cell xilinx.com:ip:axis_clock_converter:1.1 fifo_1 {} {
  S_AXIS subset_2/M_AXIS
  s_axis_aclk ps_0/FCLK_CLK0
  s_axis_aresetn slice_8/Dout
  m_axis_aclk pll_0/clk_out1
  m_axis_aresetn const_0/dout
}

# Create axis_red_pitaya_dac
cell pavel-demin:user:axis_red_pitaya_dac:1.0 dac_0 {} {
  aclk pll_0/clk_out1
  ddr_clk pll_0/clk_out2
  locked pll_0/locked
  S_AXIS fifo_1/M_AXIS
  dac_clk dac_clk_o
  dac_rst dac_rst_o
  dac_sel dac_sel_o
  dac_wrt dac_wrt_o
  dac_dat dac_dat_o
}
