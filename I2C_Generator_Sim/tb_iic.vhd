library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_I2C_Master is
end tb_I2C_Master;

architecture Behavioral of tb_I2C_Master is

    -- Function to reverse bit order of a std_logic_vector
    function reverse_vector(v : std_logic_vector) return std_logic_vector is
        variable r : std_logic_vector(v'range);
    begin
        for i in v'range loop
            r(i) := v(v'length - 1 - i);
        end loop;
        return r;
    end function;


    signal CLK : std_logic := '0';
    signal RST : std_logic := '1';
    signal slave_addr : std_logic_vector(6 downto 0) := (others => '0');
    signal rw_bit : std_logic := '0';
    signal start : std_logic := '0';
    signal repeat : std_logic := '0';
    signal addr_in : std_logic_vector(7 downto 0) := (others => '0');
    signal data_in : std_logic_vector(7 downto 0) := (others => '0');
    
    -- I2C signals
    signal scl_in : std_logic := '1';
    signal scl_out : std_logic;
    signal scl_t : std_logic;
    signal sda_in : std_logic := '1';
    signal sda_out : std_logic;
    signal sda_t : std_logic;
    
    signal busy : std_logic;
    signal ack_error : std_logic;
    
    signal sda: std_logic;
    signal scl: std_logic;

    -- Slave simulation signals
    signal slave_sda_out : std_logic := '1';
    signal slave_sda_t : std_logic := '1';


    signal repeat_wait_reg    : std_logic := '0';
    signal skip_last_pulse    : std_logic := '0';

    -- Slave state machine for ACK control
    type slave_state_type is (
        IDLE,
        WAIT_FOR_START,
        RECEIVE_SLAVE_ADDR,
        SEND_ACK1,
        RECEIVE_REG_ADDR,
        SEND_ACK2,
        RECEIVE_DATA,
        SEND_ACK3,
        COMPLETE
    );
    signal slave_state : slave_state_type := IDLE;
    signal bit_counter : integer range 0 to 7 := 0;

    component I2C_Master
        port (
            CLK      : in std_logic;
            RST      : in std_logic;
            slave_addr : in std_logic_vector(6 downto 0);
            rw_bit   : in std_logic;
            start    : in std_logic;
            repeat   : in std_logic;
            addr_in  : in std_logic_vector(7 downto 0);
            data_in  : in std_logic_vector(7 downto 0);
            scl_in   : in std_logic;
            scl_out  : out std_logic;
            scl_t    : out std_logic;
            sda_in   : in std_logic;
            sda_out  : out std_logic;
            sda_t    : out std_logic;
            busy     : out std_logic;
            ack_error : out std_logic
        );
    end component;

begin

    sda <= sda_out when sda_t = '0' else
           slave_sda_out when slave_sda_t = '0' else 'H';
    scl <= scl_out when scl_t = '0' else 'H'; 

    scl_in <= scl;
    sda_in <= sda;

    -- Clock generation (50 MHz)
    process 
    begin
        CLK <= '0';
        wait for 10 ns;
        CLK <= '1';
        wait for 10 ns;
    end process;


    process(scl, RST)
    begin
        if RST = '1' then
            slave_state <= IDLE;
            slave_sda_out <= '1';
            slave_sda_t <= '1';
            bit_counter <= 7;  -- 7'den baþla (MSB first)
        elsif falling_edge(scl) then
            case slave_state is
                when IDLE =>
                    if sda = '0' and scl = '1' then  -- START condition detected
                        slave_state <= RECEIVE_SLAVE_ADDR;
                        bit_counter <= 7;  -- 7'den baþla
                    end if;
                    
                when RECEIVE_SLAVE_ADDR =>
                    if bit_counter = 0 then  -- 0'a ulaþtýysak
                        slave_state <= SEND_ACK1;
                        bit_counter <= 7;  -- Reset to 7 for next byte
                    else
                        bit_counter <= bit_counter - 1;  -- Azalarak ilerle (7?6?5?4?3?2?1?0)
                    end if;
                    
                when SEND_ACK1 =>
                    slave_sda_out <= '0';  -- Send ACK
                    slave_sda_t <= '0';
                    slave_state <= RECEIVE_REG_ADDR;
                    bit_counter <= 7;  -- 7'den baþla
                    
                when RECEIVE_REG_ADDR =>
                    if bit_counter = 0 then  -- 0'a ulaþtýysak
                        slave_state <= SEND_ACK2;
                        bit_counter <= 7;  -- Reset to 7 for next byte
                    else
                        bit_counter <= bit_counter - 1;  -- Azalarak ilerle (7?6?5?4?3?2?1?0)
                    end if;
                    
                when SEND_ACK2 =>
                    slave_sda_out <= '0';  -- Send ACK
                    slave_sda_t <= '0';
                    slave_state <= RECEIVE_DATA;
                    bit_counter <= 7;  -- 7'den baþla
                    
                when RECEIVE_DATA =>
                    if bit_counter = 0 then  -- 0'a ulaþtýysak
                        slave_state <= SEND_ACK3;
                        bit_counter <= 7;  -- Reset to 7 for next slave address
                    else
                        bit_counter <= bit_counter - 1;  -- Azalarak ilerle (7?6?5?4?3?2?1?0)
                    end if;
                    
                when SEND_ACK3 =>
                    slave_sda_out <= '0';  -- Send ACK
                    slave_sda_t <= '0';
                    slave_state <= COMPLETE;
                    
                when COMPLETE =>
                    if sda = '1' and scl = '1' then  -- STOP condition detected
                        slave_state <= IDLE;
                        slave_sda_t <= '1';
                        bit_counter <= 7;  -- Reset to 7 for next slave address
                    elsif sda = '0' and scl = '1' then  -- Repeated START
                        slave_state <= RECEIVE_SLAVE_ADDR;
                        bit_counter <= 7;  -- 7'den baþla
                        slave_sda_t <= '1';
                    end if;
                    
                when others =>
                    slave_state <= IDLE;
                    bit_counter <= 7;  -- 7'den baþla
            end case;
        elsif rising_edge(scl) then
            -- Release ACK after SCL rises
            if slave_state = SEND_ACK1 or slave_state = SEND_ACK2 or slave_state = SEND_ACK3 then
                slave_sda_t <= '1';
                if slave_state = SEND_ACK1 then
                    slave_state <= RECEIVE_REG_ADDR;
                elsif slave_state = SEND_ACK2 then
                    slave_state <= RECEIVE_DATA;
                elsif slave_state = SEND_ACK3 then
                    slave_state <= COMPLETE;
                end if;
            end if;
        end if;
    end process;

    -- Test process
    process
        -- I2C start procedure
       procedure i2c_start(
    slave_addr_in : std_logic_vector(6 downto 0); 
    rw_in : std_logic; 
    repeat_in : std_logic;
    addr_in_val : std_logic_vector(7 downto 0);
    data_in_val : std_logic_vector(7 downto 0)
) is
begin
    -- Reverse all inputs before sending to DUT
    slave_addr <= (slave_addr_in);
    rw_bit <= rw_in;
    repeat <= repeat_in;
    addr_in <= (addr_in_val);
    data_in <= (data_in_val);

            wait for 1 us;
            start <= '1';
            wait for 100 ns;
            start <= '0';
            wait for 1 us;
        end procedure;
        
        -- Complete I2C transaction procedure
        procedure i2c_transaction(
            slave_addr_in : std_logic_vector(6 downto 0); 
            rw_in : std_logic; 
            repeat_in : std_logic;
            addr_in_val : std_logic_vector(7 downto 0);
            data_in_val : std_logic_vector(7 downto 0)
        ) is
        begin
            i2c_start(slave_addr_in, rw_in, repeat_in, addr_in_val, data_in_val);
            
            -- Wait for transaction to complete (state machine handles ACKs)
            wait until busy = '0';
            wait for 10 us;
        end procedure;

    begin
        RST <= '1';
        slave_addr <= (others => '0');
        rw_bit <= '0';
        start <= '0';
        repeat <= '0';
        addr_in <= (others => '0');
        data_in <= (others => '0');

        wait for 100 ns;
        
        RST <= '0';
        wait for 200 ns;
        
        -- Test 1: Complete transaction with different address and data
        report "Test 1: Slave=0x55, Addr=0xAA, Data=0x55";
        i2c_transaction("1111000", '0', '0', "10101010", "01010101");
        wait for 30 us;
        
        -- Test 2: Different values
        report "Test 2: Slave=0x2A, Addr=0x33, Data=0xCC";
        i2c_transaction("0101010", '0', '0', "00110011", "11001100");
        wait for 30 us;
        
        -- Test 3: All ones
        report "Test 3: Slave=0x7F, Addr=0xFF, Data=0xFF";
        i2c_transaction("1111111", '0', '0', "11111111", "11111111");
        wait for 30 us;
        
        -- Test 4: All zeros
        report "Test 4: Slave=0x00, Addr=0x00, Data=0x00";
        i2c_transaction("0000000", '0', '0', "00000000", "00000000");
        wait for 30 us;
        
        -- Test 5: Mixed pattern
        report "Test 5: Slave=0x4A, Addr=0x5C, Data=0xE7";
        i2c_transaction("1001010", '0', '0', "01011100", "11100111");
        wait for 30 us;

        -- Test 6: Repeat start condition
        report "Test 6: Repeat start transaction";
        i2c_transaction("1010101", '0', '1', "10101010", "01010101");
        wait for 30 us;
        
        -- Test 7: Another transaction after repeat
        report "Test 7: Transaction after repeat";
        i2c_transaction("0101010", '0', '0', "00001111", "11110000");
        wait for 30 us;
        
        -- Test 8: Final test with repeat
        report "Test 8: Final transaction with repeat";
        i2c_transaction("1110001", '0', '1', "11001100", "00110011");
        wait for 30 us;
        
        report "All tests completed";
        wait;
    end process;

    -- UUT
    uut : I2C_Master
        port map(
            CLK => CLK,
            RST => RST,
            slave_addr => slave_addr,
            rw_bit => rw_bit,
            start => start,
            repeat => repeat,
            addr_in => addr_in,
            data_in => data_in,
            scl_in => scl_in,
            scl_out => scl_out,
            scl_t => scl_t,
            sda_in => sda_in,
            sda_out => sda_out,
            sda_t => sda_t,
            busy => busy,
            ack_error => ack_error
        );

end Behavioral;