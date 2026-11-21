00000000004018c0 <batch(void (*)(unsigned int*, unsigned int const*, unsigned long), unsigned long)>:
  4018c0:	55                   	push   rbp
  4018c1:	41 57                	push   r15
  4018c3:	41 56                	push   r14
  4018c5:	53                   	push   rbx
  4018c6:	50                   	push   rax
  4018c7:	49 89 f6             	mov    r14,rsi
  4018ca:	49 89 ff             	mov    r15,rdi
  4018cd:	bd 20 a1 07 00       	mov    ebp,0x7a120
  4018d2:	e8 79 f7 ff ff       	call   401050 <std::chrono::_V2::steady_clock::now()@plt>
  4018d7:	48 89 c3             	mov    rbx,rax
  4018da:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4018e0:	bf 80 42 40 00       	mov    edi,0x404280
  4018e5:	be 80 40 40 00       	mov    esi,0x404080
  4018ea:	4c 89 f2             	mov    rdx,r14
  4018ed:	41 ff d7             	call   r15
  4018f0:	ff cd                	dec    ebp
  4018f2:	75 ec                	jne    4018e0 <batch(void (*)(unsigned int*, unsigned int const*, unsigned long), unsigned long)+0x20>
  4018f4:	e8 57 f7 ff ff       	call   401050 <std::chrono::_V2::steady_clock::now()@plt>
  4018f9:	48 29 d8             	sub    rax,rbx
  4018fc:	48 83 c4 08          	add    rsp,0x8
  401900:	5b                   	pop    rbx
  401901:	41 5e                	pop    r14
  401903:	41 5f                	pop    r15
  401905:	5d                   	pop    rbp
  401906:	c3                   	ret
  401907:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  40190e:	00 00 00
  401911:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  401918:	00 00 00
  40191b:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  401922:	00 00 00
  401925:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  40192c:	00 00 00
  40192f:	66 2e 0f 1f 84 00 00 	cs nop WORD PTR [rax+rax*1+0x0]
  401936:	00 00 00
  401939:	0f 1f 80 00 00 00 00 	nop    DWORD PTR [rax+0x0]

