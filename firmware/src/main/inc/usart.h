
#include "config.h"


typedef struct
{
    volatile u32 ctrl;
    volatile u32 write;
    volatile u32 read;
}USART_DEF;


typedef unsigned char byte;
#define USART_BASE 0xf1000000
#define usart1 ((USART_DEF*)(USART_BASE))
#define usart2 ((USART_DEF*)(USART_BASE+0x10))

void send_char(USART_DEF* usart,char c);
void send_string(USART_DEF* usart,const char* s);
void send_buf(USART_DEF* usart, u8* buf, u32 len);
byte get_char(USART_DEF* usart);
u32 get_u32(USART_DEF* usart);
int get_line(USART_DEF* usart, char* buff);
