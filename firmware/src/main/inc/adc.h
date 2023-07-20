#ifndef _ADC_H_
#define _ADC_H_


#include "config.h"

typedef struct {
    volatile u32 channel;
    volatile u32 ctrl;
    volatile u32 read;
} ADC;

#define adc1 ((volatile ADC *)0xf4000000)



#endif