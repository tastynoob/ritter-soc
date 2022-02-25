#include "usart.h"
#include "timer.h"
#include "stdio.h"





int main() {
    char buff[100];

    while (1) {
        get_line(buff);
        printf("%s\n", buff);
    }
}

