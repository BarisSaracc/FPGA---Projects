library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_UART_System is
end tb_UART_System;

architecture Behavioral of tb_UART_System is

    -- Clock and reset signals
    signal CLK : std_logic := '0';
    signal RST : std_logic := '1';
    
    -- UART Generator (Transmitter) signals
    signal TX : std_logic := '1';
    signal ND : std_logic := '0';
    signal DIN : std_logic_vector(7 downto 0) := (others => '0');
    
    -- UART Receiver signals
    signal DOUT : std_logic_vector(7 downto 0);
    signal RX_RDY : std_logic;
    
    -- Test signals
    signal ERROR_FLAG : std_logic := '0';
    signal ERROR_COUNT : integer := 0;
    signal TEST_COMPLETE : std_logic := '0';
    
    -- Component declarations
    component UART_Generator
        port (
            CLK : in std_logic;
            TX : out std_logic;
            RST : in std_logic;
            ND : in std_logic;
            DIN : in std_logic_vector(7 downto 0)
        );
    end component;
    
    component UART_Receiver
        port (
            CLK : in std_logic;
            RX : in std_logic;
            DOUT : out std_logic_vector(7 downto 0);
            RX_RDY : out std_logic;
            RST : in std_logic
        );
    end component;
    
    -- Clock period definition
    constant CLK_PERIOD : time := 20 ns; -- 50 MHz clock
    
begin

    -- Clock generation process
    clk_process : process
    begin
        while TEST_COMPLETE = '0' loop
            CLK <= '0';
            wait for CLK_PERIOD/2;
            CLK <= '1';
            wait for CLK_PERIOD/2;
        end loop;
        wait;
    end process;
    
    -- Reset process
    reset_process : process
    begin
        RST <= '1';
        wait for 100 ns;
        RST <= '0';
        wait;
    end process;
    
    -- Instantiate UART Generator (Transmitter)
    uart_gen : UART_Generator
        port map (
            CLK => CLK,
            TX => TX,
            RST => RST,
            ND => ND,
            DIN => DIN
        );
    
    -- Instantiate UART Receiver
    uart_recv : UART_Receiver
        port map (
            CLK => CLK,
            RX => TX,
            DOUT => DOUT,
            RX_RDY => RX_RDY,
            RST => RST
        );


    test_process : process
    begin
        wait until RST = '0';
        wait for 100 ns;
        

        for i in 0 to 255 loop
            DIN <= std_logic_vector(to_unsigned(i, 8));
            ND <= '1'; -- Enable data transmission
            wait for CLK_PERIOD;
            ND <= '0';
            
            -- Wait for RX_RDY to go high (data received)
            wait until rising_edge(CLK) and RX_RDY = '1';
            
            -- Verify received data (DIN vs DOUT)
--            if (DOUT = DIN) then
--                ERROR_FLAG <= '0'; -- No error
--                report "Test PASSED for value: " & integer'image(i) severity note;
--            else
--                ERROR_FLAG <= '1'; -- Error
--                ERROR_COUNT <= ERROR_COUNT + 1;
               
--            end if;
            assert (DOUT = DIN);

            wait for 10 * CLK_PERIOD;
        end loop;
        
        TEST_COMPLETE <= '1';
        if ERROR_COUNT = 0 then
            report "All tests PASSED!" severity note;
        else
            report "Test completed with " & integer'image(ERROR_COUNT) & " errors!" severity error;
        end if;
        wait;
    end process;

end Behavioral;