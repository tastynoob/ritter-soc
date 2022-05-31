
#include "config.h"


typedef struct
{
    int ctrl;
    int write;
    int read;
}USART_DEF;


typedef unsigned char byte;


#define USART_BASE 0xf1000000

#define USART ((volatile USART_DEF*)USART_BASE)


void send_char(char c);
void send_string(char* s);
void send_buf(u8* buf, u32 len);
byte get_char();
u32 get_u32();
int get_line(char* buff);
