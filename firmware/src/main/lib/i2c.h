#ifndef  _I2C_H_  
#define  _I2C_H_

#include "gpio.h"   
#include "timer.h"


#define PIN_SCL    5  
#define PIN_SDA    6
// #define I2C_PORT   GPIOE  



void I2C_Initi(void);
void I2C_Start(void);
void I2C_Stop(void);
void I2C_Send_Byte(u8 txd);
u8 I2C_Read_Byte(unsigned char ack);
u8 I2C_Wait_Ack(void);
u8 I2C_Wait_Ack(void);
void I2C_NAck(void);
void SingleWrite(u8 daddr, u8 addr, u8 data);
u8 SingleRead(u8 daddr, u8 addr);
void I2C_READ_BYTES(u8 slaveaddr, u8 registeraddr, u8* pbuffer, u16 num);
void I2C_SEND_BYTES(u8 slaveaddr, u8 registeraddr, u8* pbuffer, u16 num);


#endif 