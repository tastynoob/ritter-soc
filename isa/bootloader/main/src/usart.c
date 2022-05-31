#include "usart.h"

void send_char(char c) {
    USART->write = c;
    while (1) {
        int tx_finish = USART->ctrl & 0x1;
        if (tx_finish) {
            return;
        }
    }
}
void send_string(char* s) {
    for (int i = 0;s[i];i++) {
        send_char(s[i]);
    }
}

void send_buf(u8* buf, u32 len) {
    for (int i = 0;i < len;i++) {
        send_char(buf[i]);
    }
}

byte get_char() {
    while (1) {
        int ctrl = USART->ctrl;
        int rx_finish = ctrl & 0x2;
        int rx_err = ctrl & 0x4;
        if (rx_finish | rx_err) {
            return USART->read;
        }
    }
}
u32 get_u32() {
    u32 a = get_char();
    u32 b = get_char();
    u32 c = get_char();
    u32 d = get_char();
    return a | (b << 8) | (c << 16) | (d << 24);
}


int get_line(char* buff) {
    for (int i = 0;;i++) {
        buff[i] = get_char();
        if ((buff[i] == '\n') || (buff[i] == '\r')) {
            buff[i + 1] = 0;
            return i + 1;
        }
    }
}

int _write(int fd, char* pBuffer, int size) {
    for (int i = 0;i < size;i++) {
        send_char(pBuffer[i]);
    }
    return size;
}


