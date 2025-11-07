library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity video_generator is
    Port ( 
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        de    : out STD_LOGIC;  -- Data Enable output
        data  : out STD_LOGIC_VECTOR(23 downto 0)  -- 24-bit RGB data output
    );
end video_generator;

architecture Behavioral of video_generator is
    
    -- Horizontal timing constants
    constant H_TOTAL  : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2200, 12));
    constant H_SYNC_START : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2156, 12));
    constant H_SYNC_END   : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2200, 12));
    
    -- Vertical timing constants  
    constant V_TOTAL  : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1125, 12));
    constant V_SYNC_START : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1120, 12));
    constant V_SYNC_END   : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1125, 12));
    
    -- Active video region constants
    constant H_ACTIVE_START : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(147, 12));
    constant H_ACTIVE_END   : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(2067, 12));
    constant V_ACTIVE_START : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(35, 12));
    constant V_ACTIVE_END   : STD_LOGIC_VECTOR(11 downto 0) := STD_LOGIC_VECTOR(to_unsigned(1115, 12));
    
    -- Counters
    signal h_counter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal v_counter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    
    -- Internal signals for active regions
    signal h_active : STD_LOGIC;
    signal v_active : STD_LOGIC;
    
    -- Color bar state machine type and signal
    type color_bar_state is (
        BAR_WHITE,
        BAR_YELLOW, 
        BAR_CYAN,
        BAR_GREEN,
        BAR_MAGENTA,
        BAR_RED,
        BAR_BLUE,
        BAR_BLACK
    );
    signal current_bar_state : color_bar_state;
    
begin

    -- Counter process
    counter_process : process(clk, rst)
    begin
        if rst = '1' then
            h_counter <= (others => '0');
            v_counter <= (others => '0');
        elsif rising_edge(clk) then
            -- Horizontal counter
            if unsigned(h_counter) = unsigned(H_TOTAL) - 1 then
                h_counter <= (others => '0');
                
                -- Vertical counter
                if unsigned(v_counter) = unsigned(V_TOTAL) - 1 then
                    v_counter <= (others => '0');
                else
                    v_counter <= STD_LOGIC_VECTOR(unsigned(v_counter) + 1);
                end if;
            else
                h_counter <= STD_LOGIC_VECTOR(unsigned(h_counter) + 1);
            end if;
        end if;
    end process;
    
    -- Sync generation process
    sync_process : process(clk, rst)
    begin
        if rst = '1' then
            hsync <= '0';
            vsync <= '0';
        elsif rising_edge(clk) then
            -- Horizontal sync generation (Active HIGH)
            if (unsigned(h_counter) >= unsigned(H_SYNC_START)) and 
               (unsigned(h_counter) < unsigned(H_SYNC_END)) then
                hsync <= '1';
            else
                hsync <= '0';
            end if;
            
            -- Vertical sync generation (Active HIGH)
            if (unsigned(v_counter) >= unsigned(V_SYNC_START)) and 
               (unsigned(v_counter) < unsigned(V_SYNC_END)) then
                vsync <= '1';
            else
                vsync <= '0';
            end if;
        end if;
    end process;
    
    -- Active region detection process
    active_process : process(clk, rst)
    begin
        if rst = '1' then
            h_active <= '0';
            v_active <= '0';
        elsif rising_edge(clk) then
            -- Horizontal active region
            if (unsigned(h_counter) >= unsigned(H_ACTIVE_START)) and 
               (unsigned(h_counter) < unsigned(H_ACTIVE_END)) then
                h_active <= '1';
            else
                h_active <= '0';
            end if;
            
            -- Vertical active region
            if (unsigned(v_counter) >= unsigned(V_ACTIVE_START)) and 
               (unsigned(v_counter) < unsigned(V_ACTIVE_END)) then
                v_active <= '1';
            else
                v_active <= '0';
            end if;
        end if;
    end process;
    
    -- Data Enable generation process
    de_process : process(clk, rst)
    begin
        if rst = '1' then
            de <= '0';
        elsif rising_edge(clk) then
            -- Data Enable (kesiþim)
            de <= h_active and v_active;
        end if;
    end process;
    
    -- Color bar state machine process
    color_bar_process : process(clk, rst)
        variable h_pos : integer;
    begin
        if rst = '1' then
            current_bar_state <= BAR_WHITE;
            data <= (others => '0');
        elsif rising_edge(clk) then
            h_pos := to_integer(unsigned(h_counter));
            
            -- State transitions based on horizontal position
            if (h_pos >= 148) and (h_pos < 388) then
                current_bar_state <= BAR_WHITE;
            elsif (h_pos >= 388) and (h_pos < 628) then
                current_bar_state <= BAR_YELLOW;
            elsif (h_pos >= 628) and (h_pos < 868) then
                current_bar_state <= BAR_CYAN;
            elsif (h_pos >= 868) and (h_pos < 1108) then
                current_bar_state <= BAR_GREEN;
            elsif (h_pos >= 1108) and (h_pos < 1348) then
                current_bar_state <= BAR_MAGENTA;
            elsif (h_pos >= 1348) and (h_pos < 1588) then
                current_bar_state <= BAR_RED;
            elsif (h_pos >= 1588) and (h_pos < 1828) then
                current_bar_state <= BAR_BLUE;
            elsif (h_pos >= 1828) and (h_pos < 2068) then
                current_bar_state <= BAR_BLACK;
            else
                -- Outside active color bar region
                data <= (others => '0');
            end if;
            
            -- Output generation based on current state
            case current_bar_state is
                when BAR_WHITE =>
                    data <= "111111111111111111111111";  -- RGB: FFFFFF
                when BAR_YELLOW =>
                    data <= "111111111111111100000000";  -- RGB: FFFF00
                when BAR_CYAN =>
                    data <= "000000001111111111111111";  -- RGB: 00FFFF
                when BAR_GREEN =>
                    data <= "000000001111111100000000";  -- RGB: 00FF00
                when BAR_MAGENTA =>
                    data <= "111111110000000011111111";  -- RGB: FF00FF
                when BAR_RED =>
                    data <= "111111110000000000000000";  -- RGB: FF0000
                when BAR_BLUE =>
                    data <= "000000000000000011111111";  -- RGB: 0000FF
                when BAR_BLACK =>
                    data <= "000000000000000000000000";  -- RGB: 000000
            end case;
        end if;
    end process;

end Behavioral;