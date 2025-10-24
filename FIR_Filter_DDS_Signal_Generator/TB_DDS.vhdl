library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity testbench is
end testbench;

architecture Behavioral of testbench is
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '1';
    signal frekans_ayar : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
    signal dalga_cikis : STD_LOGIC_VECTOR(15 downto 0);
    
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz
    
begin
    -- DDS modülünü bağla
    uut: entity work.tam_dds
        port map (
            clk => clk,
            reset => reset,
            frekans_ayar => frekans_ayar,
            dalga_cikis => dalga_cikis
        );
    
    -- Clock üretme (50 MHz)
    clk <= not clk after 10 ns;
    
    -- Test senaryosu
    process
    begin
        -- Başlangıçta reset
        reset <= '1';
        wait for 100 ns;
        reset <= '0';
        
        -- Farklı frekanslarda test (16-bit değerler)
        frekans_ayar <= X"0001";  -- Çok yavaş (1)
        wait for 50 us;
        
        frekans_ayar <= X"0011";  -- Yavaş (16)
        wait for 50 us;
        
        frekans_ayar <= X"0100";  -- Orta (256)
        wait for 50 us;
        
        frekans_ayar <= X"5000";  -- Hızlı (4096)
        wait for 50 us;
        
        frekans_ayar <= X"F000";  -- Çok hızlı (32768)
        wait for 20 ms;
        
        frekans_ayar <= X"5000";  -- Hızlı (4096)
        wait for 20 ms;
                frekans_ayar <= X"5000";  -- Hızlı (4096)
        wait for 20 ms;
        
        frekans_ayar <= X"F000";  -- Çok hızlı (32768)
        wait for 20 ms;

                frekans_ayar <= X"5000";  -- Hızlı (4096)
        wait for 20 ms;
        
        wait;
    end process;
    
end Behavioral;
