#pragma once

#include "config.h"


u8 DHT11Init();
u8 DHT11ReadData(float* Humi, float* Temp);
