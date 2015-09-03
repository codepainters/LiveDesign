----------------------------------------------------------------------------------
-- Copyright (c) 2015, Przemyslaw Wegrzyn <pwegrzyn@codepainters.com>
-- This file is distributed under the Modified BSD License.
--
-- Simple test for LiveDesign board.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity top is
    port(FCLK   : in  std_logic;
         LED    : out std_logic_vector(7 downto 0);
         SW_DIP : in std_logic_vector(7 downto 0)
    );

end top;

architecture behavioral of top is

    component clock_prescaler
        generic (n : integer range 2 to 16;
                 exp : integer range 0 to 10);
        port(clk : in  std_logic;
             q : out  std_logic);
    end component;

    signal slow_tick : std_logic;
    signal led_state : std_logic_vector(7 downto 0) := (0 => '1', others => '0');
    
begin
    
    -- dividing by 50MHz / 10e06 -> 5Hz
    prescaler: clock_prescaler 
        generic map (n => 10, exp => 6)
        port map (clk => FCLK, q => slow_tick);
    
    process(FCLK) is
    begin
        if rising_edge(FCLK) and slow_tick = '1' then
            led_state <= led_state(6 downto 0) & led_state(7);
        end if;
    end process;

    LED <= led_state and (SW_DIP xor b"11111111");

end behavioral;

