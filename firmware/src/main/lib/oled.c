
#include "oled.h"	   
#include "oledfont.h" 


void OLED_WR_Byte(u8 dat, u8 cmd) {
    u8 i;
    if (cmd)
        OLED_DC_Set();
    else
        OLED_DC_Clr();
    for (i = 0;i < 8;i++) {
        delayus(1);
        OLED_SCLK_Clr();
        delayus(1);
        if (dat & 0x80)
            OLED_SDIN_Set();
        else
            OLED_SDIN_Clr();
        delayus(1);
        OLED_SCLK_Set();
        dat <<= 1;
    }
    delayus(1);
    OLED_DC_Set();
    delayus(1);
}



void OLED_Set_Pos(unsigned char x, unsigned char y) {
    OLED_WR_Byte(0xb0 + y, OLED_CMD);
    OLED_WR_Byte(((x & 0xf0) >> 4) | 0x10, OLED_CMD);
    OLED_WR_Byte((x & 0x0f) | 0x01, OLED_CMD);
}


void OLED_Display_On(void) {
    OLED_WR_Byte(0X8D, OLED_CMD);  //SET DCDC锟斤拷锟斤拷
    OLED_WR_Byte(0X14, OLED_CMD);  //DCDC ON
    OLED_WR_Byte(0XAF, OLED_CMD);  //DISPLAY ON
}


void OLED_Display_Off(void) {
    OLED_WR_Byte(0X8D, OLED_CMD);  //SET DCDC锟斤拷锟斤拷
    OLED_WR_Byte(0X10, OLED_CMD);  //DCDC OFF
    OLED_WR_Byte(0XAE, OLED_CMD);  //DISPLAY OFF
}


void OLED_Clear(void) {
    u8 i, n;
    for (i = 0;i < 8;i++) {
        OLED_WR_Byte(0xb0 + i, OLED_CMD);    
        OLED_WR_Byte(0x00, OLED_CMD);      
        OLED_WR_Byte(0x10, OLED_CMD);      
        for (n = 0;n < 128;n++)OLED_WR_Byte(0, OLED_DATA);
    }																		 
}


void OLED_ShowChar(u8 x, u8 y, u8 chr) {
    unsigned char c = 0, i = 0;
    c = chr - ' ';
    if (x > Max_Column - 1) {
        x = 0;
        y = y + 2;
    }

    OLED_Set_Pos(x, y);
    for (i = 0;i < 8;i++)
        OLED_WR_Byte(D8X16[c * 16 + i], OLED_DATA);
    OLED_Set_Pos(x, y + 1);
    for (i = 0;i < 8;i++)
        OLED_WR_Byte(D8X16[c * 16 + i + 8], OLED_DATA);

}


u32 oled_pow(u8 m, u8 n) {
    u32 result = 1;
    while (n--)result *= m;
    return result;
}


void OLED_ShowNum(u8 x, u8 y, u32 num, u8 len, u8 size) {
    u8 t, temp;
    u8 enshow = 0;
    for (t = 0;t < len;t++) {
        temp = (num / oled_pow(10, len - t - 1)) % 10;
        if (enshow == 0 && t < (len - 1)) {
            if (temp == 0) {
                OLED_ShowChar(x + (size / 2) * t, y, ' ');
                continue;
            }
            else enshow = 1;

        }
        OLED_ShowChar(x + (size / 2) * t, y, temp + '0');
    }
}


void OLED_ShowString(u8 x, u8 y, char* chr) {
    unsigned char j = 0;
    while (chr[j] != '\0') {
        OLED_ShowChar(x, y, chr[j]);
        x += 8;
        if (x > 120) { x = 0;y += 2; }
        j++;
    }
}



void OLED_DrawBMP(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char BMP[]) {
    unsigned int j = 0;
    unsigned char x, y;

    if (y1 % 8 == 0) y = y1 / 8;
    else y = y1 / 8 + 1;
    for (y = y0;y < y1;y++) {
        OLED_Set_Pos(x0, y);
        for (x = x0;x < x1;x++) {
            OLED_WR_Byte(BMP[j++], OLED_DATA);
        }
    }
}


void GPIO_OLED_InitConfig(void) {
    gpio1->mode |= 0x1e; // 11110

    OLED_RST_Set();
    delayms(100);
    OLED_RST_Clr();
    delayms(100);
    OLED_RST_Set();

    OLED_WR_Byte(0xAE, OLED_CMD);//--turn off oled panel
    OLED_WR_Byte(0x00, OLED_CMD);//---set low column address
    OLED_WR_Byte(0x10, OLED_CMD);//---set high column address
    OLED_WR_Byte(0x40, OLED_CMD);//--set start line address  Set Mapping RAM Display Start Line (0x00~0x3F)
    OLED_WR_Byte(0x81, OLED_CMD);//--set contrast control register
    OLED_WR_Byte(0xCF, OLED_CMD);// Set SEG Output Current Brightness
    OLED_WR_Byte(0xA1, OLED_CMD);//--Set SEG/Column Mapping     0xa0锟斤拷锟揭凤拷锟斤拷 0xa1锟斤拷锟斤拷
    OLED_WR_Byte(0xC8, OLED_CMD);//Set COM/Row Scan Direction   0xc0锟斤拷锟铰凤拷锟斤拷 0xc8锟斤拷锟斤拷
    OLED_WR_Byte(0xA6, OLED_CMD);//--set normal display
    OLED_WR_Byte(0xA8, OLED_CMD);//--set multiplex ratio(1 to 64)
    OLED_WR_Byte(0x3f, OLED_CMD);//--1/64 duty
    OLED_WR_Byte(0xD3, OLED_CMD);//-set display offset	Shift Mapping RAM Counter (0x00~0x3F)
    OLED_WR_Byte(0x00, OLED_CMD);//-not offset
    OLED_WR_Byte(0xd5, OLED_CMD);//--set display clock divide ratio/oscillator frequency
    OLED_WR_Byte(0x80, OLED_CMD);//--set divide ratio, Set Clock as 100 Frames/Sec
    OLED_WR_Byte(0xD9, OLED_CMD);//--set pre-charge period
    OLED_WR_Byte(0xF1, OLED_CMD);//Set Pre-Charge as 15 Clocks & Discharge as 1 Clock
    OLED_WR_Byte(0xDA, OLED_CMD);//--set com pins hardware configuration
    OLED_WR_Byte(0x12, OLED_CMD);
    OLED_WR_Byte(0xDB, OLED_CMD);//--set vcomh
    OLED_WR_Byte(0x40, OLED_CMD);//Set VCOM Deselect Level
    OLED_WR_Byte(0x20, OLED_CMD);//-Set Page Addressing Mode (0x00/0x01/0x02)
    OLED_WR_Byte(0x02, OLED_CMD);//
    OLED_WR_Byte(0x8D, OLED_CMD);//--set Charge Pump enable/disable
    OLED_WR_Byte(0x14, OLED_CMD);//--set(0x10) disable
    OLED_WR_Byte(0xA4, OLED_CMD);// Disable Entire Display On (0xa4/0xa5)
    OLED_WR_Byte(0xA6, OLED_CMD);// Disable Inverse Display On (0xa6/a7) 
    OLED_WR_Byte(0xAF, OLED_CMD);//--turn on oled panel

    OLED_WR_Byte(0xAF, OLED_CMD); /*display ON*/
    OLED_Clear();
    OLED_Set_Pos(0, 0);
}



