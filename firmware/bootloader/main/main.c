#include "usart.h"
#include "timer.h"
#include "GPIO.h"

void delayms(u32 ms) {
    u64 start = timer_getms();
    while (timer_getms() - start < ms);
}


#define ITCM_BASE 0x00000000
//itcm写入指针
u32 itcm_ptr = 0;
u32* itcm = 0;

//一个简单的bootloader


u32 crc32(u8* buf, u32 len) {
    u32 crc = 0;
    u32 i;
    for (i = 0; i < len; i++) {
        crc = crc ^ buf[i];
        int j;
        for (j = 0; j < 8; j++) {
            if (crc & 1) {
                crc = (crc << 1) ^ 0x04C11DB7;
            }
            else {
                crc = crc << 1;
            }
        }
    }
    return crc;
}

typedef struct {
    u32 head;//始终为0x5A5A5A5A
    u32 type;//包类型,0xee:主机准备烧录系统,0x01:主机发送数据请求,0x02:从机接收正确,0x03:从机接收异常需重新发送数据,0xaa:主机发送结束
    u32 len;//包大小(以4字节为单位):始终是4的倍数
    u32 crc;//整个包的crc32校验
    u32 data[0];
}Pack;



/*
思路:
以包为基础单位传输
首先主机发送一个包头
如果从机接收无误,则回复一个包头

*/

u32 buff[2048];
int main() {
    Pack ack = { 0x5a5a5a5a, 0x02, 0, 0 };
    Pack fail = { 0x5a5a5a5a, 0x03, 0, 0 };
    Pack* pack = (Pack*)buff;
    u32* p = (u32*)pack;
    //等待接收到烧录包
    while (1) {
        for(int i=0;i<4;i++) {
            p[i] = get_u32();
        }
        //主机烧录请求
        if (pack->head == 0x5a5a5a5a && pack->type == 0xee) {
            //返回成功包
            send_buf((u8*)&ack, sizeof(ack));
            break;
        }
    }
    while (1) {
        //开始接收包
        for (int i = 0;i < 4;i++) {
            p[i] = get_u32();
        }
        //开始接收数据
        if (pack->head == 0x5a5a5a5a) {
            if (pack->type == 0x01) {
                for (int i = 0;i < pack->len;i++) {
                    pack->data[i] = get_u32();
                }
                //进行crc校验
                u32 crc = crc32((u8*)pack->data, pack->len*4);
                if (crc == pack->crc) {//校验成功
                    //写入itcm
                    for(int i=0;i<pack->len;i++) {
                        itcm[itcm_ptr++] = pack->data[i];
                    }
                    //返回成功包
                    send_buf((u8*)&ack, sizeof(ack));
                }
                else {//校验失败
                    //返回失败包
                    send_buf((u8*)&fail, sizeof(fail));
                }
            }
            else if (pack->type == 0xaa) {//主机烧录结束,开始执行
                asm("j 0");
                break;
            }
            else {
                //返回失败包
                send_buf((u8*)&fail, sizeof(fail));
            }
        }
    }
    asm("j 0");
}



