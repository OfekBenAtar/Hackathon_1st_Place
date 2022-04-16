#define LEDS_BASE_ADDR 0x010
#define LEDS LEDS_BASE_ADDR 
#define SEVSEG (LEDS_BASE_ADDR +4)

#define ACCEL_BASE 0x020
#define ACCEL_CTRL ACCEL_BASE 
#define ACCEL_PERF_COUNTER (ACCEL_BASE + 0x4)
#define ACCEL_A (ACCEL_BASE + 0x8)
#define ACCEL_B (ACCEL_BASE + 0xc)
#define ACCEL_C (ACCEL_BASE + 0x10)
#define ACCEL_D (ACCEL_BASE + 0x14)
#define ACCEL_E (ACCEL_BASE + 0x18)
#define ACCEL_F (ACCEL_BASE + 0x1c)
#define ACCEL_G (ACCEL_BASE + 0x20)
#define ACCEL_H (ACCEL_BASE + 0x24)

#define PRINT(i, j) *((int *)(i)) = (j)
#define STOP while(1)

int main() {
	int* leds = (int*)0x14;
	int* accel_ctrl_ptr = (int*)ACCEL_CTRL;
	int* accel_perf_ctr = (int*)ACCEL_PERF_COUNTER;
	int* accel_data_a_ptr = (int*)ACCEL_A;
	int* accel_data_b_ptr = (int*)ACCEL_B;
	int* accel_data_c_ptr = (int*)ACCEL_C;
	int* accel_data_d_ptr = (int*)ACCEL_D;
	int* accel_data_e_ptr = (int*)ACCEL_E;
	int* accel_data_f_ptr = (int*)ACCEL_F;
	int* accel_data_g_ptr = (int*)ACCEL_G;
	int* accel_data_h_ptr = (int*)ACCEL_H;
	/*
	unsigned int d0 = 0x02010201;
	unsigned int d1 = 0x05040302;
	unsigned int d2 = 0x02020405;
	unsigned int d3 = 0x07040602;

	unsigned int m0 = 0x00010102;
	unsigned int m1 = 0x00010101;
	unsigned int m2 = 0x00020101;
	*/
	*accel_data_a_ptr = 0x02010201;
	*accel_data_b_ptr = 0x050402ff;
	*accel_data_d_ptr = 0x02030405;
	*accel_data_e_ptr = 0x07040602;

	*accel_data_f_ptr = 0x00010201;
	*accel_data_g_ptr = 0x00020402;
	*accel_data_h_ptr = 0x00010201;
	
	*accel_ctrl_ptr = 0x00000001; 
	PRINT(SEVSEG, *accel_data_c_ptr);
	//PRINT(SEVSEG, *accel_perf_ctr);

	PRINT(LEDS, *(accel_data_c_ptr)>>24 & 0xFF);
	STOP;
}
