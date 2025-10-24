library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- UART Receiver Entity Tanımı
-- Bu modül, UART protokolüne göre seri veri alımı yapar.
entity UART_Receiver is
    port(
        CLK     : in  std_logic;                 -- Sistem clock (50 MHz)
        RST     : in  std_logic;                 -- Senkron reset (aktif yüksek)
        RX      : in  std_logic;                 -- Seri veri giriş hattı
        RX_DATA : out std_logic_vector(7 downto 0); -- Alınan 8-bit paralel veri
        RX_RDY  : out std_logic;                 -- Veri hazır sinyali (aktif yüksek)
        SAMPLE  : out std_logic                  -- Debug amaçlı: örnekleme anı sinyali
    );
end entity;

architecture rtl of UART_Receiver is
    -- Durum Makinesi Tanımları
    type state_t is (
        IDLE,       -- Bekleme durumu: RX hattı boşta (1)
        STARTB,     -- Start biti kontrolü ve doğrulama
        BIT0,       -- 0. veri biti (LSB) alımı
        BIT1,       -- 1. veri biti alımı
        BIT2,       -- 2. veri biti alımı
        BIT3,       -- 3. veri biti alımı
        BIT4,       -- 4. veri biti alımı
        BIT5,       -- 5. veri biti alımı
        BIT6,       -- 6. veri biti alımı
        BIT7,       -- 7. veri biti (MSB) alımı
        STOPB,      -- Stop biti kontrolü
        READY_HOLD  -- RX_RDY sinyalini tutma durumu
    );
    
    -- İç Sinyal Tanımları
    signal state         : state_t := IDLE;              -- Mevcut durum makinesi durumu
    signal rx_data_reg   : std_logic_vector(7 downto 0) := (others => '0'); -- Alınan veri kaydı
    signal counter       : integer := 0;                 -- Bit süresi sayacı
    signal ready_counter : integer := 0;                 -- RX_RDY tutma süresi sayacı

    -- Sabit Değerler (50 MHz clock ve 115200 baud rate için)
    constant BIT_DURATION       : integer := 434;       -- 1 bit süresi (50MHz/115200bps)
    constant HALF_BIT_DURATION  : integer := 317;       -- Yarım bit süresi (ortadan örnekleme için)
    constant READY_HOLD_TIME    : integer := 1;       -- RX_RDY sinyalinin aktif kalma süresi

    -- Senkronizasyon ve İç Sinyaller
    signal rx_sync1, rx_sync2   : std_logic := '1';     -- RX hattını senkronize eden flip-floplar
    signal rx_rdy_internal      : std_logic := '0';     -- Dahili hazır sinyali
    signal sample_point         : std_logic := '0';     -- Örnekleme anı işareti

