.PHONY : zip
zip : xhroma16.zip
xhroma16.zip : uart.vhd uart_fsm.vhd zprava.pdf
	zip $@ $^
