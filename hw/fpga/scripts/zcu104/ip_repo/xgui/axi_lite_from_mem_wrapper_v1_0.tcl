# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "AxiAddrWidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AxiProt" -parent ${Page_0}
  ipgui::add_param $IPINST -name "DataWidth" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MaxRequests" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MemAddrWidth" -parent ${Page_0}


}

proc update_PARAM_VALUE.AxiAddrWidth { PARAM_VALUE.AxiAddrWidth } {
	# Procedure called to update AxiAddrWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AxiAddrWidth { PARAM_VALUE.AxiAddrWidth } {
	# Procedure called to validate AxiAddrWidth
	return true
}

proc update_PARAM_VALUE.AxiProt { PARAM_VALUE.AxiProt } {
	# Procedure called to update AxiProt when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AxiProt { PARAM_VALUE.AxiProt } {
	# Procedure called to validate AxiProt
	return true
}

proc update_PARAM_VALUE.DataWidth { PARAM_VALUE.DataWidth } {
	# Procedure called to update DataWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.DataWidth { PARAM_VALUE.DataWidth } {
	# Procedure called to validate DataWidth
	return true
}

proc update_PARAM_VALUE.MaxRequests { PARAM_VALUE.MaxRequests } {
	# Procedure called to update MaxRequests when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MaxRequests { PARAM_VALUE.MaxRequests } {
	# Procedure called to validate MaxRequests
	return true
}

proc update_PARAM_VALUE.MemAddrWidth { PARAM_VALUE.MemAddrWidth } {
	# Procedure called to update MemAddrWidth when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MemAddrWidth { PARAM_VALUE.MemAddrWidth } {
	# Procedure called to validate MemAddrWidth
	return true
}


proc update_MODELPARAM_VALUE.MemAddrWidth { MODELPARAM_VALUE.MemAddrWidth PARAM_VALUE.MemAddrWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MemAddrWidth}] ${MODELPARAM_VALUE.MemAddrWidth}
}

proc update_MODELPARAM_VALUE.AxiAddrWidth { MODELPARAM_VALUE.AxiAddrWidth PARAM_VALUE.AxiAddrWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AxiAddrWidth}] ${MODELPARAM_VALUE.AxiAddrWidth}
}

proc update_MODELPARAM_VALUE.DataWidth { MODELPARAM_VALUE.DataWidth PARAM_VALUE.DataWidth } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.DataWidth}] ${MODELPARAM_VALUE.DataWidth}
}

proc update_MODELPARAM_VALUE.MaxRequests { MODELPARAM_VALUE.MaxRequests PARAM_VALUE.MaxRequests } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MaxRequests}] ${MODELPARAM_VALUE.MaxRequests}
}

proc update_MODELPARAM_VALUE.AxiProt { MODELPARAM_VALUE.AxiProt PARAM_VALUE.AxiProt } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AxiProt}] ${MODELPARAM_VALUE.AxiProt}
}