0000000000401940 <ordinary>:
  401940:	48 85 d2             	test   rdx,rdx
  401943:	0f 84 5e 01 00 00    	je     401aa7 <ordinary+0x167>
  401949:	48 83 fa 04          	cmp    rdx,0x4
  40194d:	48 89 f9             	mov    rcx,rdi
  401950:	0f 93 c0             	setae  al
  401953:	48 29 f1             	sub    rcx,rsi
  401956:	48 83 f9 7f          	cmp    rcx,0x7f
  40195a:	0f 97 c1             	seta   cl
  40195d:	84 c8                	test   al,cl
  40195f:	75 07                	jne    401968 <ordinary+0x28>
  401961:	31 c0                	xor    eax,eax
  401963:	e9 a8 00 00 00       	jmp    401a10 <ordinary+0xd0>
  401968:	48 83 fa 20          	cmp    rdx,0x20
  40196c:	73 04                	jae    401972 <ordinary+0x32>
  40196e:	31 c0                	xor    eax,eax
  401970:	eb 63                	jmp    4019d5 <ordinary+0x95>
  401972:	c4 e2 7d 58 05 91 06 	vpbroadcastd ymm0,DWORD PTR [rip+0x691]        # 40200c <_IO_stdin_used+0xc>
  401979:	00 00
  40197b:	48 89 d0             	mov    rax,rdx
  40197e:	48 83 e0 e0          	and    rax,0xffffffffffffffe0
  401982:	31 c9                	xor    ecx,ecx
  401984:	66 66 66 2e 0f 1f 84 	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  40198b:	00 00 00 00 00
  401990:	c5 fd fe 0c 8e       	vpaddd ymm1,ymm0,YMMWORD PTR [rsi+rcx*4]
  401995:	c5 fd fe 54 8e 20    	vpaddd ymm2,ymm0,YMMWORD PTR [rsi+rcx*4+0x20]
  40199b:	c5 fd fe 5c 8e 40    	vpaddd ymm3,ymm0,YMMWORD PTR [rsi+rcx*4+0x40]
  4019a1:	c5 fd fe 64 8e 60    	vpaddd ymm4,ymm0,YMMWORD PTR [rsi+rcx*4+0x60]
  4019a7:	c5 fe 7f 0c 8f       	vmovdqu YMMWORD PTR [rdi+rcx*4],ymm1
  4019ac:	c5 fe 7f 54 8f 20    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x20],ymm2
  4019b2:	c5 fe 7f 5c 8f 40    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x40],ymm3
  4019b8:	c5 fe 7f 64 8f 60    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x60],ymm4
  4019be:	48 83 c1 20          	add    rcx,0x20
  4019c2:	48 39 c8             	cmp    rax,rcx
  4019c5:	75 c9                	jne    401990 <ordinary+0x50>
  4019c7:	48 39 c2             	cmp    rdx,rax
  4019ca:	0f 84 d7 00 00 00    	je     401aa7 <ordinary+0x167>
  4019d0:	f6 c2 1c             	test   dl,0x1c
  4019d3:	74 3b                	je     401a10 <ordinary+0xd0>
  4019d5:	48 89 c1             	mov    rcx,rax
  4019d8:	48 89 d0             	mov    rax,rdx
  4019db:	48 83 e0 fc          	and    rax,0xfffffffffffffffc
  4019df:	c5 f9 76 c0          	vpcmpeqd xmm0,xmm0,xmm0
  4019e3:	66 66 66 66 2e 0f 1f 	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  4019ea:	84 00 00 00 00 00
  4019f0:	c5 fa 6f 0c 8e       	vmovdqu xmm1,XMMWORD PTR [rsi+rcx*4]
  4019f5:	c5 f1 fa c8          	vpsubd xmm1,xmm1,xmm0
  4019f9:	c5 fa 7f 0c 8f       	vmovdqu XMMWORD PTR [rdi+rcx*4],xmm1
  4019fe:	48 83 c1 04          	add    rcx,0x4
  401a02:	48 39 c8             	cmp    rax,rcx
  401a05:	75 e9                	jne    4019f0 <ordinary+0xb0>
  401a07:	48 39 c2             	cmp    rdx,rax
  401a0a:	0f 84 97 00 00 00    	je     401aa7 <ordinary+0x167>
  401a10:	41 89 d0             	mov    r8d,edx
  401a13:	41 29 c0             	sub    r8d,eax
  401a16:	48 89 c1             	mov    rcx,rax
  401a19:	41 83 e0 07          	and    r8d,0x7
  401a1d:	74 24                	je     401a43 <ordinary+0x103>
  401a1f:	48 89 c1             	mov    rcx,rax
  401a22:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  401a29:	1f 84 00 00 00 00 00
  401a30:	44 8b 0c 8e          	mov    r9d,DWORD PTR [rsi+rcx*4]
  401a34:	41 ff c1             	inc    r9d
  401a37:	44 89 0c 8f          	mov    DWORD PTR [rdi+rcx*4],r9d
  401a3b:	48 ff c1             	inc    rcx
  401a3e:	49 ff c8             	dec    r8
  401a41:	75 ed                	jne    401a30 <ordinary+0xf0>
  401a43:	48 29 d0             	sub    rax,rdx
  401a46:	48 83 f8 f8          	cmp    rax,0xfffffffffffffff8
  401a4a:	77 5b                	ja     401aa7 <ordinary+0x167>
  401a4c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  401a50:	8b 04 8e             	mov    eax,DWORD PTR [rsi+rcx*4]
  401a53:	ff c0                	inc    eax
  401a55:	89 04 8f             	mov    DWORD PTR [rdi+rcx*4],eax
  401a58:	8b 44 8e 04          	mov    eax,DWORD PTR [rsi+rcx*4+0x4]
  401a5c:	ff c0                	inc    eax
  401a5e:	89 44 8f 04          	mov    DWORD PTR [rdi+rcx*4+0x4],eax
  401a62:	8b 44 8e 08          	mov    eax,DWORD PTR [rsi+rcx*4+0x8]
  401a66:	ff c0                	inc    eax
  401a68:	89 44 8f 08          	mov    DWORD PTR [rdi+rcx*4+0x8],eax
  401a6c:	8b 44 8e 0c          	mov    eax,DWORD PTR [rsi+rcx*4+0xc]
  401a70:	ff c0                	inc    eax
  401a72:	89 44 8f 0c          	mov    DWORD PTR [rdi+rcx*4+0xc],eax
  401a76:	8b 44 8e 10          	mov    eax,DWORD PTR [rsi+rcx*4+0x10]
  401a7a:	ff c0                	inc    eax
  401a7c:	89 44 8f 10          	mov    DWORD PTR [rdi+rcx*4+0x10],eax
  401a80:	8b 44 8e 14          	mov    eax,DWORD PTR [rsi+rcx*4+0x14]
  401a84:	ff c0                	inc    eax
  401a86:	89 44 8f 14          	mov    DWORD PTR [rdi+rcx*4+0x14],eax
  401a8a:	8b 44 8e 18          	mov    eax,DWORD PTR [rsi+rcx*4+0x18]
  401a8e:	ff c0                	inc    eax
  401a90:	89 44 8f 18          	mov    DWORD PTR [rdi+rcx*4+0x18],eax
  401a94:	8b 44 8e 1c          	mov    eax,DWORD PTR [rsi+rcx*4+0x1c]
  401a98:	ff c0                	inc    eax
  401a9a:	89 44 8f 1c          	mov    DWORD PTR [rdi+rcx*4+0x1c],eax
  401a9e:	48 83 c1 08          	add    rcx,0x8
  401aa2:	48 39 ca             	cmp    rdx,rcx
  401aa5:	75 a9                	jne    401a50 <ordinary+0x110>
  401aa7:	c5 f8 77             	vzeroupper
  401aaa:	c3                   	ret
  401aab:	66 66 66 66 66 66 2e 	data16 data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  401ab2:	0f 1f 84 00 00 00 00
  401ab9:	00
  401aba:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]

