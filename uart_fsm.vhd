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
	CNT_A : in std_logic_vector(3 downto 0);
	CNT_B : in std_logic_vector(3 downto 0);
	CLK   : in std_logic;
	RST   : in std_logic;
	--out
	RESULT: out std_logic_vector(1 downto 0)
);

end entity UART_FSM;



-------------------------------------------------

architecture behavioral of UART_FSM is
type STATE_T is (AWAIT_START, TRANS_START, AWAIT_NEXT, STORE_DIN,
					AWAIT_STOP, CHECK_STOP, STOP_PRESENT);
signal state : STATE_T := AWAIT_START;

begin
	process (CLK) begin
		if rising_edge(CLK) then --only rising edge
			if RST = '1' then --asynchroni reset
				state <= AWAIT_START;
			else
				RESULT <= "00"; --latch prevent?
				case state is
				when AWAIT_START =>
					RESULT <= "00";
					if DIN = '0' then
					state <= TRANS_START;
					end if;

				when TRANS_START =>
					RESULT <= "01";
					if CNT_A = "1000" then
						state <= AWAIT_NEXT;
					end if;

				when AWAIT_NEXT =>
					RESULT <= "10";
					if CNT_B = "1111" then
						state <= STORE_DIN;
					end if;

				when STORE_DIN =>
					RESULT <= "01";
					if CNT_A = "1000" then
						state <= AWAIT_STOP;
					else
						state <= AWAIT_NEXT;
					end if;

				when AWAIT_STOP =>
					RESULT <= "10";
					if CNT_B = "1111" then
						state <= CHECK_STOP;
					end if;

				when CHECK_STOP =>
					RESULT <= "00";
					if DIN = '0' then
						state <= AWAIT_START;
					else
						state <= STOP_PRESENT;
					end if;

				when STOP_PRESENT =>
					RESULT <= "11";
					state <= AWAIT_START;

				when others => null;

				end case;
			end if;
		end if;
	end process;
end behavioral;
