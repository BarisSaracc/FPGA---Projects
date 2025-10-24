----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Baris Sarac
-- 
-- Create Date: 02.09.2025 10:29:00
-- Design Name: 
-- Module Name: tb_blinker - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_blinker is
--  Port ( );
end tb_blinker;

architecture Behavioral of tb_blinker is

signal CLK_50MHZ : std_logic := '0';
signal LED : std_logic;
signal reset : std_logic := '1';
component Blink 
    port (
   
    CLK_50MHZ : in  std_logic;
    LED       : out std_logic;
     reset: in std_logic
    );
end component;

begin

process begin

 CLK_50MHZ<= '0';
 wait for 10 ns;
 CLK_50MHZ<= '1';
 wait for 10 ns;
end process;

 reset_process: process
 begin
        reset <= '1';
        wait for 100 ns; 
        reset <= '0';
        wait; 
    end process;
    
uut : Blink 
    port map(
    CLK_50MHZ =>    CLK_50MHZ,
    LED =>  LED,
    reset => reset
    );

end Behavioral;
