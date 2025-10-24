library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_UART_Receiver is
end tb_UART_Receiver;

architecture Behavioral of tb_UART_Receiver is

    signal CLK : std_logic := '0';
    signal TX : std_logic := '1';  -- Test bench TX çıkışı (UART verici)
    signal RX_DATA : std_logic_vector(7 downto 0);
    signal RX_RDY : std_logic;
    signal RST : std_logic := '1';
    
    -- UART Receiver component declaration (normal kodunuz - ALICI)
    component UART_Receiver
        port (
            CLK : in std_logic;
            RX : in std_logic;     -- Alıcının RX girişi
            RX_DATA : out std_logic_vector(7 downto 0);
            RX_RDY : out std_logic;
            RST : in std_logic
        );
    end component;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz clock
    constant BIT_TIME : time := 8680 ns; -- 115200 baud rate (434 clock cycles * 20ns)
    
begin

    -- Clock generation process
    clk_process : process
    begin
        CLK <= '0';
        wait for CLK_PERIOD/2;
        CLK <= '1';
        wait for CLK_PERIOD/2;
    end process;
    
    -- Reset process
    reset_process : process
    begin
        RST <= '1';
        wait for 100 ns;
        RST <= '0';
        wait;
    end process;
    
    -- UART transmission process (TEST BENCH TX olarak çalışıyor)
    uart_tx_process : process
    begin
        TX <= '1'; -- Idle state (hat boşta)
        wait for 200 ns; -- Wait for reset to complete
        
        -- Send 'A' character: 0x41 = 01000001 (LSB first)
        
        -- Send Start bit (0)
        TX <= '0';
        wait for BIT_TIME;
        
        -- Send data bits (LSB first)
        TX <= '1'; -- Bit 0 (LSB)
        wait for BIT_TIME;
        TX <= '0'; -- Bit 1
        wait for BIT_TIME;
        TX <= '0'; -- Bit 2
        wait for BIT_TIME;
        TX <= '0'; -- Bit 3
        wait for BIT_TIME;
        TX <= '0'; -- Bit 4
        wait for BIT_TIME;
        TX <= '0'; -- Bit 5
        wait for BIT_TIME;
        TX <= '1'; -- Bit 6
        wait for BIT_TIME;
        TX <= '0'; -- Bit 7 (MSB)
        wait for BIT_TIME;
        
        -- Send Stop bit (1)
        TX <= '1';
        wait for BIT_TIME;
        
        -- Wait and send another character
        wait for 5 * BIT_TIME;
        
        -- Send 'B' character: 0x42 = 01000010
        TX <= '0'; -- Start bit
        wait for BIT_TIME;
        
        TX <= '1'; -- Bit 0 (LSB)
        wait for BIT_TIME;
        TX <= '0'; -- Bit 1
        wait for BIT_TIME;
        TX <= '0'; -- Bit 2
        wait for BIT_TIME;
        TX <= '1'; -- Bit 3
        wait for BIT_TIME;
        TX <= '0'; -- Bit 4
        wait for BIT_TIME;
        TX <= '0'; -- Bit 5
        wait for BIT_TIME;
        TX <= '1'; -- Bit 6
        wait for BIT_TIME;
        TX <= '0'; -- Bit 7 (MSB)
        wait for BIT_TIME;
        
        TX <= '1'; -- Stop bit
        wait for BIT_TIME;
        
        wait;
    end process;
    
    -- Instantiate the UART Receiver (normal kodunuz)
    uut : UART_Receiver
        port map (
            CLK => CLK,
            RX => TX,  --  Test bench'in TX çıkışı, UUT'un RX girişine bağlı
            RX_DATA => RX_DATA,
            RX_RDY => RX_RDY,
            RST => RST
        );

end Behavioral;