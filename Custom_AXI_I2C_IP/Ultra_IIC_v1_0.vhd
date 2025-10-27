library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ultra_IIC_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 5
	);
	port (
		-- Users to add ports here
        scl_i : in std_logic;
        scl_o : out std_logic;
        scl_t : out std_logic;
        sda_i : in std_logic;
        sda_o : out std_logic;
        sda_t : out std_logic;
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end Ultra_IIC_v1_0;

architecture arch_imp of Ultra_IIC_v1_0 is


	-- component declaration
	component Ultra_IIC_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic;
		
			-- User ports ekleniyor
		slv_reg0_out : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		slv_reg1_out : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		slv_reg2_out : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		slv_reg3_out : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		slv_reg4_out : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		slv_reg5_out : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		slv_reg6_out : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		slv_reg7_out : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		
		readval : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0)

		);
	end component Ultra_IIC_v1_0_S00_AXI;
	
	
signal reg0 : std_logic_vector(31 downto 0);
signal reg1 : std_logic_vector(31 downto 0);
signal reg2 : std_logic_vector(31 downto 0);
signal reg3 : std_logic_vector(31 downto 0);
signal reg4 : std_logic_vector(31 downto 0);
signal reg5 : std_logic_vector(31 downto 0);
signal reg6 : std_logic_vector(31 downto 0);
signal reg7 : std_logic_vector(31 downto 0);

signal rst_int : std_logic;

signal readval:  std_logic_vector(31 downto 0);

signal scl_out_line : std_logic;
signal scl_t_line : std_logic;

signal sda_out_line : std_logic;
signal sda_t_line : std_logic;

signal start_prev : std_logic := '0';
signal start : std_logic;

component I2C_Master is
		port (
		CLK : in std_logic;
        RST : in std_logic;
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
        ack_error : out std_logic;
        ack_counter : out std_logic_vector(7 downto 0)
		);
		
	end component I2C_Master;


begin

rst_int <= not s00_axi_aresetn;


-- Instantiation of Axi Bus Interface S00_AXI
Ultra_IIC_v1_0_S00_AXI_inst : Ultra_IIC_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready,
		
		slv_reg0_out => reg0,
		slv_reg1_out => reg1,
		slv_reg2_out => reg2,
		slv_reg3_out => reg3,
		slv_reg4_out => reg4,
		slv_reg5_out => reg5,
		slv_reg6_out => reg6,
		slv_reg7_out => reg7,
		readval =>   readval   
	);

	-- Add user logic here
I2C_Master_inst : I2C_Master
    port map (
        CLK          => s00_axi_aclk,
        RST          => rst_int,
        slave_addr   => reg0(6 downto 0),
        addr_in      => reg1(7 downto 0),
        data_in      => reg2(7 downto 0),
        rw_bit       => reg3(0),
        repeat       => reg4(0),
        start        => start,
        ack_counter => readval(7 downto 0),
        
        scl_in       => scl_i,
        scl_out      => scl_out_line,
        scl_t        => scl_t_line,
        sda_in       => sda_i,
        sda_out       => sda_out_line,
        sda_t       => sda_t_line
        
        
    );
    
    process(s00_axi_aclk)
begin
    if rising_edge(s00_axi_aclk) then
        start_prev <= reg5(0);
        start <= reg5(0) and not start_prev;

    end if;
end process;
    
     scl_o <=   scl_out_line; 
     scl_t <=   scl_t_line; 
     sda_o <=   sda_out_line; 
     sda_t <=   sda_t_line; 
    
    	-- User logic ends
end arch_imp;
