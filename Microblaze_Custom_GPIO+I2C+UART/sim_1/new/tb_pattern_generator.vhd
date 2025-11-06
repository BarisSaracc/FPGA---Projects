library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_video_system is
end tb_video_system;

architecture Behavioral of tb_video_system is
    
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
    
    component painter is
        Port ( 
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            hsync_in : in STD_LOGIC;
            vsync_in : in STD_LOGIC;
            data_in  : in STD_LOGIC_VECTOR(23 downto 0);
            hsync_out : out STD_LOGIC;
            vsync_out : out STD_LOGIC;
            data_out  : out STD_LOGIC_VECTOR(23 downto 0)
        );
    end component;
    
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    
    signal gen_hsync : STD_LOGIC;
    signal gen_vsync : STD_LOGIC;
    signal gen_de    : STD_LOGIC;
    signal gen_data  : STD_LOGIC_VECTOR(23 downto 0);
    
    signal paint_hsync : STD_LOGIC;
    signal paint_vsync : STD_LOGIC;
    signal paint_data  : STD_LOGIC_VECTOR(23 downto 0);
    
    constant CLK_PERIOD : time := 6.735 ns;
    
begin
    
    UUT_GEN: video_generator
        port map (
            clk => clk,
            rst => rst,
            hsync => gen_hsync,
            vsync => gen_vsync,
            de => gen_de,
            data => gen_data
        );
    
    UUT_PAINT: painter
        port map (
            clk => clk,
            rst => rst,
            hsync_in => gen_hsync,
            vsync_in => gen_vsync,
            data_in  => gen_data,
            hsync_out => paint_hsync,
            vsync_out => paint_vsync,
            data_out  => paint_data
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
        
        -- 2 frame boyunca çalýþ
        wait for 33.3 ms;
        
        -- 2 frame daha çalýþ
        wait for 33.3 ms;
        
        wait;
    end process;
    
end Behavioral;