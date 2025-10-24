library IEEE;
use IEEE.std_logic_1164.all;

entity Blink is
    port (
        reset    : in std_logic;
        CLK      : in  std_logic;
        button   : in  std_logic;
        button_2   : in  std_logic;
        LED_R    : out std_logic;
        LED_G    : out std_logic
    );
end Blink;

architecture behavioral of Blink is
    signal state : std_logic_vector(1 downto 0) := "00";
    signal prev_button : std_logic := '0';
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            prev_button <= button;
            
            -- Butonun yükselen kenarını tespit et
            if prev_button = '0' and button = '1' then
                case state is
                    when "00" => state <= "01";  -- 00 -> 01
                    when "01" => state <= "10";  -- 01 -> 10
                    when "10" => state <= "11";  -- 10 -> 11
                    when "11" => state <= "00";  -- 11 -> 00
                    when others => state <= "00";
                end case;
            end if;
        end if;
    end process;

    -- LED çıkışları
    LED_R <= '1' when state = "01"  or state = "11" else '0';
    LED_G <= '1' when state = "11"  or state = "10" else '0';
