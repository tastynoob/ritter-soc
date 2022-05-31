#include "usart.h"
#include "timer.h"
#include "GPIO.h"

void delayms(u32 ms) {
    u64 start = timer_getms();
    while (timer_getms() - start < ms);
}
void delayus(u32 us) {
    u64 start = timer_getus();
    while (timer_getus() - start < us);
}


void moto_set(u32 a) {
    gpio1->out = 0xf;
    delayus(a);
    gpio1->out = 0x0;
}


#define max_pos 3800
#define min_pos 100

int main() {
    gpio1->mode = 0xf;//输出模式
    gpio1->out = 0x0;
    while (1) {
        u32 head = get_u32(usart2);
        if (head != 0x5a5a5a5a) {
           continue;
        }
        u32 pos = get_u32(usart2);
        //将100~3800映射至500~2500
        // 2000 => 1500us
        float k = pos / 4000.0;
        u32 kp = 500 + 2000 * k;
        moto_set(kp);
        printf("%d\n", kp);
    }
}



