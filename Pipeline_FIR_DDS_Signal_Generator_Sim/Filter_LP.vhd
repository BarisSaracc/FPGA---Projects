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
    signal sum1, sum2, sum3, sum4, sum5, sum6, sum7, sum8 : std_logic_vector(32 downto 0); -- 33 bit
    signal  sum9, sum10, sum11, sum12  : std_logic_vector(33 downto 0); -- 34 bit
    signal sum13, sum14  : std_logic_vector(34 downto 0); -- 35 bit
    signal sum15 : std_logic_vector(35 downto 0); -- 36 bit
 

    -- Kaydırma hattı sinyalleri
    type delay_array is array (0 to 14) of std_logic_vector(15 downto 0);
    signal delay_line : delay_array;

    -- Katsayı dizisi
    type coef_array is array (0 to 14) of std_logic_vector(15 downto 0);
    constant h : coef_array := (
        x"0000",
        x"FB2E",
        x"0000",
        x"1A85",
        x"0000",
        x"BE43",
        x"0000",
        x"5A82",
        x"0000",
        x"BE43",
        x"0000",
        x"1A85",
        x"0000",
        x"FB2E",
        x"0000"
    );

    -- Multiplier çıkışları
    type mult_output_array is array (0 to 14) of std_logic_vector(31 downto 0);
    signal p : mult_output_array;

begin

    -- Kaydırma hattı işlemi
    process(clk)
    begin
        if rising_edge(clk) then
            delay_line(0) <= x_in;
            for i in 1 to 14 loop
                delay_line(i) <= delay_line(i-1);
            end loop;
        end if;
    end process;

    -- Multiplier 
    gen_multipliers: for i in 0 to 14 generate
        m: mult_gen_0 
            port map (
                CLK => clk,
                A   => delay_line(i),
                B   => h(i),
                P   => p(i)
            );
    end generate gen_multipliers;

    -- Toplama işlemi
    process(clk)
    begin
        if rising_edge(clk) then
            -- Seviye 1: 15 → 8 (32-bit + 32-bit = 33 bit)
            sum1 <= std_logic_vector(resize(signed(p(0)), 33) + resize(signed(p(1)), 33));
            sum2 <= std_logic_vector(resize(signed(p(2)), 33) + resize(signed(p(3)), 33));
            sum3 <= std_logic_vector(resize(signed(p(4)), 33) + resize(signed(p(5)), 33));
            sum4 <= std_logic_vector(resize(signed(p(6)), 33) + resize(signed(p(7)), 33));
            sum5 <= std_logic_vector(resize(signed(p(8)), 33) + resize(signed(p(9)), 33));
            sum6 <= std_logic_vector(resize(signed(p(10)), 33) + resize(signed(p(11)), 33));
            sum7 <= std_logic_vector(resize(signed(p(12)), 33) + resize(signed(p(13)), 33));
            sum8 <= std_logic_vector(resize(signed(p(14)), 33));

            -- Seviye 2: 8 → 4 (33-bit + 33-bit = 34 bit)
            sum9 <= std_logic_vector(resize(signed(sum1), 34) + resize(signed(sum2), 34));
            sum10 <= std_logic_vector(resize(signed(sum3), 34) + resize(signed(sum4), 34));
            sum11 <= std_logic_vector(resize(signed(sum5), 34) + resize(signed(sum6), 34));
            sum12 <= std_logic_vector(resize(signed(sum7), 34) + resize(signed(sum8), 34));

            -- Seviye 3: 4 → 2 (34-bit + 34-bit = 35 bit)
            sum13 <= std_logic_vector(resize(signed(sum9), 35) + resize(signed(sum10), 35));
            sum14 <= std_logic_vector(resize(signed(sum11), 35) + resize(signed(sum12), 35));

            -- Seviye 4: 2 → 1 (35-bit + 35-bit = 36 bit)
            sum15 <= std_logic_vector(resize(signed(sum13), 36) + resize(signed(sum14), 36));

            -- Çıkış 16 bit
            y_out <= sum15(30 downto 15); -- MSB'lerden alarak ölçeklendirme
        end if;
    end process;

end architecture;