----------------------------------------------------------------------------------
-- Copyright (c) 2015, Przemyslaw Wegrzyn <pwegrzyn@codepainters.com>
-- This file is distributed under the Modified BSD License.
--
-- Simple test for LiveDesign board.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity speakers is
    port(clk   : in  std_logic;
         tick  : in  std_logic;
         left  : out std_logic;
         right : out std_logic);
end speakers;

architecture behavioral of speakers is
    component clock_prescaler
        generic(n   : integer range 2 to 16;
                exp : integer range 0 to 10);
        port(clk : in  std_logic;
             q   : out std_logic);
    end component;

    signal clk_1khz : std_logic;
    signal sound    : std_logic := '0';

    signal counter : std_logic_vector(8 downto 0) := (0 => '1', others => '0');

begin

    -- dividing by 50MHz / 5e04 -> 1kHz
    prescaler : clock_prescaler
        generic map(n => 5, exp => 4)
        port map(clk => clk, q => clk_1khz);

    -- further divide clk_1khz to get 50% duty cycle
    sound_gen : process(clk) is
    begin
        if rising_edge(clk) then
            sound <= sound xor clk_1khz;
        end if;
    end process;

    beeper : process(clk) is
    begin
        if rising_edge(clk) and tick = '1' then
            counter <= counter (counter'high - 1 downto 0) & counter(counter'high);
        end if;
    end process;

    left <= sound and counter(0);
    right <= sound and counter(2);

end behavioral;

