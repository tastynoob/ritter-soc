


#include "config.h"


typedef struct {
    int ctrl;
    int lo;
    int hi;
}TIMER_DEF;

#define TIMER_BASE 0xf2000000
#define TIMER ((volatile TIMER_DEF*)TIMER_BASE)



void timer_clear();
u64 timer_getms();