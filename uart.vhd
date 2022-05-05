-- uart.vhd: UART controller - receiving part

-- Author(s): xhroma16

--

library ieee;

use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;



-------------------------------------------------

entity UART_RX is

port(
	CLK:		in std_logic;
	RST:		in std_logic;
	DIN:		in std_logic;
	DOUT:		out std_logic_vector(7 downto 0);
	DOUT_VLD:	out std_logic

);

end UART_RX;



-------------------------------------------------

architecture behavioral of UART_RX is
signal cnt_a  : std_logic_vector(4 downto 0);
signal cnt_b  : std_logic_vector(4 downto 0);
signal din_en : std_logic;

begin

	FSM : entity work.UART_FSM(behavioral)
	port map (
		DIN    => DIN,
		CNT_A  => cnt_a,
		CNT_B  => cnt_b,
		CLK    => CLK,
		RST    => RST,
		RESULT => fsm_result
	);

	LOGIC : process (CLK) begin
		if rising_edge(CLK) then
			if fsm_result = "00" then
				cnt_a = "0000"
				cnt_b

		end if;
	end process;

	p_cnt_a : process(CLK, RST)
	begin
		if (RST='1') then
			cnt_out <= "0000";
		elsif rising_edge(CLK) and (fsm_result = "01") then
			cnt <= cnt + 1;
		end if;
	end process;

	p_cnt_b : process(CLK,  RST)
	begin
		if (RST='1') then
			cnt_out <= "0000";
		elsif rising_edge(CLK) and (fsm_result = "10") then
			cnt <= cnt + 1;
		end if;
	end process;

end behavioral;
