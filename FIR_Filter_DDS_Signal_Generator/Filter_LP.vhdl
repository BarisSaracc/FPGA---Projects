library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Filter_LP is
    port (
        clk   : in  std_logic;
        x_in  : in  std_logic_vector(15 downto 0);
        y_out : out std_logic_vector(15 downto 0)
    );
end entity;

architecture Behavioral of Filter_LP is

    component mult_gen_0
      port (
        CLK : in  std_logic;
        A   : in  std_logic_vector(15 downto 0);
        B   : in  std_logic_vector(15 downto 0);
        P   : out std_logic_vector(31 downto 0)
      );
    end component;

   -- Ara toplam sinyalleri
    signal sum1, sum2, sum3, sum4 : std_logic_vector(32 downto 0); -- 33 bit
    signal sum5, sum6             : std_logic_vector(33 downto 0); -- 34 bit
    signal sum_final              : std_logic_vector(34 downto 0); -- 35 bit

    -- Kaydırma hattı sinyalleri
    signal delay_line_0 : std_logic_vector(15 downto 0);
    signal delay_line_1 : std_logic_vector(15 downto 0);
    signal delay_line_2 : std_logic_vector(15 downto 0);
    signal delay_line_3 : std_logic_vector(15 downto 0);
    signal delay_line_4 : std_logic_vector(15 downto 0);
    signal delay_line_5 : std_logic_vector(15 downto 0);
    signal delay_line_6 : std_logic_vector(15 downto 0);
    signal delay_line_7 : std_logic_vector(15 downto 0);
    
    -- Katsayılar
    constant h0 : std_logic_vector(15 downto 0) := x"0B61"; -- 2913
constant h1 : std_logic_vector(15 downto 0) := x"0CCD"; -- 3277
constant h2 : std_logic_vector(15 downto 0) := x"1111"; -- 4369
constant h3 : std_logic_vector(15 downto 0) := x"16C1"; -- 5825
constant h4 : std_logic_vector(15 downto 0) := x"16C1"; -- 5825
constant h5 : std_logic_vector(15 downto 0) := x"1111"; -- 4369
constant h6 : std_logic_vector(15 downto 0) := x"0CCD"; -- 3277
constant h7 : std_logic_vector(15 downto 0) := x"0B61"; -- 2913

    -- Multiplier çıkışları
    signal p0 : std_logic_vector(31 downto 0);
    signal p1 : std_logic_vector(31 downto 0);
    signal p2 : std_logic_vector(31 downto 0);
    signal p3 : std_logic_vector(31 downto 0);
    signal p4 : std_logic_vector(31 downto 0);
    signal p5 : std_logic_vector(31 downto 0);
    signal p6 : std_logic_vector(31 downto 0);
    signal p7 : std_logic_vector(31 downto 0);
    
    -- Toplam registerı
    signal sum_reg : std_logic_vector(34 downto 0);

begin

    -- Kaydırma hattı işlemi
    process(clk)
    begin
        if rising_edge(clk) then
            delay_line_0 <= x_in;
            delay_line_1 <= delay_line_0;
            delay_line_2 <= delay_line_1;
            delay_line_3 <= delay_line_2;
            delay_line_4 <= delay_line_3;
            delay_line_5 <= delay_line_4;
            delay_line_6 <= delay_line_5;
            delay_line_7 <= delay_line_6;
        end if;
    end process;

    -- Multiplier örnekleri
    m0: mult_gen_0 port map ( CLK => clk, A => delay_line_0, B => h0, P => p0 );
    m1: mult_gen_0 port map ( CLK => clk, A => delay_line_1, B => h1, P => p1 );
    m2: mult_gen_0 port map ( CLK => clk, A => delay_line_2, B => h2, P => p2 );
    m3: mult_gen_0 port map ( CLK => clk, A => delay_line_3, B => h3, P => p3 );
    m4: mult_gen_0 port map ( CLK => clk, A => delay_line_4, B => h4, P => p4 );
    m5: mult_gen_0 port map ( CLK => clk, A => delay_line_5, B => h5, P => p5 );
    m6: mult_gen_0 port map ( CLK => clk, A => delay_line_6, B => h6, P => p6 );
    m7: mult_gen_0 port map ( CLK => clk, A => delay_line_7, B => h7, P => p7 );

    -- Toplama işlemi
    process(clk)
    begin
        if rising_edge(clk) then
            -- Seviye 1: 8 → 4 (32-bit + 32-bit = 33
            sum1 <= std_logic_vector(unsigned(p0) + unsigned(p1));
            sum2 <= std_logic_vector(unsigned(p2) + unsigned(p3));
            sum3 <= std_logic_vector(unsigned(p4) + unsigned(p5));
            sum4 <= std_logic_vector(unsigned(p6) + unsigned(p7));

            -- Seviye 2: 4 → 2 (33-bit + 33-bit = 34
            sum5 <= std_logic_vector(resize(unsigned(sum1), 33) + resize(unsigned(sum2), 33));
            sum6 <= std_logic_vector(resize(unsigned(sum3), 33) + resize(unsigned(sum4), 33));

            -- Seviye 3: 2 → 1 (34-bit + 34-bit = 35
            sum_final <= std_logic_vector(unsigned(sum5) + unsigned(sum6));

            -- Toplamı kaydet
            sum_reg <= sum_final;
            
            -- Çıkış 16 bit (35 bit'ten 20 bit'e ölçeklendirme)
            y_out <= sum_reg(34 downto 19); -- MSB'lerden alarak ölçeklendirme
        end if;
    end process;

end architecture;
