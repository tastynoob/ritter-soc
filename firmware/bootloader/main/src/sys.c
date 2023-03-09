

#define fctrl 0x310
#define facc 0x311
#define fop1 0x312
#define fop2 0x313




// //浮点加法函数
// float __addsf3(float a, float b) {
//     asm("csrw 0x310,0x0");//加法模式
//     asm("csrw 0x312,%0" : : "r"(a));//输入a
//     asm("csrw 0x313,%0" : : "r"(b));//输入b
//     asm("nop");
//     asm("nop");
//     asm("csrr a0,0x311");//输出结果
// }
// //浮点减法函数
// float __subsf3(float a, float b) {
//     asm("csrw 0x310,0x1");//减法模式
//     asm("csrw 0x312,%0" : : "r"(a));//输入a
//     asm("csrw 0x313,%0" : : "r"(b));//输入b
//     asm("nop");
//     asm("nop");
//     asm("csrr a0,0x311");//输出结果
// }
// //浮点乘法函数
// float __mulsf3(float a, float b) {
//     asm("csrw 0x310,0x2");//乘法模式
//     asm("csrw 0x312,%0" : : "r"(a));//输入a
//     asm("csrw 0x313,%0" : : "r"(b));//输入b
//     asm("nop");
//     asm("nop");
//     asm("csrr a0,0x311");//输出结果
// }
