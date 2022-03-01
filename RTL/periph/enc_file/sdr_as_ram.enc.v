
`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: anlgoic
// Author: 	xg 
// description: sdram as ram top module
//////////////////////////////////////////////////////////////////////////////////

`define   DATA_WIDTH                        32
`define   ADDR_WIDTH                        21
`define   DM_WIDTH                          4
`define   ROW_WIDTH                        11
`define   BA_WIDTH                        2

module sdr_as_ram  #( parameter self_refresh_open=1)
	( 
	    input   		Sdr_clk,
		input			Sdr_clk_sft,
        input   		Rst,
			  			  
		output			Sdr_init_done,
		output			Sdr_init_ref_vld,
		output	    	Sdr_busy,
		
		input			App_ref_req,		
		
        input						App_wr_en, 
        input  [`ADDR_WIDTH-1:0]	App_wr_addr,  	////row[10:0],bank[1:0],col[7:0]
		input	[`DM_WIDTH-1:0]		App_wr_dm,
		input	[`DATA_WIDTH-1:0]	App_wr_din,
		
		input						App_rd_en,
		input	[`ADDR_WIDTH-1:0]	App_rd_addr,
		output						Sdr_rd_en,	//synthesis keep
		output	[`DATA_WIDTH-1:0]	Sdr_rd_dout,//synthesis keep
		

		output							SDRAM_CLK,
		output  						SDR_RAS,
		output							SDR_CAS,
		output							SDR_WE,
		output		[`BA_WIDTH-1:0]		SDR_BA,
		output		[`ROW_WIDTH-1:0]	SDR_ADDR,
		output		[`DM_WIDTH-1:0]		SDR_DM,
		inout		[`DATA_WIDTH-1:0]	SDR_DQ		
		
	);
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Anlogic"
`pragma protect encrypt_agent_info = "Anlogic Encryption Tool anlogic_2019"
`pragma protect key_keyowner = "Anlogic", key_keyname = "anlogic-rsa-002"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
ldMJHWsGtXnaYQQzfACBjXZ5VtRICTASO5GkUE3OfelYLt7eR/QjlOJPN/7Vpmza
wKB3Oy8JaLFnN0fHCR8mfGutSxgF5ouSlKhUmWUU28JfcGv8nLausDYJtAjxPtBb
Uq/vai2y3RsBGZ8FXsn6t8KYlXOVMI/dj+6lKpTR9Sk=
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname = "CDS_RSA_KEY_VER_1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
OwDq5HDfWWNPTPpZEvUtqk/ahvG36HB5/LoDTlm3WN5JUq1t7rwcfG6gYZmUMrko
L2gkebFviE8olhdZAuSCW4KUzV5exQyNZjfn3AunrURHjVGilj/eZEJ4jhfFxUXT
oqhGeWjtW5dVDRMDOZIfSAtw4W4PKl6X0Pv+PPm/ao6zTZUEqJeMsXe7TvkjzlWT
uKGIJZovmbPkPMOjz/YmK2wuwiF49zIqEBS/RfHIBc44Sg7K6kggJRbOv5dVwKKc
R6vcnjAP2yQo1KnBltRC02KiH543GkvOW+hwPViyYabW50Pp0L2pa4BsX8IF2YGK
IIZYYDyvpswLefWdbdKKbg==
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
P4lse2XqEbGaLeHh5Wk3KWbMmXNgZ93DL40eB5NRECVhSY1gHAC59JuaavHZXxiU
29OEr20YMjAf9V2wtw13IT9sf8Kfzmumhw7zfToPVCm1fG+YDsyC0D0NLRJP2S3B
F4VawvVCoL7LyY6nI5sJJgp8tBDPWRpy0E8dw8v6xdI=
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
SH9kr4sayIDz0T6vEYaFWfxZcKHf95pmHXkgYrfxFoe9nJqePjsVsOG8EZIH/nL1
orpTa5jwU2R3xe4M3YQpPhxELIsmFVNSD02ztyrve1Wvu3RYtBpg2kwB4HC8zzWx
v8FQRPTXNTO6N9O6qPOyNDCYb6xi1bQ6Npe2SFbzT4+V5/3e84flusYx4FQYACDf
qLbu4fBmBIyy+ByTATJYNylJXa2PCyFVLnz9E+YZbQH+i6x2fa5yDJJRoAM3NHaO
GdnIXoBMvXLDVJFOUVpO1SzFWXTth9Ro0qaRSzn55vcX93yYl/Juc+PB+tIvQ4UO
4aJjTX/HcGRqMHc0DZ/3+A==
`pragma protect key_keyowner = "Synopsys", key_keyname = "SNPS-VCS-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
H9Z99uxsqHjGTB6i2C1S25/iBwXeFBlEnRECbPzR9gsg9nEuNlrkEcUI90t4IsjX
cC92YXm8B7ncRc/aGvMym8M2GD7m1JpQhUTWpogPCUPpDN2Ql2Y9ayL6oFZ0j7UJ
bcZDXPkDXMkBTf1D8h+NctHYNGUJYBvzZqmZ5oOFulI=
`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 2160)
`pragma protect data_block
bUM3SmEzTWRlcHZiRnllRpi1K6Hx2dDEFMg59XbpjNCqCmHIWvwx6UoFWuy9O5g9
u5pH0oksy8YCGQNhNF/hFIOnp/eng9w6meOCcwk/pvsNM9+3q35wJzu1Qytv9BKM
frc5dZ/trPCbwve+k5/S1xcXXJMd5pvtHhbE9eYyQw8N3IYULgoubOPBheA5d9FM
wKt/oJlnis9O9OcbaB0ZIUPTmWPph81kuJFqngytfc5fwuOxy0Gc2tKlctY2ssdr
4E6XOPWhrwMqGpmetF734FumJ9tA77T6xJRLz97Jx+UuxslrfcmmNAhUBL+DJuZ3
b9Nu7rTucIBt5heO3fO24Cwk3AjipKjwHVj0gj7IgaeYRRIAYSidSJftNPBAM1OU
WUkUkVqF/r+n/2BCJ8Ffee9YcCNW5BYzPNgOB5NR3jCea05a2LUVZ11Ln/OtF/Hg
PJ9SGAAx1UMm9BNbr/mxyHbxEZ3c0Gl6JEsZvreSTPes/zr3kq4uY2nBcXnqtwPy
Qe/ageka1dkMJD3X7+fAyhq4VE3ytKlZz5zMzOzHF6tMTcjMK3ebtVhWLAg3JhMd
FgoTZDX9o30e5aC544BPPefRfLoFfjkvnP3UT09qGIsvyttAXRQxq2jSbuEQqSGb
Elwcdg9XOJIce+VME0+NStm9B2Ocjzu23i3PUKFVF2nQTRWqqLjQeUGzpRHkK9zf
JpPD4CJVx4bsrg8iOIEQWihGtb1AdR2nXoJwCkR8nJuxNakTUcJBHGic80bx65j8
WjLXa2Qx7ae7ItIvGS7GCjTqqAIXPMwCli/NoNK61UiwXdu0rtwmreVUoEZaTndD
ZzBMjOz/x5LHIixjO2Fco09Qw4IzkoS0N8lBFR5W6zgGVqd5ao9avm+qISiv6XiX
9r1bBImupmkqmjaBrDNqyR1YC8JAf8nJH1ug4G+1y/lBaJUl7trKoObO7ql3ocpt
N5AtSsvNOghrJmL/NdgsI5kwp0oUNn8JI/FYD1+l9DNjrJholGpSmj93RtlYgcIl
7I5I2q0yTB+vKgq7zWfmTiN2+kfZXpG7dLEgKjG2AemqiwSeaNWuyp3CPUn4ITw5
XNk1Afx6pcPxgrxxvvNYNGfHu57nbyLBnT577BblYGUH/X9yQCi/pdN2MHDScVTr
9XGR0+Y0DX+eBiowFVaEoS2kLxtKWwdi3px9H3PpDJoJzmn1o87AJSxwih/ZBy6C
qLmazp1hd5sBD7aGQa8FSbq3wMgOzxRidHpA5iOBOSTG8PwDhfgIExp0dz+wMCgf
ZBBSKkXdPADwgbi07niGYrZ/ivYSkU0lmN3kDnVPHq2VEqwrQVG/wag5FwbPSvW3
4PLrDc8vZYPWyUMjZ8w/NGtw58yKBzEhkPjMCtaI3lFHNpoHmcs315SYZAtekCIa
lDFquofZ94dnwtxzHmDDtdBaR2H8Jkis+yfYFaSyLr/TYgBB+xdUNXWzYgURBECW
f47MYcVpqqrdk0GGeH0blDbedVlvs7n7QEGUCUMqH1gfFM7Tg/8oPgmSxyTrSdaM
BtwrQsmfwgXebgamALNti9lmJTFY0/wI4ZGOUzqYea6VudSXNHlmwLcppyLm/krB
R8Ya1RKfvRVGYy6pDxqjt3lCyvYbpnLfjHDf34qWS9ye0pIax7BGXhT4zgsLw+Vf
3djpYE7BYFE+s1tk6kZZhtbtVOfF3yJYYUU7QevYQymnyNSqMqsLEPX6zQ9D3UUA
JtMhDK1F/pOFGMYNclHjyy3mMIEIvgPjYm+/nUb2RHF8WV1Sx7fwQXseX8agehPq
ciX9Y5UN8YrYOvzXM8paSIiARW2rgztL9EWDXtRl8MppvL1jpC6vSczek7b80W0L
zxt/otmurl5SXqFXFflHn8KxOKXd7RveL8dYZASBGb5HUW31ogIiY4rAE22CgN6B
dJ9jXTVx5GedZqVknN8ysPgwfiWd6RYYVvMHUMgrLtLXQ9FAj0FMZt8jjN8EX5WY
wmdW78PXSFjMUrY4+ROfBr00+SI6tTtdrWSzDiiJfAQhIrLTHzdVbWvrH1512sDP
vnLzY60eN/a5vk0VdAzPrjjcKzA1hPUlzAa+2C6ZOecaNUbia5Sezgyspz5PLAvq
26Lo6+NIKaaaebq8WYP56MuPIlX3N4p8Z6VPp/JSsqgc77SUgriPeJwYIg1B6LZ4
bcrra415rPFzUeBg8Mc8nJlASNOVGFP/gc0RQpQ1KsE1WB4Ok78PXzTehHx87SW/
pqyLvPhRSawOyqnsKTaASVGUkrb8HeiM29apgzTYECvxmimw4VWQGJ68jXsrzV0c
BAtHy1jNFoeCawAh8/oN0Im8zwzbGVdxSlLeoIEyiX34/K2/I8gZh+7JEY/HDc2+
pa1Z4ZBpOwmnXK3ZfCCJZiyVTwIl3Lv8yQklD7Ln5zFwiCy79B3oj55mUmnRJija
jlBDL/HLePCzQzdw4JgrVv/f8Q23vryxqVfSEXUj+WXLXaQjeBj6RMzBe/lKTnE+
kBDg8OZqD9jxLi5xxM31wxZIY5Up0/L9x0J4zebFSrHmelu2iTJqGBbqBst5k/kY
8rXBeetPFiAEfKKh5PdG4aSW6jW5ejvGKU4VvIbR5ckQ2NqegvZ+f4rduxk21c1h
iDqQf87suGnrYbjYi/dbwDOjhTaGksGVF+sgC0XYqcI1CnJF+oVZNhxMSwFe6BXr
P67x+i9cFXMSYtqPHEr5266Bv3vtn4dmPXjCO1LoifEaVLAxBTl1kOd3ws3/tCYg
2qNKtZXRFm0i9EhhBiQi1JtfIEqHS1HkoxLKVRVS6b5hIQho1I6E8NjkpzjwTqa2
NsqGFviON2+4k9w+GOHMXPeG2DP3j4uKEbNpdwY1abhdLVzWF9uSwSarxbegY+hZ
`pragma protect end_protected

endmodule


