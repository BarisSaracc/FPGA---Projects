library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity Blink is
    port (
    CLK_50MHZ : in  std_logic;
    LED       : out std_logic;
    reset      : in std_logic
    );
end Blink;

architecture behavioral of Blink is
    signal counter : std_logic_vector(24 downto 0);
    signal led_i : std_logic;
    
begin
    prescaler: process(CLK_50MHZ)
    begin            
    if rising_edge(CLK_50MHZ) then
        
         if reset = '1' then
          counter <= (others => '0');
            led_i   <= '0';
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

    LED <= led_i;
end behavioral;
