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