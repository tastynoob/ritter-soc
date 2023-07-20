#include "usart.h"
#include "timer.h"
#include "GPIO.h"
#include "adc.h"
#include "dht11.h"
#include "oled.h"
#include <stdio.h>
#include <string.h>
#include "i2c.h"
#include "bmp280.h"


u8 handShake() {
    if (avaliable(usart2)) {
        char c = get_char(usart2);
        send_char(usart2, 'b');
        return c == 'a';
    }
    return 0;
}

float read_adc() {
    while (!(adc1->ctrl)) {} //wait for high
    return ((3000.0 - adc1->read) / 3000 * 100 - 50) * 2;
}

void OLED_ShowChars(u8 x, u8 y, char* chr, u32 size) {
    unsigned char j = 0;
    while (size--) {
        OLED_ShowChar(x, y, chr[j]);
        x += 8;
        if (x > 120) { x = 0;y += 2; }
        j++;
    }
}



float k1 = 0;
int main() {
    // 50% pwm
    PWM1->reload = 8000;
    PWM1->comp = 6000;
    PWM1->ctrl = 0x01;

    adc1->channel = 0x00;//channel 0
    adc1->ctrl = 0x1;// start convert

    GPIO_OLED_InitConfig();
    I2C_Initi();
    BMP280_Init(BMP280_TEMPERATURE_16BIT, BMP280_TEMPERATURE_16BIT, BMP280_NORMALMODE);

    if (!DHT11Init()) {
        sprintf(stringBuf, "dht11 error!");
        OLED_ShowString(0, 0, stringBuf);
        sprintf(stringBuf, "plz restart!");
        OLED_ShowString(0, 2, stringBuf);
        while (1);
    }
    
    send_string(usart1, "Start!\n");

    float humi = 0, temp = 0, adc = 0;
    float temperature=0;
    float pressure=0;
    int ctl_auto = 1, ctl_lux = 0;
    u64 k = timer_getms();
    // used for step
    u64 lastTime[4] = { k, k, k, k };
    while (1) {
        u64 thisTime = timer_getms();

        if (handShake()) {
            send_string(usart1, "HandShaked!\n");
            
            send_string(usart2, stringBuf);// send data
            send_char(usart2, '\n');
            get_line(usart2, recvBuf);// received

            send_string(usart1, "received:");
            send_string(usart1, recvBuf);
            send_char(usart1, '\n');

            int t0, t1;
            u8 n = sscanf(recvBuf, "Auto:%d;Lux:%d;", &t0, &t1);
            if (n == 2) {// control
                ctl_auto = t0;
                ctl_lux = t1;
            }
            else {
                send_string(usart1, "receive error!\n");
            }
        }


        
        // 500ms, update
        if (thisTime - lastTime[0] > 500) {
            lastTime[0] = thisTime;
            
            if (DHT11ReadData(&humi, &temp)) {
                adc = read_adc();
                sprintf(stringBuf, "Temp:%.1f;Prs:%.1f;Humi:%.1f;Lux:%.1f;", temp-4, fabs(pressure) , humi, adc);
                send_string(usart1, stringBuf);
                send_char(usart1, '\n');
                char* s0 = stringBuf;
                char* s1 = strchr(stringBuf, ';');
                s1++;
                char* s2 = strchr(s1, ';');
                s2++;
                char* s3 = strchr(s2, ';');
                s3++;
                OLED_ShowChars(0, 0, s0, s1 - s0 - 1);
                OLED_ShowChars(0, 2, s1, s2 - s1 - 1);
                OLED_ShowChars(0, 4, s2, s3 - s2 - 1);
                OLED_ShowString(0, 6, s3);
            }

            if (ctl_auto) { // auto mode
                PWM1->comp = 1000 - 1000 / 100 * adc;
            }
            else {
                PWM1->comp = 6000 / 100 * ctl_lux;
            }
        }
        if (thisTime - lastTime[1] > 1000) {
            lastTime[1] = thisTime;
            BMP280_ReadTemperatureAndPressure(&temperature, &pressure);
        }
    }
}



