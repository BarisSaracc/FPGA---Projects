library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Blink is
    port (
        CLK_50MHZ : in  std_logic;
        LED_R     : out std_logic;
        LED_G     : out std_logic;
        reset     : in std_logic;
        button    : in std_logic
    );
end Blink;

architecture behavioral of Blink is
    signal counter : std_logic_vector(24 downto 0);
    signal counter2 : std_logic_vector(24 downto 0);
    signal counter_db : std_logic_vector(24 downto 0);
    signal led_i   : std_logic;
    signal led_k   : std_logic := '0';
    signal prev_btn : std_logic := '0';
    signal stb_btn   : std_logic;
    
begin
    -- Green LED
    prescaler: process(CLK_50MHZ)
    begin        
        if rising_edge(CLK_50MHZ) then
            if reset = '1' then
                led_i   <= '0';
                counter <= (others => '0');             
            else
                if (to_integer(unsigned(counter)) < 25000000) then
                    counter <= std_logic_vector(unsigned(counter) + 1);
                else
                    led_i <= not led_i;
                    counter <= (others => '0');
                end if;
            end if;
        end if;
    end process prescaler;

      -- Red LED
    red_proc: process(CLK_50MHZ)
    begin
    if rising_edge(CLK_50MHZ) then
            if button /= stb_btn then
    counter_db <= std_logic_vector(unsigned(counter_db) + 1);
    if (to_integer(unsigned(counter_db)) < 1000000) then      --20ms bekle tekrar oku
                    stb_btn <= button;    
                     counter_db <= (others => '0'); 
                end if;
            else
                counter_db <= (others => '0'); 
            end if;
            if prev_btn = '0' and stb_btn = '1' then
                led_k <= not led_k;
            end if;
            prev_btn <= stb_btn;
        end if;
    end process red_proc;

    LED_R <= led_k;
    LED_G <= led_i;

end behavioral;
