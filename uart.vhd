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
	DOUT_VLD:	out std_logic := '0'

);

end UART_RX;

-------------------------------------------------

architecture behavioral of UART_RX is
signal cnt_a      : std_logic_vector(2 downto 0) := "000";
signal cnt_b      : std_logic_vector(3 downto 0) := "0000";
signal fsm_result : std_logic_vector(1 downto 0);
signal d_out      : std_logic_vector(7 downto 0) := "00000000";

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

	p_cnt_a : process(CLK, RST)
	begin
		if RST = '1' then
			cnt_a <= "000";
		elsif rising_edge(CLK) then
			if fsm_result = "00" then
				cnt_a <= "000";
			elsif fsm_result(0) = '1' then
				cnt_a <= cnt_a + 1;
			end if;
		end if;
	end process;

	p_cnt_b : process(CLK, RST)
	begin
		if RST = '1' then
			cnt_b <= "0000";
		elsif rising_edge(CLK) then
			if fsm_result = "00" or cnt_b = "1110" then
				cnt_b <= "0000";
			elsif fsm_result(1) = '1' then
				cnt_b <= cnt_b + 1;
			end if;
		end if;
	end process;

	p_sipo_sh_reg : process(CLK, RST)
	begin
		if rising_edge(CLK) then
			if fsm_result = "11" then
				DOUT_VLD <= '1';
			else
				DOUT_VLD <= '0';
			end if;
			--DOUT_VLD <= '1' when (fsm_result = "11") else '0';
			if fsm_result = "01" then
				--my own bit shift
				d_out(0) <= d_out(1);
				d_out(1) <= d_out(2);
				d_out(2) <= d_out(3);
				d_out(3) <= d_out(4);
				d_out(4) <= d_out(5);
				d_out(5) <= d_out(6);
				d_out(6) <= d_out(7);
				d_out(7) <= DIN;
			end if;
			DOUT <= d_out;
		end if;
	end process;

end behavioral;
