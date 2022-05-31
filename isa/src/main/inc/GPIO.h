#include "config.h"



typedef struct{
    volatile u32 mode;//io模式,1为写,0为读
    volatile u32 out;//写io
    volatile u32 in;//读io
}GPIO;


#define gpio1 ((volatile GPIO*)0xf0000000)