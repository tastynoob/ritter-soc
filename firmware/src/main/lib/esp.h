#ifndef _ESP_H_
#define _ESP_H_

#include "config.h"

// 16 byte
typedef struct {
    u32 head; // 4
    u8 cmd[8]; //8
    u32 end; //4 bytes crc of pack
} LinkPack;


typedef enum {
    None,
    Norm, // client to host : send normal data : temp;humi;lux;
    Req, // host to client
    Resp, // client to host
    Ctl, // host to client : control command
}HeadType;


#endif