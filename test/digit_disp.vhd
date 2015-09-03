----------------------------------------------------------------------------------
-- Copyright (c) 2015, Przemyslaw Wegrzyn <pwegrzyn@codepainters.com>
-- This file is distributed under the Modified BSD License.
--
-- Simple test for LiveDesign board.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity digit_disp is
    port(clk  : in  std_logic;
         tick : in  std_logic;
         dig0 : out std_logic_vector(7 downto 0);
         dig1 : out std_logic_vector(7 downto 0);
         dig2 : out std_logic_vector(7 downto 0);
         dig3 : out std_logic_vector(7 downto 0);
         dig4 : out std_logic_vector(7 downto 0);
         dig5 : out std_logic_vector(7 downto 0);
         sw   : in  std_logic_vector(5 downto 0)
    );
end digit_disp;

architecture behavioral of digit_disp is
    signal disp_state : std_logic_vector(7 downto 0) := (0 => '1', others => '0');

begin
    process(clk) is
    begin
        if rising_edge(clk) and tick = '1' then
            disp_state <= disp_state(6 downto 0) & disp_state(7);
        end if;
    end process;

    -- show moving segment by default, turn on all segments when 
    -- button below is pressed
    dig0 <= disp_state when sw(0) = '1' else (others => '1');
    dig1 <= disp_state when sw(1) = '1' else (others => '1');
    dig2 <= disp_state when sw(2) = '1' else (others => '1');
    dig3 <= disp_state when sw(3) = '1' else (others => '1');
    dig4 <= disp_state when sw(4) = '1' else (others => '1');
    dig5 <= disp_state when sw(5) = '1' else (others => '1');

end behavioral;

