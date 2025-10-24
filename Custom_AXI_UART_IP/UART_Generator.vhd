library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART_Generator is
    port(
        CLK : in std_logic;
        TX : out std_logic;
        RST : in std_logic;
        binary: in std_logic_vector(7 downto 0);
        ND: in std_logic
    );
end entity;

architecture rtl of UART_Generator is

    type state_t is (
        IDLE,       -- Boþta
        STARTB,     -- Start biti
        BIT0,       -- Data bit 0 (LSB)
        BIT1,       -- Data bit 1
        BIT2,       -- Data bit 2
        BIT3,       -- Data bit 3
        BIT4,       -- Data bit 4
        BIT5,       -- Data bit 5
        BIT6,       -- Data bit 6
        BIT7,       -- Data bit 7 (MSB) 
        STOPB       -- Stop biti
    );
    
    signal state : state_t := IDLE;
    signal txr   : std_logic := '1';
    signal counter : unsigned(8 downto 0) := (others => '0');
    constant BIT_DURATION : unsigned(8 downto 0) := to_unsigned(434, 9);
    
    signal ascii_binary : std_logic_vector(7 downto 0);
    signal data_ready : std_logic := '0';
    signal nd_sync : std_logic := '0';
    signal nd_prev : std_logic := '0';
    
begin
    TX <= txr;

    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE;
                txr <= '1';
                counter <= (others => '0');
                ascii_binary <= (others => '0');
                data_ready <= '0';
                nd_sync <= '0';
                nd_prev <= '0';
            else
                -- ND sinyalini senkronize et ve yükselen kenarý tespit et
                nd_sync <= ND;
                nd_prev <= nd_sync;
                
                -- Yeni veri geldiðinde (ND'nin yükselen kenarý)
                if nd_prev = '0' and nd_sync = '1' then
                    if state = IDLE then
                        ascii_binary <= binary;
                        data_ready <= '1';
                    end if;
                end if;
                
                -- Counter artýrma ve state geçiþleri
                if state /= IDLE then
                    if counter < BIT_DURATION then
                        counter <= counter + 1;
                    else
                        counter <= (others => '0');

                        case state is
                            when STARTB => state <= BIT0;
                            when BIT0 => state <= BIT1;
                            when BIT1 => state <= BIT2;
                            when BIT2 => state <= BIT3;
                            when BIT3 => state <= BIT4;
                            when BIT4 => state <= BIT5;
                            when BIT5 => state <= BIT6;
                            when BIT6 => state <= BIT7;
                            when BIT7 => state <= STOPB;
                            when STOPB => 
                                state <= IDLE;
                                data_ready <= '0';
                            when others => state <= IDLE;
                        end case;
                    end if;
                end if;
                
                case state is
                    when IDLE =>
                        txr <= '1';
                        if data_ready = '1' then
                            counter <= (others => '0');
                            state <= STARTB;
                        end if;
                        
                    when STARTB =>
                        txr <= '0';
                        
                    when BIT0 =>
                        txr <= ascii_binary(0); -- LSB 
                        
                    when BIT1 =>
                        txr <= ascii_binary(1);
                        
                    when BIT2 =>
                        txr <= ascii_binary(2);
                        
                    when BIT3 =>
                        txr <= ascii_binary(3);
                        
                    when BIT4 =>
                        txr <= ascii_binary(4);
                        
                    when BIT5 =>
                        txr <= ascii_binary(5);
                        
                    when BIT6 =>
                        txr <= ascii_binary(6);
                        
                    when BIT7 =>
                        txr <= ascii_binary(7); -- MSB 
                        
                    when STOPB =>
                        txr <= '1';
                        
                    when others =>
                        txr <= '1';
                end case;
            end if;
        end if;
    end process;
end architecture;