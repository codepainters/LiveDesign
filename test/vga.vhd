----------------------------------------------------------------------------------
-- Copyright (c) 2015, Przemyslaw Wegrzyn <pwegrzyn@codepainters.com>
-- This file is distributed under the Modified BSD License.
--
-- Simple test for LiveDesign board.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga is
    port(clk   : in  std_logic;
         r     : out std_logic_vector(2 downto 0);
         g     : out std_logic_vector(2 downto 0);
         b     : out std_logic_vector(2 downto 0);
         hsync : out std_logic;
         vsync : out std_logic);
end vga;

architecture behavioral of vga is
    
    type t_hsync_phase is (h_pulse, h_back_porch, h_active, h_front_porch);
    type t_vsync_phase is (v_pulse, v_back_porch, v_active, v_front_porch);
    
    -- horizontal timing (in pixels)
    constant HSYNC_PULSE : integer := 96;
    constant HSYNC_BACK_PORCH : integer := 48;
    constant HSYNC_ACTIVE : integer := 640;
    constant HSYNC_FRONT_PORCH : integer := 16;

    -- vertical timing (in lines)
    constant VSYNC_PULSE : integer := 2;
    constant VSYNC_BACK_PORCH : integer := 33;
    constant VSYNC_ACTIVE : integer := 480;
    constant VSYNC_FRONT_PORCH : integer := 10;
        
    -- for each pixel pixel_clk is first 0, then 1
    signal pixel_clk : std_logic := '0';

    -- hsync generator state
    signal hsync_phase : t_hsync_phase := h_pulse ;
    signal hsync_cnt : unsigned(10 downto 0) := to_unsigned(HSYNC_PULSE - 2, 11);

    -- vsync generator state
    signal vsync_phase : t_vsync_phase := v_pulse ;
    signal vsync_cnt : unsigned(9 downto 0) := to_unsigned(VSYNC_PULSE - 2, 10);

    -- true at the end of line, controls vsync generation
    signal next_line : boolean := false;
    
begin
    
    hsync_gen : process(clk) is
    begin
        if rising_edge(clk) then
            pixel_clk <= not pixel_clk;
            
            if pixel_clk = '1' then
                -- counter overflow ?
                if hsync_cnt(hsync_cnt'high) = '1' then
                    -- yes, move to next phase preloading the counter as needed
                    case hsync_phase is
                        when h_pulse =>
                            hsync_phase <= h_back_porch;
                            hsync_cnt <= to_unsigned(HSYNC_BACK_PORCH - 2, 11);
                            
                        when h_back_porch =>
                            hsync_phase <= h_active;
                            hsync_cnt <= to_unsigned(HSYNC_ACTIVE - 2, 11);
                        
                        when h_active =>
                            hsync_phase <= h_front_porch;
                            hsync_cnt <= to_unsigned(HSYNC_FRONT_PORCH - 2, 11);
                        
                        when h_front_porch =>
                            hsync_phase <= h_pulse;
                            hsync_cnt <= to_unsigned(HSYNC_PULSE - 2, 11);
                            
                    end case;
                else
                    hsync_cnt <= hsync_cnt - 1;
                end if;
            end if;                
        end if;
    end process;
     
    hsync <= '0' when hsync_phase = h_pulse else '1';
    next_line <= hsync_cnt(hsync_cnt'high) = '1' and hsync_phase = h_front_porch and pixel_clk = '1';
        
    vsync_gen : process(clk) is
    begin
        if rising_edge(clk) then            
            if next_line then
                -- counter overflow ?
                if vsync_cnt(vsync_cnt'high) = '1' then
                    -- yes, move to next phase preloading the counter as needed
                    case vsync_phase is
                        when v_pulse =>
                            vsync_phase <= v_back_porch;
                            vsync_cnt <= to_unsigned(VSYNC_BACK_PORCH - 2, 10);
                            
                        when v_back_porch =>
                            vsync_phase <= v_active;
                            vsync_cnt <= to_unsigned(VSYNC_ACTIVE - 2, 10);
                        
                        when v_active =>
                            vsync_phase <= v_front_porch;
                            vsync_cnt <= to_unsigned(VSYNC_FRONT_PORCH - 2, 10);
                        
                        when v_front_porch =>
                            vsync_phase <= v_pulse;
                            vsync_cnt <= to_unsigned(VSYNC_PULSE - 2, 10);
                            
                    end case;
                else
                    vsync_cnt <= vsync_cnt - 1;
                end if;
            end if;                
        end if;
    end process;        
    
    vsync <= '0' when vsync_phase = v_pulse else '1';
        
    r <= "111" when vsync_phase = v_active and hsync_phase = h_active else "000";
    g <= "000";
    b <= "000";
    
end behavioral;

