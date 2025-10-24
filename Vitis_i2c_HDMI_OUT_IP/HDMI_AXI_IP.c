#include "xparameters.h"
#include "xiic.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

#define GPIO_DATA_OFFSET    0x0
#define GPIO_TRI_OFFSET     0x4
#define GPIO2_DATA_OFFSET   0x8
#define GPIO2_TRI_OFFSET    0xC

#define TPI_DEVICE_POWER_STATE_CTRL_REG       (0x1E)
#define TPI_DEVICE_ID                         (0x1B)
#define TMDS_CONT_REG                         (0x82)
#define TPI_INTERRUPT_ENABLE_REG              (0x3C)
#define TPI_INTERRUPT_STATUS_REG              (0x3D)
#define TPI_ENABLE                            (0xC7)
#define SII9022_SYS_CTRL_DATA_REG              0x1a

#define HOT_PLUG_EVENT                        (0x01)

#define TX_POWER_STATE_MASK                   (0x03)
#define TX_POWER_STATE_D0                     (0x00)
#define TX_POWER_STATE_D1                     (0x01)
#define TX_POWER_STATE_D2                     (0x02)
#define TX_POWER_STATE_D3                     (0x03)

#define SiI9022_DEVICE_ID                     (0xB0)

#define SII9022_VIDEO_DATA_BASE_REG            0x00
#define SII9022_PIXEL_CLK_LSB_REG              (SII9022_VIDEO_DATA_BASE_REG + 0x00)
#define SII9022_PIXEL_CLK_MSB_REG              (SII9022_VIDEO_DATA_BASE_REG + 0x01)
#define SII9022_VFREQ_LSB_REG                  (SII9022_VIDEO_DATA_BASE_REG + 0x02)
#define SII9022_VFREQ_MSB_REG                  (SII9022_VIDEO_DATA_BASE_REG + 0x03)
#define SII9022_PIXELS_LSB_REG                 (SII9022_VIDEO_DATA_BASE_REG + 0x04)
#define SII9022_PIXELS_MSB_REG                 (SII9022_VIDEO_DATA_BASE_REG + 0x05)
#define SII9022_LINES_LSB_REG                  (SII9022_VIDEO_DATA_BASE_REG + 0x06)
#define SII9022_LINES_MSB_REG                  (SII9022_VIDEO_DATA_BASE_REG + 0x07)

#define SII9022_PIXEL_REPETITION_REG         0x08
#define SII9022_AVI_IN_FORMAT_REG            0x09
#define SII9022_AVI_OUT_FORMAT_REG           0x0a

// Eksik fonksiyon tanımı
int sil9022_ll_write(uint8_t reg, uint8_t val)
{
    uint8_t data[2] = {reg, val};
    int result;

    result = XIic_Send(XPAR_AXI_IIC_0_BASEADDR, 0x76>>1, data, 2, XIIC_STOP);

    if (result != 0) {
        xil_printf("I2C write error: reg=0x%02X, val=0x%02X, result=%d\n", reg, val, result);
    }

    return result;
}

int sil9022_init()
{
    unsigned short pixel_clock = 14850;
    unsigned short v_freq = 6000;
    unsigned short pixels = 2200;
    unsigned short lines = 1125;

    sil9022_ll_write(TPI_ENABLE, 0);

    sil9022_ll_write(TPI_DEVICE_POWER_STATE_CTRL_REG, 0); // Power ON
    usleep(100);

    sil9022_ll_write(SII9022_PIXEL_REPETITION_REG, 112); // Rising edge
    usleep(100);

    sil9022_ll_write(SII9022_AVI_IN_FORMAT_REG, 0);
    usleep(100);

    sil9022_ll_write(SII9022_AVI_OUT_FORMAT_REG, 0);
    usleep(100);

    sil9022_ll_write(96, 4); // Sync Register Configuration and Sync Monitoring Registers
    usleep(100);

    sil9022_ll_write(60, 1);
    usleep(100);

    sil9022_ll_write(SII9022_SYS_CTRL_DATA_REG, 17);
    usleep(100);

    sil9022_ll_write(SII9022_PIXEL_CLK_LSB_REG, (pixel_clock & 0xFF));
    usleep(100);

    sil9022_ll_write(SII9022_PIXEL_CLK_MSB_REG, ((pixel_clock >> 8) & 0xFF));
    usleep(100);

    sil9022_ll_write(SII9022_VFREQ_LSB_REG, (v_freq & 0xFF));
    usleep(100);

    sil9022_ll_write(SII9022_VFREQ_MSB_REG, ((v_freq >> 8) & 0xFF));
    usleep(100);

    sil9022_ll_write(SII9022_PIXELS_LSB_REG, (pixels & 0xFF));
    usleep(100);

    sil9022_ll_write(SII9022_PIXELS_MSB_REG, ((pixels >> 8) & 0xFF));
    usleep(100);

    sil9022_ll_write(SII9022_LINES_LSB_REG, (lines & 0xFF));
    usleep(100);

    sil9022_ll_write(SII9022_LINES_MSB_REG, ((lines >> 8) & 0xFF));
    usleep(100);

    sil9022_ll_write(SII9022_PIXEL_REPETITION_REG, 112);
    usleep(100);

    sil9022_ll_write(SII9022_SYS_CTRL_DATA_REG, 1);

    return 0;
}

int main()
{

	sleep(10);

    UINTPTR gpio_base = XPAR_AXI_GPIO_0_BASEADDR;
    UINTPTR gpio_green_base = XPAR_AXI_GPIO_1_BASEADDR;

    Xil_Out32(gpio_base + GPIO_TRI_OFFSET, 0x0);
    Xil_Out32(gpio_base + GPIO2_TRI_OFFSET, 0x0);
    Xil_Out32(gpio_green_base + GPIO_TRI_OFFSET, 0x0);
    Xil_Out32(gpio_green_base + GPIO2_TRI_OFFSET, 0x0);

    Xil_Out32(gpio_base + GPIO_DATA_OFFSET, 0xFF);
    Xil_Out32(gpio_green_base + GPIO_DATA_OFFSET, 0xFF);
    xil_printf("Reset 1 \n\r");
    usleep(100000); // 100ms bekle

    Xil_Out32(gpio_base + GPIO_DATA_OFFSET, 0x00);
    Xil_Out32(gpio_green_base + GPIO_DATA_OFFSET, 0x00);
    xil_printf("Reset 0 \n\r");
    usleep(100000);

    Xil_Out32(gpio_base + GPIO_DATA_OFFSET, 0xFF);
    Xil_Out32(gpio_green_base + GPIO_DATA_OFFSET, 0xFF);
    xil_printf("Reset 1 \n\r");
    usleep(100000);

    sil9022_init();

    usleep(10000);

    return 0;
}
