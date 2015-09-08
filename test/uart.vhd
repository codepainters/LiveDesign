----------------------------------------------------------------------------------
-- Copyright (c) 2015, Przemyslaw Wegrzyn <pwegrzyn@codepainters.com>
-- This file is distributed under the Modified BSD License.
--
-- Simple test for LiveDesign board.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_test is
    port(
        clk : in  std_logic;
        rxd : in  std_logic;
        txd : out std_logic
    );
end entity;

architecture rtl of uart_test is
    component kcuart_rx
        port(serial_in    : in  std_logic;
             data_out     : out std_logic_vector(7 downto 0);
             data_strobe  : out std_logic;
             en_16_x_baud : in  std_logic;
             clk          : in  std_logic);
    end component kcuart_rx;

    component kcuart_tx
        port(data_in        : in  std_logic_vector(7 downto 0);
             send_character : in  std_logic;
             en_16_x_baud   : in  std_logic;
             serial_out     : out std_logic;
             Tx_complete    : out std_logic;
             clk            : in  std_logic);
    end component kcuart_tx;

    signal baudrate_x16 : std_logic;

    -- 50Mhz / 16 * 115200 = 27.13, counter goes through all zeros and all 1, hence 25
    constant baudrate_reload : integer := 25;
    signal baudrate_cnt      : unsigned(5 downto 0);

    signal rx_data   : std_logic_vector(7 downto 0);
    signal rx_strobe : std_logic;

    signal tx_data   : std_logic_vector(7 downto 0);
    signal tx_strobe : std_logic;

begin
    rx : component kcuart_rx
        port map(
            serial_in    => rxd,
            data_out     => rx_data,
            data_strobe  => rx_strobe,
            en_16_x_baud => baudrate_x16,
            clk          => clk
        );

    tx : component kcuart_tx
        port map(
            data_in        => tx_data,
            send_character => tx_strobe,
            en_16_x_baud   => baudrate_x16,
            serial_out     => txd,
            Tx_complete    => open,
            clk            => clk
        );

    baudrate_cntr : process(clk) is
    begin
        if rising_edge(clk) then
            if baudrate_cnt(baudrate_cnt'high) = '1' then
                baudrate_cnt <= to_unsigned(baudrate_reload, baudrate_cnt'length);
            else
                baudrate_cnt <= baudrate_cnt - 1;
            end if;
        end if;
    end process;

    baudrate_x16 <= baudrate_cnt(baudrate_cnt'high);

    buf_loader : process(clk) is
        variable prev_rx_strobe : std_logic := '0';
    begin
        if rising_edge(clk) then
            -- only load on rising edge, in and out speed is same, 
            -- so no risk of overflow 
            if prev_rx_strobe = '0' and rx_strobe = '1' then
                tx_strobe <= '1';
            else
                tx_strobe <= '0';
            end if;
            prev_rx_strobe := rx_strobe;

        end if;

    end process;

    -- echo
    tx_data <= rx_data;

end architecture;
