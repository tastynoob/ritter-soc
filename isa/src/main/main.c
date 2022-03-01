#include "usart.h"
#include "timer.h"
#include "stdio.h"



void delayms(uint32_t ms) {
    uint64_t start = timer_getms();
    while (timer_getms() - start < ms);
}


//调用muldf3会写2次t2

int* ptr = 0x02000000;

int main() {
    printf("start test\n");
    delayms(1000);
    printf("delay 1000 finish\n");
    printf("write finish\n");
}

