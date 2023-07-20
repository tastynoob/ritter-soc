#include "bmp280.h"
#include "i2c.h"


u8 _temperature_res, _pressure_oversampling, _mode;
short t2, t3, p2, p3, p4, p5, p6, p7, p8, p9;
u16 t1, p1;
int t_fine;


u8 BMP280_Read8(u8 addr) {
    u8 tmp[1];
    I2C_READ_BYTES(BMP280_I2CADDR, addr, tmp, 1);
    return tmp[0];
}

u16 BMP280_Read16(u8 addr) {

    u8 tmp[2];
    I2C_READ_BYTES(BMP280_I2CADDR, addr, tmp, 2);
    return ((tmp[0] << 8) | tmp[1]);
}

u16 BMP280_Read16LE(u8 addr) {
    u16 tmp;

    tmp = BMP280_Read16(addr);
    return (tmp >> 8) | (tmp << 8);
}


void BMP280_Write8(u8 address, u8 data) {
    I2C_SEND_BYTES(BMP280_I2CADDR, address, &data, 1);
}

u32 BMP280_Read24(u8 addr) {
    u8 tmp[3];
    I2C_READ_BYTES(BMP280_I2CADDR, addr, tmp, 3);
    return ((tmp[0] << 16) | tmp[1] << 8 | tmp[2]);
}


void BMP280_SetConfig(u8 standby_time, u8 filter) {
    BMP280_Write8(BMP280_CONFIG, (((standby_time & 0x7) << 5) | ((filter & 0x7) << 2)) & 0xFC);
}

void BMP280_Init(u8 temperature_resolution, u8 pressure_oversampling, u8 mode) {


    if (mode > BMP280_NORMALMODE)
        mode = BMP280_NORMALMODE;

    _mode = mode;

    if (mode == BMP280_FORCEDMODE)
        mode = BMP280_SLEEPMODE;



    if (temperature_resolution > BMP280_TEMPERATURE_20BIT)
        temperature_resolution = BMP280_TEMPERATURE_20BIT;
    _temperature_res = temperature_resolution;

    if (pressure_oversampling > BMP280_ULTRAHIGHRES)
        pressure_oversampling = BMP280_ULTRAHIGHRES;
    _pressure_oversampling = pressure_oversampling;

    SingleWrite(BMP280_I2CADDR, 0xe0, 0xb6);
    delayms(100);

    while (BMP280_Read8(BMP280_CHIPID) != 0x58) {}

    /* read calibration data */
    t1 = BMP280_Read16LE(BMP280_DIG_T1);
    t2 = BMP280_Read16LE(BMP280_DIG_T2);
    t3 = BMP280_Read16LE(BMP280_DIG_T3);

    p1 = BMP280_Read16LE(BMP280_DIG_P1);
    p2 = BMP280_Read16LE(BMP280_DIG_P2);
    p3 = BMP280_Read16LE(BMP280_DIG_P3);
    p4 = BMP280_Read16LE(BMP280_DIG_P4);
    p5 = BMP280_Read16LE(BMP280_DIG_P5);
    p6 = BMP280_Read16LE(BMP280_DIG_P6);
    p7 = BMP280_Read16LE(BMP280_DIG_P7);
    p8 = BMP280_Read16LE(BMP280_DIG_P8);
    p9 = BMP280_Read16LE(BMP280_DIG_P9);

    BMP280_Write8(BMP280_CONTROL, ((temperature_resolution << 5) | (pressure_oversampling << 2) | mode));
    BMP280_SetConfig(0x2, 0x0);

    printf("BMP_CTL: %x\n", BMP280_Read8(BMP280_CONTROL));
    printf("BMP_CFG: %x\n", BMP280_Read8(BMP280_CONFIG));
}



float BMP280_ReadTemperature(void) {
    int var1, var2;
    u8 mode;
    mode = BMP280_Read8(BMP280_CONTROL) & 0x03;

    // if (_mode == BMP280_FORCEDMODE) {
        
    //     u8 ctrl = BMP280_Read8(BMP280_CONTROL);
    //     ctrl &= ~(0x03);
    //     ctrl |= BMP280_FORCEDMODE;
    //     BMP280_Write8(BMP280_CONTROL, ctrl);

    //     mode = BMP280_Read8(BMP280_CONTROL); 	// Read written mode
    //     mode &= 0x03;							// Do not work without it...

    //     if (mode == BMP280_FORCEDMODE) {
    //         while (1) // Wait for end of conversion
    //         {
    //             mode = BMP280_Read8(BMP280_CONTROL);
    //             mode &= 0x03;
    //             if (mode == BMP280_SLEEPMODE)
    //                 break;
    //         }

    //         int adc_T = BMP280_Read24(BMP280_TEMPDATA);
            
    //         //adc_T >>= 4;

    //         printf("T:%d\n", adc_T);

    //         var1 = ((((adc_T >> 3) - ((int)t1 << 1))) *
    //                 ((int)t2)) >> 11;

    //         var2 = (((((adc_T >> 4) - ((int)t1)) *
    //                   ((adc_T >> 4) - ((int)t1))) >> 12) *
    //                 ((int)t3)) >> 14;

    //         t_fine = var1 + var2;

    //         float T = (t_fine * 5 + 128) >> 8;
    //         return T / 100;
    //     }
    // }
    // else
    if (mode == BMP280_NORMALMODE) {
        int adc_T = BMP280_Read24(BMP280_TEMPDATA);
        adc_T >>= 8;

        var1 = ((((adc_T >> 3) - ((int)t1 << 1))) *
                ((int)t2)) >> 11;

        var2 = (((((adc_T >> 4) - ((int)t1)) *
                  ((adc_T >> 4) - ((int)t1))) >> 12) *
                ((int)t3)) >> 14;

        t_fine = var1 + var2;

        float T = (t_fine * 5 + 128) >> 8;
        return T / 100;
    }
    

    return -99;
}



u8 BMP280_ReadTemperatureAndPressure(float* temperature, float * pressure) {
    s64 var1, var2, p;

    // Must be done first to get the t_fine variable set up
    *temperature = BMP280_ReadTemperature();

    if (*temperature == -99)
        return -1;

    int adc_P = BMP280_Read24(BMP280_PRESSUREDATA);
    adc_P >>= 8;

    var1 = ((s64)t_fine) - 128000;
    var2 = var1 * var1 * (s64)p6;
    var2 = var2 + ((var1 * (s64)p5) << 17);
    var2 = var2 + (((s64)p4) << 35);
    var1 = ((var1 * var1 * (s64)p3) >> 8) +
        ((var1 * (s64)p2) << 12);
    var1 = (((((s64)1) << 47) + var1)) * ((s64)p1) >> 33;

    if (var1 == 0) {
        return 0;  // avoid exception caused by division by zero
    }
    p = 1048576 - adc_P;
    p = (((p << 31) - var2) * 3125) / var1;
    var1 = (((s64)p9) * (p >> 13) * (p >> 13)) >> 25;
    var2 = (((s64)p8) * p) >> 19;

    p = ((p + var1 + var2) >> 8) + (((s64)p7) << 4);
    *pressure = p / 256.0 / 1000;

    return 0;
}