0000000000401ac0 <restricted>:
  401ac0:	48 85 d2             	test   rdx,rdx
  401ac3:	0f 84 b0 00 00 00    	je     401b79 <restricted+0xb9>
  401ac9:	48 83 fa 03          	cmp    rdx,0x3
  401acd:	77 07                	ja     401ad6 <restricted+0x16>
  401acf:	31 c0                	xor    eax,eax
  401ad1:	e9 93 00 00 00       	jmp    401b69 <restricted+0xa9>
  401ad6:	48 83 fa 20          	cmp    rdx,0x20
  401ada:	73 04                	jae    401ae0 <restricted+0x20>
  401adc:	31 c0                	xor    eax,eax
  401ade:	eb 61                	jmp    401b41 <restricted+0x81>
  401ae0:	c4 e2 7d 58 05 23 05 	vpbroadcastd ymm0,DWORD PTR [rip+0x523]        # 40200c <_IO_stdin_used+0xc>
  401ae7:	00 00
  401ae9:	48 89 d0             	mov    rax,rdx
  401aec:	48 83 e0 e0          	and    rax,0xffffffffffffffe0
  401af0:	31 c9                	xor    ecx,ecx
  401af2:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  401af9:	1f 84 00 00 00 00 00
  401b00:	c5 fd fe 0c 8e       	vpaddd ymm1,ymm0,YMMWORD PTR [rsi+rcx*4]
  401b05:	c5 fd fe 54 8e 20    	vpaddd ymm2,ymm0,YMMWORD PTR [rsi+rcx*4+0x20]
  401b0b:	c5 fd fe 5c 8e 40    	vpaddd ymm3,ymm0,YMMWORD PTR [rsi+rcx*4+0x40]
  401b11:	c5 fd fe 64 8e 60    	vpaddd ymm4,ymm0,YMMWORD PTR [rsi+rcx*4+0x60]
  401b17:	c5 fe 7f 0c 8f       	vmovdqu YMMWORD PTR [rdi+rcx*4],ymm1
  401b1c:	c5 fe 7f 54 8f 20    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x20],ymm2
  401b22:	c5 fe 7f 5c 8f 40    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x40],ymm3
  401b28:	c5 fe 7f 64 8f 60    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x60],ymm4
  401b2e:	48 83 c1 20          	add    rcx,0x20
  401b32:	48 39 c8             	cmp    rax,rcx
  401b35:	75 c9                	jne    401b00 <restricted+0x40>
  401b37:	48 39 c2             	cmp    rdx,rax
  401b3a:	74 3d                	je     401b79 <restricted+0xb9>
  401b3c:	f6 c2 1c             	test   dl,0x1c
  401b3f:	74 28                	je     401b69 <restricted+0xa9>
  401b41:	48 89 c1             	mov    rcx,rax
  401b44:	48 89 d0             	mov    rax,rdx
  401b47:	48 83 e0 fc          	and    rax,0xfffffffffffffffc
  401b4b:	c5 f9 76 c0          	vpcmpeqd xmm0,xmm0,xmm0
  401b4f:	90                   	nop
  401b50:	c5 fa 6f 0c 8e       	vmovdqu xmm1,XMMWORD PTR [rsi+rcx*4]
  401b55:	c5 f1 fa c8          	vpsubd xmm1,xmm1,xmm0
  401b59:	c5 fa 7f 0c 8f       	vmovdqu XMMWORD PTR [rdi+rcx*4],xmm1
  401b5e:	48 83 c1 04          	add    rcx,0x4
  401b62:	48 39 c8             	cmp    rax,rcx
  401b65:	75 e9                	jne    401b50 <restricted+0x90>
  401b67:	eb 0b                	jmp    401b74 <restricted+0xb4>
  401b69:	8b 0c 86             	mov    ecx,DWORD PTR [rsi+rax*4]
  401b6c:	ff c1                	inc    ecx
  401b6e:	89 0c 87             	mov    DWORD PTR [rdi+rax*4],ecx
  401b71:	48 ff c0             	inc    rax
  401b74:	48 39 c2             	cmp    rdx,rax
  401b77:	75 f0                	jne    401b69 <restricted+0xa9>
  401b79:	c5 f8 77             	vzeroupper
  401b7c:	c3                   	ret
