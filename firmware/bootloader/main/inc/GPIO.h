#include "config.h"



typedef struct
{
    int mode;
    int out;
    int in;
}GPIO;
#define gpio1 ((volatile GPIO*)0xf0000000)