library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity testbench is
end testbench;

architecture Behavioral of testbench is
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    signal frekans_ayar : STD_LOGIC_VECTOR(31 downto 0) := X"00000000";
    signal dalga_cikis : STD_LOGIC_VECTOR(15 downto 0);
    signal filtered_output : STD_LOGIC_VECTOR(15 downto 0);
    
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz
    
begin
    -- DDS 
    uut_dds: entity work.tam_dds
        port map (
            clk => clk,
            reset => reset,
            frekans_ayar => frekans_ayar,
            dalga_cikis => dalga_cikis
        );
    
    -- Filter_LP
    uut_filter: entity work.Filter_LP
        port map (
            clk => clk,
            x_in => dalga_cikis,
            y_out => filtered_output
        );
    
    -- Clock üretme (50 MHz)
    clk <= not clk after CLK_PERIOD/2;
    
    -- Test senaryosu
    process
    begin
        -- Başlangıçta reset
        reset <= '1';
        wait for 200 ns;
        reset <= '0';
        wait for 100 ns;
        
-- Son 20 bit etkisiz (2^20 = 1048576)
for i in 0 to 2550 loop
    frekans_ayar <= std_logic_vector(to_unsigned(i * 1048576, 32));
    wait until rising_edge(clk);
    wait for 1 ns;
end loop;
        
        wait;
    end process;
    
end Behavioral;