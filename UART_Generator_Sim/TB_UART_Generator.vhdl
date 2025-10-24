library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_UART_Generator is
end tb_UART_Generator;

architecture Behavioral of tb_UART_Generator is

    signal CLK : std_logic := '0';
    signal TX : std_logic := '1';
    signal RST : std_logic := '1';
    signal Binary_in : std_logic_vector(7 downto 0);
    signal ND_in : std_logic;

    component UART_Generator
        port (
            CLK : in  std_logic;
            TX  : out std_logic;
            RST : in  std_logic;
            binary: in std_logic_vector(7 downto 0);
            ND: in std_logic
        );
    end component;

begin

    -- Clock generation (50 MHz)
    process 
    begin
        CLK <= '0';
        wait for 10 ns;
        CLK <= '1';
        wait for 10 ns;
    end process;

    -- Test process
    process
        procedure send_character(data : in std_logic_vector(7 downto 0)) is
        begin
            Binary_in <= data;
            wait for 1 us;
            ND_in <= '1';
            wait for 100 ns;  -- ND sinyalini biraz daha uzun tut
            ND_in <= '0';
            wait for 1 us;
        end procedure;
    begin
        RST <= '1';
        ND_in <= '0';
        Binary_in <= (others => '0');

        wait for 100 ns;
        
        RST <= '0';
        wait for 200 us;
        
        
        -- Test verileri - ASCII karakterleri
        ND_in <= '1';
        send_character("01000001");  -- 'A' karakteri
        ND_in <= '0';
        wait for 900 us;   -- Bir karakterin g nderilmesini bekle
        ND_in <= '1';
        send_character("01000010");  -- 'B' karakteri
        ND_in <= '0';
        wait for 900 us;
        
       
        
        wait;
    end process;
    
    -- UUT
    uut : UART_Generator
        port map(
            CLK => CLK,
            TX  => TX,
            RST => RST,
            binary => Binary_in,
            ND => ND_in
        );

end Behavioral;
