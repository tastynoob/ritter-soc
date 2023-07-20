#include "timer.h"







void timer_clear() {
    TIMER->lo = 0;
    TIMER->hi = 0;
}
u64 timer_getms() {
    u64 time = (((u64)(TIMER->hi)) << 32) + ((u64)(TIMER->lo));
    time = time / 80000;
    return time;
}

u64 timer_getus() {
    u64 time = (((u64)(TIMER->hi)) << 32) + ((u64)(TIMER->lo));
    time = time / 80;
    return time;
}

void delayms(u32 ms)
{
    u64 start = timer_getms();
    while (timer_getms() - start < ms)
        ;
}
void delayus(u32 us)
{
    u64 start = timer_getus();
    while (timer_getus() - start < us)
        ;
}