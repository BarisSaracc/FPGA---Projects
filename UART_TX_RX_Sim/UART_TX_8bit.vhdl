library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity UART_Generator is
    port(
        CLK : in std_logic;
        TX : out std_logic;
        RST : in std_logic;
        ND : in std_logic;
        DIN : in std_logic_vector(7 downto 0)  -- Yeni eklenen data girişi
    );
end entity;

architecture rtl of UART_Generator is
    type state_t is (
        IDLE,       -- Hattın boşta olduğu durum
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
    signal counter : integer := 0;
    signal data_byte : std_logic_vector(7 downto 0) := (others => '0');
    signal data_ready : std_logic := '0';
    signal data_latch : std_logic_vector(7 downto 0) := (others => '0');
    
    constant BIT_DURATION : integer := 434; -- 434 clock darbesi bekleme
    
begin
    TX <= txr;

    -- DIN girişindeki veriyi yakalama process'i
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                data_ready <= '0';
                data_latch <= (others => '0');
            elsif ND = '1' and data_ready = '0' then
                -- Yeni veri geldi, latch'le ve göndermeye hazırlan
                data_latch <= DIN;
                data_ready <= '1';
            elsif state = IDLE and data_ready = '1' then
                -- Veri gönderildi, hazır durumuna dön
                data_ready <= '0';
            end if;
        end if;
    end process;

    -- UART veri gönderme process'i
    process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE;
                txr <= '1';
                counter <= 0;
                data_byte <= (others => '0');
            else
                case state is
                    when IDLE =>
                        txr <= '1';
                        if data_ready = '1' then
                            -- Yeni veriyi al ve göndermeye başla
                            data_byte <= data_latch;
                            counter <= 0;
                            state <= STARTB;
                        end if;

                    when STARTB =>
                        txr <= '0';
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= BIT0;
                        end if;

                    when BIT0 =>
                        txr <= data_byte(0); -- LSB
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= BIT1;
                        end if;

                    when BIT1 =>
                        txr <= data_byte(1);
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= BIT2;
                        end if;

                    when BIT2 =>
                        txr <= data_byte(2);
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= BIT3;
                        end if;

                    when BIT3 =>
                        txr <= data_byte(3);
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= BIT4;
                        end if;

                    when BIT4 =>
                        txr <= data_byte(4);
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= BIT5;
                        end if;

                    when BIT5 =>
                        txr <= data_byte(5);
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= BIT6;
                        end if;

                    when BIT6 =>
                        txr <= data_byte(6);
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= BIT7;
                        end if;

                    when BIT7 =>
                        txr <= data_byte(7); -- MSB
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= STOPB;
                        end if;

                    when STOPB =>
                        txr <= '1';
                        if counter < BIT_DURATION then
                            counter <= counter + 1;
                        else
                            counter <= 0;
                            state <= IDLE;
                        end if;

                end case;
            end if;
        end if;
    end process;
end architecture;