begin
    -- Çıkış Sinyal Bağlantıları
    RX_DATA <= rx_data_reg;         -- Alınan veriyi çıkışa bağla
    RX_RDY  <= rx_rdy_internal;     -- Hazır sinyalini çıkışa bağla
    SAMPLE  <= sample_point;        -- Örnekleme anını debug için çıkışa ver

    -- Ana İşlem: Durum Makinesi ve Veri Alımı
    process(CLK)
    begin
        if rising_edge(CLK) then
            -- RX hattını iki kademeli flip-flop ile senkronize et
            -- Bu, metastability sorunlarını önlemek için standart bir yöntemdir
            rx_sync1 <= RX;
            rx_sync2 <= rx_sync1;

            -- Reset durumu: Tüm sinyalleri ve durumları sıfırla
            if RST = '1' then
                state <= IDLE;
                rx_data_reg <= (others => '0');
                counter <= 0;
                ready_counter <= 0;
                rx_rdy_internal <= '0';
                sample_point <= '0';
            else
                -- Varsayılan değerler: Örnekleme sinyalini varsayılan olarak pasif yap
                sample_point <= '0';

                -- Durum Makinesi
                case state is
                    -- IDLE DURUMU: RX hattının boşta olduğu durum (1 seviyesi)
                    when IDLE =>
                        rx_rdy_internal <= '0';    -- Hazır sinyalini pasif yap
                        counter <= 0;              -- Sayaçları sıfırla
                        ready_counter <= 0;
                        
                        -- Start biti algılama (RX hattı 0'a düştü)
                        if rx_sync2 = '0' then
                            state <= STARTB;       -- Start biti durumuna geç
                            counter <= 0;          -- Sayacı sıfırla
                        end if;

                    -- STARTB DURUMU: Start bitinin doğrulanması
                    when STARTB =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;  -- Sayacı artır
                            
                            -- Yarım bit süresi sonunda start bitini kontrol et
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';  -- Örnekleme anı sinyali
                                
                                -- Start biti doğrulama (hala 0 olmalı)
                                if rx_sync2 = '0' then
                                    state <= BIT0;   -- Geçerli start biti, veri alımına geç
                                    counter <= 0;    -- Sayacı sıfırla
                                else
                                    state <= IDLE;   -- Sahte start biti, bekleme durumuna dön
                                    counter <= 0;    -- Sayacı sıfırla
                                end if;
                            end if;
                        else
                            -- Zaman aşımı: Beklenen sürede start biti doğrulanamadı
                            state <= IDLE;
                            counter <= 0;
                        end if;

                    -- VERİ BİTLERİNİN ALINMASI (BIT0 - BIT7)
                    -- Her bit için aynı işlem yapılır, sadece kaydedilen bit pozisyonu farklıdır
                    when BIT0 =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            
                            -- Yarım bit süresi sonunda bit değerini örnekle
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';      -- Örnekleme anı sinyali
                                rx_data_reg(0) <= rx_sync2; -- 0. biti kaydet (LSB)
                            end if;
                        else
                            -- Bit süresi tamamlandı, sonraki bite geç
                            counter <= 0;
                            state <= BIT1;
                        end if;

                    -- BIT1 - BIT6 için benzer işlemler (kısaltma için gösterilmiyor)
                    when BIT1 =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';
                                rx_data_reg(1) <= rx_sync2; -- 1. biti kaydet
                            end if;
                        else
                            counter <= 0;
                            state <= BIT2;
                        end if;

                    when BIT2 =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';
                                rx_data_reg(2) <= rx_sync2; -- 2. biti kaydet
                            end if;
                        else
                            counter <= 0;
                            state <= BIT3;
                        end if;

                    when BIT3 =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';
                                rx_data_reg(3) <= rx_sync2; -- 3. biti kaydet
                            end if;
                        else
                            counter <= 0;
                            state <= BIT4;
                        end if;

                    when BIT4 =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';
                                rx_data_reg(4) <= rx_sync2; -- 4. biti kaydet
                            end if;
                        else
                            counter <= 0;
                            state <= BIT5;
                        end if;

                    when BIT5 =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';
                                rx_data_reg(5) <= rx_sync2; -- 5. biti kaydet
                            end if;
                        else
                            counter <= 0;
                            state <= BIT6;
                        end if;

                    when BIT6 =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';
                                rx_data_reg(6) <= rx_sync2; -- 6. biti kaydet
                            end if;
                        else
                            counter <= 0;
                            state <= BIT7;
                        end if;

                    -- SON VERİ BİTİ (MSB)
                    when BIT7 =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            
                            -- Yarım bit süresi sonunda bit değerini örnekle
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';      -- Örnekleme anı sinyali
                                rx_data_reg(7) <= rx_sync2; -- 7. biti kaydet (MSB)
                            end if;
                        else
                            -- Tüm veri bitleri alındı, stop bitine geç
                            counter <= 0;
                            state <= STOPB;
                        end if;

                    -- STOPB DURUMU: Stop bitinin kontrolü
                    when STOPB =>
                        if counter < BIT_DURATION-1 then
                            counter <= counter + 1;
                            
                            -- Yarım bit süresi sonunda stop bitini kontrol et
                            if counter = HALF_BIT_DURATION-1 then
                                sample_point <= '1';  -- Örnekleme anı sinyali
                                
                                -- Stop biti doğrulama (1 olmalı)
                                if rx_sync2 = '1' then
                                    -- Geçerli stop biti, veriyi hazırla
                                    state <= READY_HOLD;
                                    rx_rdy_internal <= '1'; -- Veri hazır sinyalini aktif et
                                    counter <= 0;
                                else
                                    -- Stop biti hatası (framing error)
                                    state <= IDLE;
                                    counter <= 0;
                                end if;
                            end if;
                        else
                            -- Zaman aşımı
                            state <= IDLE;
                            counter <= 0;
                        end if;

                    -- READY_HOLD DURUMU: RX_RDY sinyalini belirli süre aktif tut
                    when READY_HOLD =>
                        if ready_counter < READY_HOLD_TIME-1 then
                            ready_counter <= ready_counter + 1;
                            rx_rdy_internal <= '1'; -- RX_RDY sinyalini aktif tut
                        else
                            -- Tutma süresi tamamlandı, bekleme durumuna dön
                            state <= IDLE;
                            rx_rdy_internal <= '0';
                            ready_counter <= 0;
                        end if;

                end case;
            end if;
        end if;
    end process;
end architecture;
