library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ButtonDebouncer is
    port (
        CLK      : in  std_logic;
        button   : in  std_logic;
        debounced_button : out std_logic
        
    );
end ButtonDebouncer;

architecture behavioral of ButtonDebouncer is
    signal counter_db : std_logic_vector(24 downto 0) := (others => '0');
    signal stb_btn    : std_logic := '0';
    signal prev_btn   : std_logic := '0';
    
begin
    -- Debouncer Process
    debounce_process: process(CLK)
    begin
        if rising_edge(CLK) then
            -- Buton durumu değiştiyse saymaya başla
            if button /= stb_btn then
                counter_db <= std_logic_vector(unsigned(counter_db) + 1);
                
                -- 20ms bekleme süresi 
                if (to_integer(unsigned(counter_db)) >= 1000000) then
                    stb_btn <= button;    -- Buton durumunu güncelle
                    counter_db <= (others => '0');  
                end if;
            else
                -- Buton durumu değişmediyse sayacı sıfırla
                counter_db <= (others => '0');
            end if;
            
            -- Önceki buton durumunu kaydet
            prev_btn <= stb_btn;
        end if;
    end process debounce_process;

    -- Çıkış ataması: Sadece yükselen kenarda '1' olacak
    debounced_button <= '1' when (prev_btn = '0' and stb_btn = '1') else '0';

end behavioral;
