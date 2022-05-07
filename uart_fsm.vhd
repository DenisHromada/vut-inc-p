-- uart_fsm.vhd: UART controller - finite state machine

-- Author(s): xhroma16

--

library ieee;

use ieee.std_logic_1164.all;



-------------------------------------------------

entity UART_FSM is

port(
	--in
	DIN   : in std_logic;
	CNT_A : in std_logic_vector(2 downto 0);
	CNT_B : in std_logic_vector(3 downto 0);
	CLK   : in std_logic;
	RST   : in std_logic;
	--out
	RESULT: out std_logic_vector(1 downto 0));
end UART_FSM;



-------------------------------------------------

architecture behavioral of UART_FSM is
type STATE_T is (AWAIT_START, TRANS_START, AWAIT_NEXT, STORE_DIN, AWAIT_STOP);
signal cur_state : STATE_T := AWAIT_START;
signal next_state : STATE_T := AWAIT_START;

begin
	cur_state_logic: process (cur_state, DIN, CNT_A, CNT_B, RST) begin
		if RST = '1' then
			next_state <= AWAIT_START;
		else
			case cur_state is
			when AWAIT_START =>
				if DIN = '0' then
					next_state <= TRANS_START;
				end if;

			when TRANS_START =>
				if CNT_B = "0101" then
					next_state <= AWAIT_NEXT;
				end if;

			when AWAIT_NEXT =>
				if CNT_B = "1110" then
					next_state <= STORE_DIN;
				end if;

			when STORE_DIN =>
				if CNT_A = "111" then
					next_state <= AWAIT_STOP;
				else
					next_state <= AWAIT_NEXT;
				end if;

			when AWAIT_STOP =>
				if CNT_B = "1110" then
					next_state <= AWAIT_START;
				end if;

			when others => null;
			end case;
		end if;
	end process;

	next_state_logic: process(CLK) begin
		if RST = '1' then
			cur_state <= AWAIT_START;
		elsif rising_edge(CLK) then
			cur_state <= next_state;
		end if;
	end process;

	output_logic: process(cur_state, DIN, CNT_A, CNT_B) begin
		case cur_state is
		when AWAIT_START =>
			RESULT <= "00";

		when TRANS_START =>
			RESULT <= "10";
			if CNT_B = "0101" then
				RESULT <= "00";
			end if;

		when AWAIT_NEXT =>
			RESULT <= "10";

		when STORE_DIN =>
			RESULT <= "01";

		when AWAIT_STOP =>
			RESULT <= "10";
			if CNT_B = "1110" then
				if DIN = '1' then
					RESULT <= "11";
				else
					RESULT <= "00";
				end if;
			end if;

		when others => null;
		end case;
	end process;
end behavioral;
