#include "gpio.h"
#include "timer.h"

#define DHT11_IO 0

#define DHT11_READ (gpio1->in & (1 << DHT11_IO))
#define DHT11_HIGH (gpio1->out |= (1 << DHT11_IO))
#define DHT11_LOW (gpio1->out &= ~(1 << DHT11_IO))

#define DHT11_IN (gpio1->mode &= ~(1 << DHT11_IO))
#define DHT11_OUT (gpio1->mode |= (1 << DHT11_IO))




/*DHT11复位和检测响应函数，返回值：1-检测到响应信号；0-未检测到响应信号*/
u8 DHT11RstAndCheck(void)
{
    u8 timer = 0;

    DHT11_OUT;
    DHT11_LOW;    // 输出低电平
    delayms(20);     // 拉低至少18ms
    DHT11_HIGH;    // 输出高电平
    delayus(30);     // 拉高20~40us
    DHT11_IN;
    while (!DHT11_READ) // 等待总线拉低，DHT11会拉低40~80us作为响应信号
    {
        timer++; // 总线拉低时计数
        delayus(1);
    }
    if (timer > 100 || timer < 5) // 判断响应时间
    {
        return 0;
    }
    timer = 0;
    while (DHT11_READ) // 等待DHT11释放总线，持续时间40~80us
    {
        timer++; // 总线拉高时计数
        delayus(1);
    }

    if (timer > 100 || timer < 5) // 检测响应信号之后的高电平
    {
        return 0;
    }
    return 1;
}

/*读取一字节数据，返回值-读到的数据*/
u8 DHT11ReadByte(void)
{
    u8 i;
    u8 byt = 0;
    DHT11_IN;
    for (i = 0; i < 8; i++)
    {
        while (DHT11_READ)
            ; // 等待低电平，数据位前都有50us低电平时隙
        while (!DHT11_READ)
            ; // 等待高电平，开始传输数据位
        delayus(40);
        byt <<= 1;    // 因高位在前，所以左移byt，最低位补0
        if (DHT11_READ) // 将总线电平值读取到byt最低位中
        {
            byt |= 0x01;
        }
    }

    return byt;
}

/*读取一次数据，返回值：Humi-湿度整数部分数据,Temp-温度整数部分数据；返回值: -1-失败，1-成功*/
u8 DHT11ReadData(float* Humi, float* Temp)
{
    u8 i;
    u8 buf[5];

    if (DHT11RstAndCheck()) // 检测响应信号
    {
        for (i = 0; i < 5; i++) // 读取40位数据
        {
            buf[i] = DHT11ReadByte(); // 读取1字节数据
        }
        if ((buf[0] + buf[1] + buf[2] + buf[3])%256 == buf[4]) // 校验成功
        {
            Humi[0] = buf[0] + buf[1]/10.0;
            Temp[0] = (buf[2] & 0x7f) + buf[3]/10.0;
            if (buf[2] & 0x80) Temp[0] = - Temp[0];
        }
        return 1;
    }
    // 响应失败返回0
    return 0;
}

/*DHT11初始化函数*/
u8 DHT11Init()
{
    return DHT11RstAndCheck(); // 返回DHT11状态
}