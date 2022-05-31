


#include "config.h"


typedef struct {
    volatile u32 ctrl;
    volatile u32 lo;
    volatile u32 hi;
}TIMER_DEF;

#define TIMER_BASE 0xf2000000
#define TIMER ((volatile TIMER_DEF*)TIMER_BASE)



void timer_clear();
u64 timer_getms();
u64 timer_getus();