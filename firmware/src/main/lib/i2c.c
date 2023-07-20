#include "i2c.h"


#define SCL_SET_1 (gpio1->out |= (1<<PIN_SCL))
#define SCL_SET_0 (gpio1->out &= ~(1<<PIN_SCL))

#define SDA_SET_1 (gpio1->out |= (1<<PIN_SDA))
#define SDA_SET_0 (gpio1->out &= ~(1<<PIN_SDA))
#define SDA_GET (gpio1->in & (1<<PIN_SDA))

#define SDA_OUT (gpio1->mode |= (1<<PIN_SDA))
#define SDA_IN (gpio1->mode &= ~(1<<PIN_SDA))


void I2C_Initi(void) {
    gpio1->mode |= 0x60;
    SDA_SET_1;
    SCL_SET_1;
}

void I2C_Start(void) {
    SDA_OUT;
    SDA_SET_1;  //SDA=1
    delayus(10);;
    SCL_SET_1;  //SCL=1
    delayus(10);;
    SDA_SET_0;//SDA=0
    delayus(10);;
    SCL_SET_0;//SCL=0
    delayus(10);;
}

void I2C_Stop(void) {
    SDA_OUT;
    SDA_SET_0;
    delayus(10);;
    SCL_SET_1;
    delayus(10);;
    SDA_SET_1;
    delayus(10);;
}

u8 I2C_Wait_Ack(void) {
    u8 ucErrTime = 0;
    SDA_OUT;
    SDA_SET_1;
    delayus(5);;
    SCL_SET_1;
    delayus(5);;

    while (SDA_GET);

    // while (SDA_GET) {
    //     delayus(2);
    //     ucErrTime++;
    //     if (ucErrTime > 250) {
    //         I2C_Stop();
    //         return 1;
    //     }
    // }
    
    SCL_SET_0;
    delayus(5);;
    return 0;
}

void I2C_Ack(void) {
    SDA_OUT;
    SDA_SET_0;
    delayus(5);;
    SCL_SET_1;
    delayus(5);;
    SCL_SET_0;
}

void I2C_NAck(void) {
    SCL_SET_0;
    SDA_OUT;
    SDA_SET_1;
    delayus(5);;
    SCL_SET_1;
    delayus(5);;
    SCL_SET_0;
}

void I2C_Send_Byte(u8 txd) {
    u8 t;
    SDA_OUT;
    SCL_SET_0;
    delayus(5);;
    for (t = 0;t < 8;t++) {
        if ((txd & 0x80) == 0x80) {
            SDA_SET_1;
        }//SDA=1
        else {
            SDA_SET_0;
        }//SDA=0
        txd <<= 1;
        delayus(5);;
        SCL_SET_1;
        delayus(5);;
        SCL_SET_0;
        delayus(5);;
    }
}

u8 I2C_Read_Byte(unsigned char ack) {
    unsigned char i, receive = 0;
    SDA_OUT;
    SDA_SET_1;
    //SDA_IN;
    delayus(5);;
    for (i = 0;i < 8;i++) {
        SCL_SET_0;
        delayus(5);;
        SCL_SET_1;
        delayus(5);;
        receive <<= 1;
        if (SDA_GET) {
            receive++;
        }
        delayus(5);;
    }
    if (!ack)
        I2C_NAck();//nACK
    else
        I2C_Ack(); //ACK
    return receive;
}

void SingleWrite(u8 daddr, u8 addr, u8 data) {
    I2C_Start();
    I2C_Send_Byte(daddr);
    I2C_Wait_Ack();
    I2C_Send_Byte(addr);
    I2C_Wait_Ack();
    I2C_Send_Byte(data);
    I2C_Wait_Ack();
    I2C_Stop();
}

u8 SingleRead(u8 daddr, u8 addr) {
    u8 data;
    I2C_Start();
    I2C_Send_Byte(daddr);
    I2C_Wait_Ack();
    I2C_Send_Byte(addr);
    I2C_Wait_Ack();
    I2C_Start();
    I2C_Send_Byte(daddr + 1);
    I2C_Wait_Ack();
    data = I2C_Read_Byte(0);//nack
    I2C_Stop();
    return data;
}

void I2C_READ_BYTES(u8 slaveaddr, u8 registeraddr, u8* pbuffer, u16 num) {

    I2C_Start();//开始通讯
    I2C_Send_Byte(slaveaddr);//寻址从机
    I2C_Wait_Ack();//等待回应
    I2C_Send_Byte(registeraddr);//寻址寄存器
    I2C_Wait_Ack();//等待回应


    I2C_Start();//重新通讯
    I2C_Send_Byte(slaveaddr + 1);	//改为读数据
    I2C_Wait_Ack();//等待回应

    for (int t = 0;t < num;t++)//存储数据
    {
        *(pbuffer + t) = I2C_Read_Byte(!(t == num - 1)); //字节没发完，必须给出应答，发完的给个非应答信号
    }
    I2C_Stop();//通讯结束

}


void I2C_SEND_BYTES(u8 slaveaddr, u8 registeraddr, u8* pbuffer, u16 num) {

    I2C_Start();//开始通讯
    I2C_Send_Byte(slaveaddr);//寻址从机
    I2C_Wait_Ack();//等待回应
    I2C_Send_Byte(registeraddr);//寻址寄存器
    I2C_Wait_Ack();//等待回应

    for (int t = 0;t < num;t++)//发送数组中的数据
    {
        I2C_Send_Byte(*(pbuffer + t));
        I2C_Wait_Ack();//每发送一个字节，都需要一个应答
    }
    I2C_Stop();//终止通讯

}