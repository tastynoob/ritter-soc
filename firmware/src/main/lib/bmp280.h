
#ifndef BMPXX80_H_
#define BMPXX80_H_


#include "config.h"




#define BMP280_I2CADDR	0xEC




// Temperature resolution
#define BMP280_TEMPERATURE_16BIT 1
#define BMP280_TEMPERATURE_17BIT 2
#define BMP280_TEMPERATURE_18BIT 3
#define BMP280_TEMPERATURE_19BIT 4
#define BMP280_TEMPERATURE_20BIT 5

// Pressure oversampling
#define BMP280_ULTRALOWPOWER	1
#define BMP280_LOWPOWER			2
#define BMP280_STANDARD			3
#define BMP280_HIGHRES			4
#define BMP280_ULTRAHIGHRES		5

// t_standby time
#define BME280_STANDBY_MS_0_5	0
#define BME280_STANDBY_MS_10	6
#define BME280_STANDBY_MS_20	7
#define BME280_STANDBY_MS_62_5	1
#define BME280_STANDBY_MS_125	2
#define BME280_STANDBY_MS_250 	3
#define BME280_STANDBY_MS_500	4
#define BME280_STANDBY_MS_1000	5

// IIR filter
#define BME280_FILTER_OFF	0
#define BME280_FILTER_X2 	1
#define BME280_FILTER_X4 	2
#define BME280_FILTER_X8	3
#define BME280_FILTER_X16 	4

// Mode
#define BMP280_SLEEPMODE		0
#define BMP280_FORCEDMODE		1
#define BMP280_NORMALMODE		3




#define	BMP280_DIG_T1		0x88
#define	BMP280_DIG_T2		0x8A
#define	BMP280_DIG_T3		0x8C

#define	BMP280_DIG_P1		0x8E
#define	BMP280_DIG_P2		0x90
#define	BMP280_DIG_P3		0x92
#define	BMP280_DIG_P4		0x94
#define	BMP280_DIG_P5		0x96
#define	BMP280_DIG_P6		0x98
#define	BMP280_DIG_P7		0x9A
#define	BMP280_DIG_P8		0x9C
#define	BMP280_DIG_P9		0x9E


//
//	Registers
//


#define	BMP280_CHIPID			0xD0
#define	BMP280_VERSION			0xD1
#define	BMP280_SOFTRESET		0xE0
#define	BMP280_CAL26			0xE1  // R calibration stored in 0xE1-0xF0
#define	BMP280_STATUS			0xF3
#define	BMP280_CONTROL			0xF4
#define	BMP280_CONFIG			0xF5
#define	BMP280_PRESSUREDATA		0xF7
#define	BMP280_TEMPDATA			0xFA





#define	BMP280_MEASURING			(1<<3) // Conversion in progress



//
// User functions
//



void BMP280_Init(u8 temperature_resolution, u8 pressure_oversampling, u8 mode);


void BMP280_SetConfig(u8 standby_time, u8 filter);

float BMP280_ReadTemperature(void);
u8 BMP280_ReadTemperatureAndPressure(float* temperature, float* pressure);



#endif /* BMPXX80_H_ */