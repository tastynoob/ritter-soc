#include "timer.h"







void timer_clear() {
    TIMER->lo = 0;
    TIMER->hi = 0;
}
uint64_t timer_getms() {
    uint64_t time = (((uint64_t)(TIMER->hi)) << 32) + ((uint64_t)(TIMER->lo));
    time = time / 84000;
    return time;
}