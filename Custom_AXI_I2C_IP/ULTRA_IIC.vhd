library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity I2C_Master is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        slave_addr : in std_logic_vector(6 downto 0);
        rw_bit   : in std_logic;  -- '0' for write, '1' for read
        start    : in std_logic;
        repeat   : in std_logic;  -- '0' for stop, '1' for repeat start
        addr_in  : in std_logic_vector(7 downto 0);  -- Address register input
        data_in  : in std_logic_vector(7 downto 0);  -- Data input
        
        -- I2C signals
        scl_in   : in std_logic;
        scl_out  : out std_logic;
        scl_t    : out std_logic;  -- '1' when high impedance
        sda_in   : in std_logic;
        sda_out  : out std_logic;
        sda_t    : out std_logic;  -- '1' when high impedance
        
        ack_counter: out std_logic_vector(7 downto 0);
        
        busy     : out std_logic;
        ack_error : out std_logic
    );
end entity;

architecture rtl of I2C_Master is

COMPONENT ila_0
PORT (
    clk : IN STD_LOGIC;
    probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe1 : IN STD_LOGIC_VECTOR(6 DOWNTO 0); 
    probe2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe3 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe4 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe5 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
    probe6 : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
    probe7 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe8 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe9 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe10 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe11 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe12 : IN STD_LOGIC_VECTOR(0 DOWNTO 0); 
    probe13 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    probe14 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
);
END COMPONENT;

    type state_t is (
        IDLE,
        START_CONDITION,
        SEND_SLAVE_ADDR,
        WAIT_ACK1,
        SEND_ADDR_REG,
        WAIT_ACK2,
        SEND_DATA,
        WAIT_ACK3,
        STOP_CONDITION
    );
    
    signal state : state_t := IDLE;
    
    -- SCL generation
    signal scl_counter : unsigned(7 downto 0) := (others => '0');
    signal scl_enable : std_logic := '0';
    signal scl_high : std_logic := '0';
    signal scl_low : std_logic := '0';
    
    -- Data registers
    signal slave_addr_reg : std_logic_vector(6 downto 0) := (others => '0');
    signal addr_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal data_reg : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Bit counter and shift registers
    signal bit_counter : integer range 0 to 7 := 0;
    signal shift_reg : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Control signals
    signal start_detected : std_logic := '0';
    signal start_prev : std_logic := '0';
    
    -- Output registers
    signal scl_out_reg : std_logic := '1';
    signal sda_out_reg : std_logic := '1';
    signal sda_t_reg : std_logic := '1';
    
    -- ACK counter
    signal ack_counter_reg : std_logic_vector(7 downto 0) := (others => '0');
    
    -- ILA probe signals
    signal probe0_sig : std_logic_vector(0 downto 0);
    signal probe1_sig : std_logic_vector(6 downto 0);
    signal probe2_sig : std_logic_vector(0 downto 0);
    signal probe3_sig : std_logic_vector(0 downto 0);
    signal probe4_sig : std_logic_vector(0 downto 0);
    signal probe5_sig : std_logic_vector(7 downto 0);
    signal probe6_sig : std_logic_vector(7 downto 0);
    signal probe7_sig : std_logic_vector(0 downto 0);
    signal probe8_sig : std_logic_vector(0 downto 0);
    signal probe9_sig : std_logic_vector(0 downto 0);
    signal probe10_sig : std_logic_vector(0 downto 0);
    signal probe11_sig : std_logic_vector(0 downto 0);
    signal probe12_sig : std_logic_vector(0 downto 0);
    signal probe13_sig : std_logic_vector(2 downto 0);
    signal probe14_sig : std_logic_vector(7 downto 0); 
    
    -- Internal signals for monitoring
    signal busy_int : std_logic := '0';
    signal ack_error_int : std_logic := '0';
    
    -- ACK detection signals
    signal ack1_received : std_logic := '0';
    signal ack2_received : std_logic := '0';
    signal ack3_received : std_logic := '0';
    
    -- Constants for 100 kHz SCL with 50 MHz CLK
    constant SCL_HALF_PERIOD : unsigned(7 downto 0) := to_unsigned(250, 8);
    
