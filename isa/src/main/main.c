#include "usart.h"
#include "timer.h"
#include "stdio.h"



void delayms(uint32_t ms) {
    uint64_t start = timer_getms();
    while (timer_getms() - start < ms);
}




// char buff[100];
// int main() {
    
//     printf("123,%f\n",1.2);
// }




