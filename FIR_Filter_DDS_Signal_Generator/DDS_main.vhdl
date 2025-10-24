library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tam_dds is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        frekans_ayar : in STD_LOGIC_VECTOR(15 downto 0);
        dalga_cikis : out STD_LOGIC_VECTOR(15 downto 0)
    );
end tam_dds;

architecture Behavioral of tam_dds is
    signal sayac : unsigned(31 downto 0) := (others => '0'); -- 32 bit 
    
    -- 128 örnekli sinüs ROM'u (16-bit)
    type rom_tipi is array (0 to 127) of std_logic_vector(15 downto 0);
    constant sin_rom : rom_tipi := (
        X"8000", X"8647", X"8C8B", X"92C7", X"98F8", X"9F19", X"A527", X"AB1F",
        X"B0FB", X"B6B9", X"BC56", X"C1CD", X"C71C", X"CC3F", X"D133", X"D5F5",
        X"DA82", X"DED7", X"E2F1", X"E6CF", X"EA6D", X"EDC9", X"F0E2", X"F3B5",
        X"F641", X"F884", X"FA7C", X"FC29", X"FD89", X"FE9C", X"FF61", X"FFD8",
        X"FFFF", X"FFD8", X"FF61", X"FE9C", X"FD89", X"FC29", X"FA7C", X"F884",
        X"F641", X"F3B5", X"F0E2", X"EDC9", X"EA6D", X"E6CF", X"E2F1", X"DED7",
        X"DA82", X"D5F5", X"D133", X"CC3F", X"C71C", X"C1CD", X"BC56", X"B6B9",
        X"B0FB", X"AB1F", X"A527", X"9F19", X"98F8", X"92C7", X"8C8B", X"8647",
        X"8000", X"79B8", X"7374", X"6D38", X"6707", X"60E6", X"5AD8", X"54E0",
        X"4F04", X"4946", X"43A9", X"3E32", X"38E3", X"33C0", X"2ECC", X"2A0A",
        X"257D", X"2128", X"1D0E", X"1930", X"1592", X"1236", X"0F1D", X"0C4A",
        X"09BE", X"077B", X"0583", X"03D6", X"0276", X"0163", X"009E", X"0027",
        X"0000", X"0027", X"009E", X"0163", X"0276", X"03D6", X"0583", X"077B",
        X"09BE", X"0C4A", X"0F1D", X"1236", X"1592", X"1930", X"1D0E", X"2128",
        X"257D", X"2A0A", X"2ECC", X"33C0", X"38E3", X"3E32", X"43A9", X"4946",
        X"4F04", X"54E0", X"5AD8", X"60E6", X"6707", X"6D38", X"7374", X"79B8"
    );
    
begin
    process(clk, reset)
    begin
        if reset = '1' then
            sayac <= (others => '0');
        elsif rising_edge(clk) then
            sayac <= sayac + unsigned(frekans_ayar);
        end if;
    end process;
    
    -- Üst 7 bit ile 128 adresi seç (0-127 arası)
    dalga_cikis <= sin_rom(to_integer(sayac(31 downto 25)));
    
end Behavioral;