begin

    -- Output assignments
    scl_out <= scl_out_reg;
    sda_out <= sda_out_reg;
    sda_t <= sda_t_reg;
    scl_t <= '0';
    busy <= busy_int;
    ack_error <= ack_error_int;
    ack_counter <= ack_counter_reg;

    -- Connect ILA probe signals
    probe0_sig(0) <= RST;
    probe1_sig <= slave_addr;
    probe2_sig(0) <= rw_bit;
    probe3_sig(0) <= start;
    probe4_sig(0) <= repeat;
    probe5_sig <= addr_in;
    probe6_sig <= data_in;
    probe7_sig(0) <= scl_in;
    probe8_sig(0) <= scl_out_reg;
    probe9_sig(0) <= '0';  -- scl_t is always '0'
    probe10_sig(0) <= sda_in;
    probe11_sig(0) <= sda_out_reg;
    probe12_sig(0) <= sda_t_reg;
    probe13_sig <= std_logic_vector(to_unsigned(bit_counter, 3));  -- 3 bit for 0-7 values
    probe14_sig <= std_logic_vector(ack_counter_reg);  -- DÜZELTME: Tüm 8 bit'i baðla

    -- ILA instance
    UART_ILA0 : ila_0
    PORT MAP (
        clk => CLK,
        probe0 => probe0_sig,
        probe1 => probe1_sig,
        probe2 => probe2_sig,
        probe3 => probe3_sig,
        probe4 => probe4_sig,
        probe5 => probe5_sig,
        probe6 => probe6_sig,
        probe7 => probe7_sig,
        probe8 => probe8_sig,
        probe9 => probe9_sig,
        probe10 => probe10_sig,
        probe11 => probe11_sig,
        probe12 => probe12_sig,
        probe13 => probe13_sig,
        probe14 => probe14_sig
    );

    -- SCL clock generation process
    scl_gen_process: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                scl_counter <= (others => '0');
                scl_high <= '0';
                scl_low <= '0';
                scl_out_reg <= '1';
            else
                if scl_enable = '1' then
                    if scl_counter < SCL_HALF_PERIOD - 1 then
                        scl_counter <= scl_counter + 1;
                        scl_high <= '0';
                        scl_low <= '0';
                    else
                        scl_counter <= (others => '0');
                        if scl_out_reg = '1' then
                            scl_high <= '1';
                            scl_low <= '0';
                            scl_out_reg <= '0';
                        else
                            scl_low <= '1';
                            scl_high <= '0';
                            scl_out_reg <= '1';
                        end if;
                    end if;
                else
                    scl_counter <= (others => '0');
                    if repeat = '0' then
                        scl_out_reg <= '1';
                    else
                        scl_out_reg <= '0';
                    end if;
                    scl_high <= '0';
                    scl_low <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Start signal detection
    start_detection: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                start_prev <= '0';
                start_detected <= '0';
            else
                start_prev <= start;
                if start_prev = '0' and start = '1' then
                    start_detected <= '1';
                elsif state /= IDLE then
                    start_detected <= '0';
                end if;
            end if;
        end if;
    end process;

    -- ACK Counter Process
    ack_counter_process: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                ack_counter_reg <= (others => '0');
                ack1_received <= '0';
                ack2_received <= '0';
                ack3_received <= '0';
            else
                -- Reset counter on start
                if start_detected = '1' then
                    ack_counter_reg <= (others => '0');
                    ack1_received <= '0';
                    ack2_received <= '0';
                    ack3_received <= '0';
                else
                    -- ACK1 detection (after slave address)
                    if state = WAIT_ACK1 and scl_high = '1' and ack1_received = '0' then
                        if sda_in = '0' then  -- ACK received (low)
                            ack_counter_reg <= std_logic_vector(unsigned(ack_counter_reg) + 1);
                        end if;
                        ack1_received <= '1';
                    
                    -- ACK2 detection (after address register)
                    elsif state = WAIT_ACK2 and scl_high = '1' and ack2_received = '0' then
                        if sda_in = '0' then  -- ACK received (low)
                            ack_counter_reg <= std_logic_vector(unsigned(ack_counter_reg) + 1);
                        end if;
                        ack2_received <= '1';
                    
                    -- ACK3 detection (after data)
                    elsif state = WAIT_ACK3 and scl_high = '1' and ack3_received = '0' then
                        if sda_in = '0' then  -- ACK received (low)
                            ack_counter_reg <= std_logic_vector(unsigned(ack_counter_reg) + 1);
                        end if;
                        ack3_received <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Main state machine with MSB first transmission (bit_counter 7->0)
    main_fsm: process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '1' then
                state <= IDLE;
                slave_addr_reg <= (others => '0');
                addr_reg <= (others => '0');
                data_reg <= (others => '0');
                shift_reg <= (others => '0');
                bit_counter <= 7; -- Start from MSB (bit 7)
                scl_enable <= '0';
                sda_out_reg <= '1';
                sda_t_reg <= '1';
                busy_int <= '0';
                ack_error_int <= '0';
            else
                case state is
                    when IDLE =>
                        busy_int <= '0';
                        ack_error_int <= '0';
                        scl_enable <= '0';
                        sda_out_reg <= '1';
                        sda_t_reg <= '0';
                        bit_counter <= 7; -- Reset to MSB (bit 7)
                        
                        if start_detected = '1' then
                            state <= START_CONDITION;
                            busy_int <= '1';
                            slave_addr_reg <= slave_addr;
                            addr_reg <= addr_in;
                            data_reg <= data_in;
                        end if;
                        
                    when START_CONDITION =>
                        sda_out_reg <= '0';
                        sda_t_reg <= '0';
                        scl_enable <= '1';
                        
                        if scl_high = '1' then
                            -- Slave address: 6,5,4,3,2,1,0,rw (MSB first, rw bit last)
                            shift_reg <= slave_addr_reg & rw_bit;
                            state <= SEND_SLAVE_ADDR;
                            bit_counter <= 7; -- Start from MSB (bit 7)
                        end if;
                        
                    -- Send slave address: address bits 6 to 0 first, then rw bit
                    -- Order: 6,5,4,3,2,1,0,rw (MSB first)
                    when SEND_SLAVE_ADDR =>
                        -- Send bits in order: 7,6,5,4,3,2,1,0 (MSB to LSB)
                        sda_out_reg <= shift_reg(bit_counter);
                        sda_t_reg <= '0';
                        
                        if scl_high = '1' then
                            if bit_counter > 0 then
                                bit_counter <= bit_counter - 1;
                            else
                                -- All bits sent, wait for ACK
                                state <= WAIT_ACK1;
                                sda_out_reg <= '0'; -- Release SDA for ACK
                                sda_t_reg <= '1';   -- High impedance for ACK
                            end if;
                        end if;
                        
                    -- Wait for ACK after slave address
                    when WAIT_ACK1 =>
                        sda_t_reg <= '1'; -- High impedance for ACK detection
                        if scl_high = '1' then
                            -- Address register: 7,6,5,4,3,2,1,0 (MSB first)
                            shift_reg <= addr_reg;
                            state <= SEND_ADDR_REG;
                            bit_counter <= 7; -- Start from MSB (bit 7)
                        end if;
                        
                    -- Send address register (8 bits) - MSB first
                    -- Order: 7,6,5,4,3,2,1,0
                    when SEND_ADDR_REG =>
                        -- Send bits in order: 7,6,5,4,3,2,1,0 (MSB to LSB)
                        sda_out_reg <= shift_reg(bit_counter);
                        sda_t_reg <= '0';
                        
                        if scl_high = '1' then
                            if bit_counter > 0 then
                                bit_counter <= bit_counter - 1;
                            else
                                -- All bits sent, wait for ACK
                                state <= WAIT_ACK2;
                                sda_out_reg <= '0'; -- Release SDA for ACK
                                sda_t_reg <= '1';   -- High impedance for ACK
                            end if;
                        end if;
                        
                    -- Wait for ACK after address register
                    when WAIT_ACK2 =>
                        sda_t_reg <= '1'; -- High impedance for ACK detection
                        if scl_high = '1' then
                            -- Data: 7,6,5,4,3,2,1,0 (MSB first)
                            shift_reg <= data_reg;
                            state <= SEND_DATA;
                            bit_counter <= 7; -- Start from MSB (bit 7)
                        end if;
                        
                    -- Send data (8 bits) - MSB first
                    -- Order: 7,6,5,4,3,2,1,0
                    when SEND_DATA =>
                        -- Send bits in order: 7,6,5,4,3,2,1,0 (MSB to LSB)
                        sda_out_reg <= shift_reg(bit_counter);
                        sda_t_reg <= '0';
                        
                        if scl_high = '1' then
                            if bit_counter > 0 then
                                bit_counter <= bit_counter - 1;
                            else
                                -- All bits sent, wait for ACK
                                state <= WAIT_ACK3;
                                sda_out_reg <= '0'; -- Release SDA for ACK
                                sda_t_reg <= '1';   -- High impedance for ACK
                            end if;
                        end if;
                        
                    -- Wait for ACK after data
                    when WAIT_ACK3 =>
                        sda_t_reg <= '1'; -- High impedance for ACK detection
                        if scl_high = '1' then
                            state <= STOP_CONDITION;
                        end if;
                        
                    when STOP_CONDITION =>
                        sda_t_reg <= '0';
                        
                        -- SCL low olduðunda SDA'yý low'da tut
                        if scl_out_reg = '0' then
                            sda_out_reg <= '0';
                        else
                            -- SCL high olduðunda SDA'yý high yap (stop condition)
                            sda_out_reg <= '1';                
                            state <= IDLE;
                        end if;
                        
                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process;

end architecture;