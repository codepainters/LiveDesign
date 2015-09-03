----------------------------------------------------------------------------------
-- Simple test for LiveDesign board.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity top is
    port(FCLK : in  std_logic;
         LED  : out std_logic_vector(7 downto 0)
    );

end top;

architecture behavioral of top is

    signal led_state : std_logic_vector(7 downto 0) := (0 => '1', others => '0');
    
begin
    
    process(FCLK) is
    begin
        if rising_edge(FCLK) then
            led_state <= led_state(6 downto 0) & led_state(7);
        end if;
    end process;

    LED <= led_state;

end behavioral;

