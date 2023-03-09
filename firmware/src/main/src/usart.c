#include "usart.h"

void send_char(USART_DEF* usart, char c) {
    usart->write = c;
    while (1) {
        int tx_finish = usart->ctrl & 0x1;
        if (tx_finish) {
            return;
        }
    }
}
void send_string(USART_DEF* usart,const char* s) {
    for (int i = 0;s[i];i++) {
        send_char(usart,s[i]);
    }
}

void send_buf(USART_DEF* usart, u8* buf, u32 len) {
    for (int i = 0;i < len;i++) {
        send_char(usart,buf[i]);
    }
}

byte get_char(USART_DEF* usart) {
    while (1) {
        int ctrl = usart->ctrl;
        int rx_finish = ctrl & 0x2;
        int rx_err = ctrl & 0x4;
        if (rx_finish | rx_err) {
            return usart->read;
        }
    }
}
u32 get_u32(USART_DEF* usart) {
    u32 a = get_char(usart);
    u32 b = get_char(usart);
    u32 c = get_char(usart);
    u32 d = get_char(usart);
    return a | (b << 8) | (c << 16) | (d << 24);
}


int get_line(USART_DEF* usart, char* buff) {
    for (int i = 0;;i++) {
        buff[i] = get_char(usart);
        if ((buff[i] == '\n') || (buff[i] == '\r')) {
            buff[i + 1] = 0;
            return i + 1;
        }
    }
}

int _write(int fd, char* pBuffer, int size) {
    for (int i = 0;i < size;i++) {
        send_char(usart1, pBuffer[i]);
    }
    return size;
}


