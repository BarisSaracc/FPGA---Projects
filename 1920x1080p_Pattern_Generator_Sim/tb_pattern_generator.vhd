library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_video_generator is
end tb_video_generator;

architecture Behavioral of tb_video_generator is
    
    component video_generator is
        Port ( 
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            hsync : out STD_LOGIC;
            vsync : out STD_LOGIC;
            de    : out STD_LOGIC;
            data  : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;
    
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    signal hsync : STD_LOGIC;
    signal vsync : STD_LOGIC;
    signal de    : STD_LOGIC;
    signal data  : STD_LOGIC_VECTOR(23 downto 0);
    
    constant CLK_PERIOD : time := 6.735 ns;
    
begin
    
    UUT: video_generator
        port map (
            clk => clk,
            rst => rst,
            hsync => hsync,
            vsync => vsync,
            de => de,
            data => data
        );
    
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD/2;
            clk <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;
    
    stim_process : process
    begin
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 50 ms;
        wait;
    end process;
    
end Behavioral;