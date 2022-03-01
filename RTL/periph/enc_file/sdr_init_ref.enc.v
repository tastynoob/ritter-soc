
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: anlgoic
// Author: 	xg 
// description: sdram init and refresh
//////////////////////////////////////////////////////////////////////////////////

`define signle_bit 0

`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "Anlogic"
`pragma protect encrypt_agent_info = "Anlogic Encryption Tool anlogic_2019"
`pragma protect key_keyowner = "Anlogic", key_keyname = "anlogic-rsa-002"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
fL3jeQy7syqqsnmum1IqoZzCDKVMqSdQs9SZOd/9SnLELhRQ+LjH6TuQisZ5TtDp
i4qDEIt+KHiLbl/FbsyPiEcVkBL8nVtCpnAVwe6auqe1QiAWIrPZEom3Mr0/D5ba
b9L9d4RrssP4OUCee81yn/kNr8AfF7jyVtFzhlokQrQ=
`pragma protect key_keyowner = "Cadence Design Systems.", key_keyname = "CDS_RSA_KEY_VER_1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
b4g1ectq7aaTCU84fxG/DEtbaK5nvH5Hgbon7Ep3n7MUAcIeilJu2voEuA1ZmPhU
ivqme8xHIz5s5hAu+05n0m5qxTfb7wx8y08F8KgxD1nKiBB8LTfcHtBp9b0YGVtt
jHucWRhIthMkL4mnnTatqEz732cydQW0pw6eMkqZf56UHEsP3UBctTWKyRmad/wA
uQq7r5k/xZli/TLWMDQxFsW0DjkfUT7qDu4vA6Z0wovSZgb29kylfNqdUyf1c2QD
N+w4JE1IzpPE8LPtvSHrTRGC+cXJdIHz3/nwolvYBuekYmAmX+qdOGI2DUZk38EV
/MMTTPvT5jbJ0nkoJzfgOQ==
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-1"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
U+MldwUAHNq5eBQZwefIjT9YNfsSJUgGC2yF7gCEW3WLeenvyd5kwhiuwDkNLXl/
8NJkMZ1S+gMkyCUEF9vwv0kFBREnYstdROrwDBSvScAhCoefA5x+p8x4uhyR8tvK
IdDyW6Qrhgy59stV8FjX6NhC5ugh4GnwuugzNJclzFc=
`pragma protect key_keyowner = "Mentor Graphics Corporation", key_keyname = "MGC-VERIF-SIM-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 256)
`pragma protect key_block
cKK1EF0xFZ3BTHYWCt4YArSD6ys+EfD1grHn9QZRDxpW6Xs8yW8QKqe1xV6hpKlg
tWaG60eHVh9io9L9+d4s+p+J1mbbMZ4xvmYAdoR+YAwGGy6JdooVC5T9ACnK+WXI
FftgpZPp/SqGH68gFKZF2DsXDAnTEhgbvulnu3LfUX8aKX2ip2zow6VrHJX1D3NU
5gs9M8yOrlP42pbhu7NZ5pZa7FFy+2tL/pp6/W+KTteXZSU32YDDl/S1IXnSmpYw
btXDvHn7UDIWFAF0+E9a6SazUyuDyNTQ8/l4o8aXX1kBgGrKppDcMdqmotKwTRdQ
8AyYC47qZDwPAh4wK9gs+g==
`pragma protect key_keyowner = "Synopsys", key_keyname = "SNPS-VCS-RSA-2"
`pragma protect key_method = "rsa"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 128)
`pragma protect key_block
qoi2KpsJZxm+nAc1OeuMv9ECR+cQUaIXpXiIj2M/RqwPdEZyFO2y80lKJoPimQLx
xGPTxTJdSYxQHD4wSl+f3DDRddNF1/oRBYjtIE6PeoUQXyYm6claxwgkYx9onOeV
B/I/wqnTgHWpkq//WiyRfc5vSze9xrlaAjeupO3z1tQ=
`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 64, bytes = 4496)
`pragma protect data_block
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
`pragma protect end_protected	