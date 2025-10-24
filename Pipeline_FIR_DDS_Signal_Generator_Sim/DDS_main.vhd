library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tam_dds is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        frekans_ayar : in STD_LOGIC_VECTOR(31 downto 0);  -- 32 bit yap
        dalga_cikis : out STD_LOGIC_VECTOR(15 downto 0)
    );
end tam_dds;

architecture Behavioral of tam_dds is
    signal faz_biriktici : unsigned(31 downto 0) := (others => '0');
    signal rom_adres : std_logic_vector(7 downto 0);
    
    -- 256 örnekli sinüs ROM'u (daha yüksek çözünürlük için)
    type rom_tipi is array (0 to 255) of std_logic_vector(15 downto 0);
    constant sin_rom : rom_tipi := (
        -- 256 örnek için sinüs değerleri (0-255)
        -- Buraya 256 adet 16-bit sinüs değeri girilmeli
        -- Örnek: 0-127 için mevcut değerler, 128-255 için simetrik
        X"0000", X"0324", X"0647", X"096A", X"0C8B", X"0FAB", X"12C7", X"15E1",
        X"18F8", X"1C0B", X"1F19", X"2223", X"2527", X"2826", X"2B1F", X"2E11",
        X"30FB", X"33DE", X"36B9", X"398B", X"3C56", X"3F17", X"41CD", X"447A",
        X"471C", X"49B3", X"4C3F", X"4EBF", X"5133", X"539B", X"55F5", X"5842",
        X"5A82", X"5CB3", X"5ED7", X"60EB", X"62F1", X"64E7", X"66CF", X"68A6",
        X"6A6D", X"6C23", X"6DC9", X"6F5E", X"70E2", X"7254", X"73B5", X"7504",
        X"7641", X"776B", X"7884", X"7989", X"7A7C", X"7B5C", X"7C29", X"7CE3",
        X"7D89", X"7E1C", X"7E9C", X"7F08", X"7F61", X"7FA6", X"7FD8", X"7FF6",
        X"7FFF", X"7FF6", X"7FD8", X"7FA6", X"7F61", X"7F08", X"7E9C", X"7E1C",
        X"7D89", X"7CE3", X"7C29", X"7B5C", X"7A7C", X"7989", X"7884", X"776B",
        X"7641", X"7504", X"73B5", X"7254", X"70E2", X"6F5E", X"6DC9", X"6C23",
        X"6A6D", X"68A6", X"66CF", X"64E7", X"62F1", X"60EB", X"5ED7", X"5CB3",
        X"5A82", X"5842", X"55F5", X"539B", X"5133", X"4EBF", X"4C3F", X"49B3",
        X"471C", X"447A", X"41CD", X"3F17", X"3C56", X"398B", X"36B9", X"33DE",
        X"30FB", X"2E11", X"2B1F", X"2826", X"2527", X"2223", X"1F19", X"1C0B",
        X"18F8", X"15E1", X"12C7", X"0FAB", X"0C8B", X"096A", X"0647", X"0324",
        X"0000", X"FCDB", X"F9B8", X"F695", X"F374", X"F054", X"ED38", X"EA1E",
        X"E707", X"E3F4", X"E0E6", X"DDDC", X"DAD8", X"D7D9", X"D4E0", X"D1EE",
        X"CF04", X"CC21", X"C946", X"C674", X"C3A9", X"C0E8", X"BE32", X"BB85",
        X"B8E3", X"B64C", X"B3C0", X"B140", X"AECC", X"AC64", X"AA0A", X"A7BD",
        X"A57D", X"A34C", X"A128", X"9F14", X"9D0E", X"9B18", X"9930", X"9759",
        X"9592", X"93DC", X"9236", X"90A1", X"8F1D", X"8DAB", X"8C4A", X"8AFB",
        X"89BE", X"8894", X"877B", X"8676", X"8583", X"84A3", X"83D6", X"831C",
        X"8276", X"81E3", X"8163", X"80F7", X"809E", X"8059", X"8027", X"8009",
        X"8000", X"8009", X"8027", X"8059", X"809E", X"80F7", X"8163", X"81E3",
        X"8276", X"831C", X"83D6", X"84A3", X"8583", X"8676", X"877B", X"8894",
        X"89BE", X"8AFB", X"8C4A", X"8DAB", X"8F1D", X"90A1", X"9236", X"93DC",
        X"9592", X"9759", X"9930", X"9B18", X"9D0E", X"9F14", X"A128", X"A34C",
        X"A57D", X"A7BD", X"AA0A", X"AC64", X"AECC", X"B140", X"B3C0", X"B64C",
        X"B8E3", X"BB85", X"BE32", X"C0E8", X"C3A9", X"C674", X"C946", X"CC21",
        X"CF04", X"D1EE", X"D4E0", X"D7D9", X"DAD8", X"DDDC", X"E0E6", X"E3F4",
        X"E707", X"EA1E", X"ED38", X"F054", X"F374", X"F695", X"F9B8", X"FCDB"
    );
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            faz_biriktici <= (others => '0');
        elsif rising_edge(clk) then
            faz_biriktici <= faz_biriktici + unsigned(frekans_ayar);
        end if;
    end process;
    
    -- Üst 8 bit ile 256 adresi seç
    rom_adres <= std_logic_vector(faz_biriktici(31 downto 24));
    dalga_cikis <= sin_rom(to_integer(unsigned(rom_adres)));
    
end Behavioral;