#include <stdio.h>
#include "platform.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"  

int main()
{
    init_platform();
    UINTPTR gpio_base = XPAR_AXI_GPIO_0_BASEADDR;
    UINTPTR gpio_green_base = XPAR_AXI_GPIO_1_BASEADDR;

#define UART_IP_BASE       0x44A00000   // Ultra_UART_0 IP base address
#define UART_REG0          (UART_IP_BASE + 0x0)   // DATA REG
#define UART_REG1          (UART_IP_BASE + 0x4)   // ND REG

#define GPIO_DATA_OFFSET   0x0
#define GPIO_TRI_OFFSET    0x4
#define GPIO2_DATA_OFFSET  0x8
#define GPIO2_TRI_OFFSET   0xC

    while(1)
    {
        // LED on (0xFF)
        Xil_Out32(gpio_base + GPIO_DATA_OFFSET, 0xFF);
        Xil_Out32(gpio_green_base + GPIO_DATA_OFFSET, 0xFF);
        xil_printf("Reset 1 \n\r");
        sleep(1);

        // 1) slv_reg0 'A' (ASCII 65) 
        Xil_Out32(UART_REG0, 'A');

        // 2) slv_reg1(0) ND bit 1 
        Xil_Out32(UART_REG1, 1);

        // 3) return 0 
        Xil_Out32(UART_REG1, 0);



        sleep(1);


        // LED off (0x00)
        Xil_Out32(gpio_base + GPIO_DATA_OFFSET, 0x00);
        Xil_Out32(gpio_green_base + GPIO_DATA_OFFSET, 0x00);
        xil_printf("Reset 0 \n\r");
        sleep(1);
    }

    cleanup_platform();
    return 0;
}
