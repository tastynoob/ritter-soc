#ifndef __OLED_H
#define __OLED_H

#include "gpio.h"
#include "timer.h"


#define SIZE 					16
#define XLevelL					0x00
#define XLevelH					0x10
#define Max_Column				128
#define Max_Row					64
#define	Brightness				0xFF 
#define X_WIDTH 				128
#define Y_WIDTH 				64	    

#define OLED_CMD  0				//д����
#define OLED_DATA 1				//д����

#define  GPIO_OLED_SCLK_Pin     4							/* D0 */
#define  GPIO_OLED_PIN_Pin     	3							/* D1 */
#define  GPIO_OLED_RES_Pin     	2							/* RES */
#define  GPIO_OLED_DC_Pin     	1							/* DC */


#define OLED_RST_Clr() (gpio1->out &= ~(1<<GPIO_OLED_RES_Pin))
#define OLED_RST_Set() (gpio1->out |= (1<<GPIO_OLED_RES_Pin))

#define OLED_DC_Clr() (gpio1->out &= ~(1<<GPIO_OLED_DC_Pin))
#define OLED_DC_Set() (gpio1->out |= (1<<GPIO_OLED_DC_Pin))


#define OLED_SCLK_Clr() (gpio1->out &= ~(1<<GPIO_OLED_SCLK_Pin))
#define OLED_SCLK_Set() (gpio1->out |= (1<<GPIO_OLED_SCLK_Pin))

#define OLED_SDIN_Clr() (gpio1->out &= ~(1<<GPIO_OLED_PIN_Pin))
#define OLED_SDIN_Set() (gpio1->out |= (1<<GPIO_OLED_PIN_Pin))


void OLED_Clear(void);
void OLED_Display_On(void);
void OLED_Display_Off(void);
void GPIO_OLED_InitConfig(void);
void OLED_WR_Byte(u8 dat, u8 cmd);
void OLED_Set_Pos(unsigned char x, unsigned char y);
void OLED_ShowChar(u8 x, u8 y, u8 chr);
void OLED_ShowString(u8 x, u8 y, char* p);
void OLED_ShowCHinese(u8 x, u8 y, u8 no);
void OLED_ShowNum(u8 x, u8 y, u32 num, u8 len, u8 size);
void OLED_DrawBMP(unsigned char x0, unsigned char y0, unsigned char x1, unsigned char y1, unsigned char BMP[]);


#endif  



