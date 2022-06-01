


#include "config.h"


typedef struct {
    volatile u32 ctrl;
    volatile u32 lo;
    volatile u32 hi;
}TIMER_DEF;


typedef struct {
    volatile u32 ctrl;
    volatile u32 reload;
    volatile u32 comp;
}PWM_DEF;

#define TIMER_BASE 0xf2000000
#define TIMER ((volatile TIMER_DEF*)TIMER_BASE)

#define PWM1 ((volatile PWM_DEF*)0xf3000000)



void timer_clear();
u64 timer_getms();
u64 timer_getus();