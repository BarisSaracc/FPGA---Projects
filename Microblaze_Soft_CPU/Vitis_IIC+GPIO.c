#include "xparameters.h"
#include "xiic.h"
#include "xil_printf.h"
#include "xil_io.h"

#define GPIO_DATA_OFFSET    0x0
#define GPIO_TRI_OFFSET     0x4
#define GPIO2_DATA_OFFSET   0x8
#define GPIO2_TRI_OFFSET    0xC

int main()
{



 init_platform();
    /*
    UINTPTR gpio_base = XPAR_AXI_GPIO_0_BASEADDR;
    UINTPTR gpio_green_base = XPAR_AXI_GPIO_1_BASEADDR;
    UINTPTR gpio_version_base = XPAR_VERSION_REG_0_BASEADDR;

    // GPIO
    Xil_Out32(gpio_base + GPIO_TRI_OFFSET, 0x0);
    Xil_Out32(gpio_base + GPIO2_TRI_OFFSET, 0x0);
    Xil_Out32(gpio_green_base + GPIO_TRI_OFFSET, 0x0);
    Xil_Out32(gpio_green_base + GPIO2_TRI_OFFSET, 0x0);
    
    uint32_t version_value = Xil_In32(gpio_version_base);
    
    print("System started\n\r");
   xil_printf("Version Register Value: 0x%08X\n\r", version_value);

 Xil_Out32(gpio_base + GPIO_DATA_OFFSET, 0xFF);
        Xil_Out32(gpio_green_base + GPIO_DATA_OFFSET, 0xFF);
        xil_printf("Reset 1 \n\r");
        msleep(100);

        Xil_Out32(gpio_base + GPIO_DATA_OFFSET, 0x00);
        Xil_Out32(gpio_green_base + GPIO_DATA_OFFSET, 0x00);
        xil_printf("Reset 0 \n\r");
        msleep(100);

 Xil_Out32(gpio_base + GPIO_DATA_OFFSET, 0xFF);
        Xil_Out32(gpio_green_base + GPIO_DATA_OFFSET, 0xFF);
        xil_printf("Reset 1 \n\r");
        msleep(100);
*/
u8 reg = 0x1B;   // Device ID Register adress
u8 val=0;
u8 result;
result = XIic_Send(XPAR_AXI_IIC_1_BASEADDR, 0x3B, &reg, 1, XIIC_REPEATED_START);
if (result!= 1) xil_printf("result1: 0x%02X\r\n", result);
result=XIic_Recv(XPAR_AXI_IIC_1_BASEADDR, 0x3B, &val, 1, XIIC_STOP);
if (result!= 1) xil_printf("result2: 0x%02X\r\n", result);
xil_printf("Device ID: 0x%02X\r\n", val);

u8 reg2 = 0xF5;   // Device ID Register adress
u8 val2=0;
result=XIic_Send(XPAR_AXI_IIC_0_BASEADDR, 0x4C, &reg2, 1, XIIC_REPEATED_START);
xil_printf("result3: 0x%02X\r\n", result);
result=XIic_Recv(XPAR_AXI_IIC_0_BASEADDR, 0x4C, &val2, 1, XIIC_STOP);
xil_printf("result4: 0x%02X\r\n", result);
xil_printf("Device ID: 0x%02X\r\n", val2);

    u8 data[2] = {0x08,112};
    int senddata;
    int i;
    xil_printf("I2C Send Test\r\n");
    while(1)
    {
    
  senddata = XIic_Send(XPAR_AXI_IIC_1_BASEADDR, 0x39, data, 2, XIIC_STOP);
//sil9022_ll_write(0x76, 0x08, 112);

    xil_printf("senddata %X\r\n",senddata);
    }
    return 0;
}
