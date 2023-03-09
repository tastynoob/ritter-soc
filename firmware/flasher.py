from os import system
from secrets import token_bytes
import struct
import serial
import serial.tools.list_ports
import sys

max_pack_size = 1024

com_id = 0
# crc32校验算法
def crc32(data):
    # 校验值
    crc = 0
    # 遍历数据
    for i in range(len(data)):
        # 计算校验值
        crc = crc ^ data[i]
        for j in range(8):
            if crc & 1:
                crc = (crc << 1) ^ 0x04C11DB7
            else:
                crc = crc << 1
        crc &= 0xffffffff
    # 返回校验值
    return crc

class Pack:
    head = 0x5a5a5a5a
    type = 0xee
    #以4字节作为一个单位
    len = 0
    crc = 0
    data = []


flash_file_path = sys.argv[1]
#穷举所有的串口
com_list = serial.tools.list_ports.comports()
print("串口列表:")
for i in range(0, len(com_list)):
    print("%d: %s" % (i, com_list[i]))
print("请选择串口:")
com_id = int(input())
#连接串口
ser = serial.Serial(com_list[com_id].device, 115200, timeout=0.5)


flash_file = open(flash_file_path, "rb")
flash_data = flash_file.read()
flash_file.close()
if len(flash_data)%4 != 0:
    flash_data += b'\x00'*(4 - len(flash_data)%4)

#将数据分包
pack_num = len(flash_data)//max_pack_size
other_pack =0
if len(flash_data)%max_pack_size != 0:
    other_pack = 1

# typedef struct {
#     u32 head;//始终为0x5A5A5A5A
#     u32 type;//包类型,0xee:主机准备烧录系统,0x01:主机发送数据请求,0x02:从机接收正确,0x03:从机接收异常需重新发送数据,0xaa:主机发送结束
#     u32 len;//包大小(以4字节为单位):始终是4的倍数
#     u32 crc;//整个包的crc32校验
#     u32 data[0];
# }Pack;

packs = []
for i in range(pack_num):
    pack = Pack()
    pack.type = 0x01
    pack.len = int((max_pack_size)//4)
    if max_pack_size%4 != 0:
        exit("数据长度不是4的倍数")
    pack.crc = crc32(flash_data[i*max_pack_size:(i+1)*max_pack_size])
    pack.data = bytearray(flash_data[i*max_pack_size:(i+1)*max_pack_size])
    # #翻转
    # for i in range(len(pack.data)//4):
    #     a = pack.data[i*4]
    #     b = pack.data[i*4+1]
    #     pack.data[i*4] = pack.data[i*4 + 3]
    #     pack.data[i*4 + 1] = pack.data[i*4 + 2]
    #     pack.data[i*4 + 2] = b
    #     pack.data[i*4 + 3] = a
    # #翻转
    # pack.data.reverse()
    packs.append(pack)

if other_pack:
    pack = Pack()
    pack.type = 0x01
    pack.len = int((len(flash_data)%max_pack_size)/4)
    if(len(flash_data)%max_pack_size)%4 != 0:
        exit("数据长度不是4的倍数")
    pack.crc = crc32(flash_data[int(-pack.len*4):])
    pack.data =bytearray( flash_data[int(-pack.len*4):])
    # #翻转
    # for i in range(len(pack.data)//4):
    #     a = pack.data[i*4]
    #     b = pack.data[i*4+1]
    #     pack.data[i*4] = pack.data[i*4 + 3]
    #     pack.data[i*4 + 1] = pack.data[i*4 + 2]
    #     pack.data[i*4 + 2] = b
    #     pack.data[i*4 + 3] = a
    # pack.data.reverse()
    packs.append(pack)


def flash_pack(pack:Pack):
    ser.write(pack.head.to_bytes(4, 'little'))
    ser.write(pack.type.to_bytes(4, 'little'))
    ser.write(pack.len.to_bytes(4, 'little'))
    ser.write(pack.crc.to_bytes(4, 'little'))
    ser.write(pack.data)
    ser.flush()
    # print(pack.head.to_bytes(4, 'little'))
    # print(pack.type.to_bytes(4, 'little'))
    # print(pack.len.to_bytes(4, 'little'))
    # print(pack.crc.to_bytes(4, 'little'))
    # print(pack.data)

def receive_pack():
    head = ser.read(4)
    type = ser.read(4)
    lens = ser.read(4)
    crc = ser.read(4)
    data = ser.read(int.from_bytes(lens, 'little'))
    if len(head) != 4:
        exit("接收失败")
    if len(type) != 4:
        exit("接收失败")
    if len(lens) != 4:
        exit("接收失败")
    if len(crc) != 4:
        exit("接收失败")
    head = struct.unpack('<I', head)[0]
    type = struct.unpack('<I', type)[0]
    lens = struct.unpack('<I', lens)[0]
    crc = struct.unpack('<I', crc)[0]
    return  head, type, lens, crc, data

# a = bytearray(b'1234123412341234')
# print(len(a))
# print(hex(crc32(a)))
# #翻转a
# for i in range(len(a)):
#     b = a[i]
#     a[i] = a[len(a) - i - 1]
#     a[len(a) - i - 1] = b
# ser.write(a)


# data = ser.read(16)
# n = ser.readlines()
# print(data)
# print(str(n))


# exit(0)

print("文件大小:", len(flash_data))
print("分包数量:", len(packs))
print("开始烧录...")
start_pack = Pack()
start_pack.type = 0xee
start_pack.len = 0
start_pack.crc = 0
start_pack.data = []
flash_pack(start_pack)
#接收响应包
head, type, lens, crc, data = receive_pack()
if head != 0x5a5a5a5a and type != 0x02:
    print("连接失败", head, type)
    exit(0)
print("连接成功")
i=0
cnt = 0
while(True):
    print("第%d包大小:%d" % (i, packs[i].len*4))
    flash_pack(packs[i])#发送包
    head, type, lens, crc, data = receive_pack()#接收包
    
    if head == 0x5a5a5a5a and type == 0x02:
            i+=1
            cnt=0
            print("第%d包发送成功" % i)
    else:
        cnt+=1
        print("第%d包发送失败" % i,":开始重新发送")
    if cnt>=5:
        print("第%d包发送失败" % i,":烧录超时")
        exit(0)
    if i == len(packs):
        break

print("烧录完成")


end_pack = Pack()
end_pack.type = 0xaa
end_pack.len = 0
end_pack.crc = 0
end_pack.data = []
flash_pack(end_pack)
ser.close()

