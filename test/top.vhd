----------------------------------------------------------------------------------
-- Copyright (c) 2015, Przemyslaw Wegrzyn <pwegrzyn@codepainters.com>
-- This file is distributed under the Modified BSD License.
--
-- Simple test for LiveDesign board.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity top is
    port(FCLK     : in  std_logic;
         LED      : out std_logic_vector(7 downto 0);
         SW_DIP   : in  std_logic_vector(7 downto 0);
         SW_USER  : in  std_logic_vector(5 downto 0);

         DIG0_SEG : out std_logic_vector(7 downto 0);
         DIG1_SEG : out std_logic_vector(7 downto 0);
         DIG2_SEG : out std_logic_vector(7 downto 0);
         DIG3_SEG : out std_logic_vector(7 downto 0);
         DIG4_SEG : out std_logic_vector(7 downto 0);
         DIG5_SEG : out std_logic_vector(7 downto 0);

         AUDIO_L  : out std_logic;
         AUDIO_R  : out std_logic
    );

end top;

architecture behavioral of top is
    component clock_prescaler
        generic(n   : integer range 2 to 16;
                exp : integer range 0 to 10);
        port(clk : in  std_logic;
             q   : out std_logic);
    end component;

    component digit_disp
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
    end component;

    component speakers
        port(clk   : in  std_logic;
             tick  : in  std_logic;
             left  : out std_logic;
             right : out std_logic);
    end component;

    signal slow_tick : std_logic;
    signal led_state : std_logic_vector(7 downto 0) := (0 => '1', others => '0');

begin

    -- dividing by 50MHz / 10e06 -> 5Hz
    prescaler : clock_prescaler
        generic map(n => 10, exp => 6)
        port map(clk => FCLK, q => slow_tick);

    t_disp : digit_disp
        port map(clk  => FCLK,
                 tick => slow_tick,
                 dig0 => DIG0_SEG,
                 dig1 => DIG1_SEG,
                 dig2 => DIG2_SEG,
                 dig3 => DIG3_SEG,
                 dig4 => DIG4_SEG,
                 dig5 => DIG5_SEG,
                 sw   => SW_USER);

    t_speakers : speakers
        port map(clk   => FCLK,
                 tick  => slow_tick,
                 left  => AUDIO_L,
                 right => AUDIO_R);

    process(FCLK) is
    begin
        if rising_edge(FCLK) and slow_tick = '1' then
            led_state <= led_state(6 downto 0) & led_state(7);
        end if;
    end process;

    LED <= led_state and (SW_DIP xor b"11111111");

end behavioral;

