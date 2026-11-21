00000000004018b0 <batch(void (*)(unsigned int*, unsigned int const*, unsigned long), unsigned long)>:
  4018b0:	55                   	push   rbp
  4018b1:	41 57                	push   r15
  4018b3:	41 56                	push   r14
  4018b5:	53                   	push   rbx
  4018b6:	50                   	push   rax
  4018b7:	49 89 f6             	mov    r14,rsi
  4018ba:	49 89 ff             	mov    r15,rdi
  4018bd:	bd 20 a1 07 00       	mov    ebp,0x7a120
  4018c2:	e8 89 f7 ff ff       	call   401050 <std::chrono::_V2::steady_clock::now()@plt>
  4018c7:	48 89 c3             	mov    rbx,rax
  4018ca:	66 0f 1f 44 00 00    	nop    WORD PTR [rax+rax*1+0x0]
  4018d0:	bf 80 42 40 00       	mov    edi,0x404280
  4018d5:	be 80 40 40 00       	mov    esi,0x404080
  4018da:	4c 89 f2             	mov    rdx,r14
  4018dd:	41 ff d7             	call   r15
  4018e0:	ff cd                	dec    ebp
  4018e2:	75 ec                	jne    4018d0 <batch(void (*)(unsigned int*, unsigned int const*, unsigned long), unsigned long)+0x20>
  4018e4:	e8 67 f7 ff ff       	call   401050 <std::chrono::_V2::steady_clock::now()@plt>
  4018e9:	48 29 d8             	sub    rax,rbx
  4018ec:	48 83 c4 08          	add    rsp,0x8
  4018f0:	5b                   	pop    rbx
  4018f1:	41 5e                	pop    r14
  4018f3:	41 5f                	pop    r15
  4018f5:	5d                   	pop    rbp
  4018f6:	c3                   	ret
  4018f7:	66 0f 1f 84 00 00 00 	nop    WORD PTR [rax+rax*1+0x0]
  4018fe:	00 00 

0000000000401900 <ordinary>:
  401900:	48 85 d2             	test   rdx,rdx
  401903:	0f 84 5e 01 00 00    	je     401a67 <ordinary+0x167>
  401909:	48 83 fa 04          	cmp    rdx,0x4
  40190d:	48 89 f9             	mov    rcx,rdi
  401910:	0f 93 c0             	setae  al
  401913:	48 29 f1             	sub    rcx,rsi
  401916:	48 83 f9 7f          	cmp    rcx,0x7f
  40191a:	0f 97 c1             	seta   cl
  40191d:	84 c8                	test   al,cl
  40191f:	75 07                	jne    401928 <ordinary+0x28>
  401921:	31 c0                	xor    eax,eax
  401923:	e9 a8 00 00 00       	jmp    4019d0 <ordinary+0xd0>
  401928:	48 83 fa 20          	cmp    rdx,0x20
  40192c:	73 04                	jae    401932 <ordinary+0x32>
  40192e:	31 c0                	xor    eax,eax
  401930:	eb 63                	jmp    401995 <ordinary+0x95>
  401932:	c4 e2 7d 58 05 d1 06 	vpbroadcastd ymm0,DWORD PTR [rip+0x6d1]        # 40200c <_IO_stdin_used+0xc>
  401939:	00 00 
  40193b:	48 89 d0             	mov    rax,rdx
  40193e:	48 83 e0 e0          	and    rax,0xffffffffffffffe0
  401942:	31 c9                	xor    ecx,ecx
  401944:	66 66 66 2e 0f 1f 84 	data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  40194b:	00 00 00 00 00 
  401950:	c5 fd fe 0c 8e       	vpaddd ymm1,ymm0,YMMWORD PTR [rsi+rcx*4]
  401955:	c5 fd fe 54 8e 20    	vpaddd ymm2,ymm0,YMMWORD PTR [rsi+rcx*4+0x20]
  40195b:	c5 fd fe 5c 8e 40    	vpaddd ymm3,ymm0,YMMWORD PTR [rsi+rcx*4+0x40]
  401961:	c5 fd fe 64 8e 60    	vpaddd ymm4,ymm0,YMMWORD PTR [rsi+rcx*4+0x60]
  401967:	c5 fe 7f 0c 8f       	vmovdqu YMMWORD PTR [rdi+rcx*4],ymm1
  40196c:	c5 fe 7f 54 8f 20    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x20],ymm2
  401972:	c5 fe 7f 5c 8f 40    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x40],ymm3
  401978:	c5 fe 7f 64 8f 60    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x60],ymm4
  40197e:	48 83 c1 20          	add    rcx,0x20
  401982:	48 39 c8             	cmp    rax,rcx
  401985:	75 c9                	jne    401950 <ordinary+0x50>
  401987:	48 39 c2             	cmp    rdx,rax
  40198a:	0f 84 d7 00 00 00    	je     401a67 <ordinary+0x167>
  401990:	f6 c2 1c             	test   dl,0x1c
  401993:	74 3b                	je     4019d0 <ordinary+0xd0>
  401995:	48 89 c1             	mov    rcx,rax
  401998:	48 89 d0             	mov    rax,rdx
  40199b:	48 83 e0 fc          	and    rax,0xfffffffffffffffc
  40199f:	c5 f9 76 c0          	vpcmpeqd xmm0,xmm0,xmm0
  4019a3:	66 66 66 66 2e 0f 1f 	data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  4019aa:	84 00 00 00 00 00 
  4019b0:	c5 fa 6f 0c 8e       	vmovdqu xmm1,XMMWORD PTR [rsi+rcx*4]
  4019b5:	c5 f1 fa c8          	vpsubd xmm1,xmm1,xmm0
  4019b9:	c5 fa 7f 0c 8f       	vmovdqu XMMWORD PTR [rdi+rcx*4],xmm1
  4019be:	48 83 c1 04          	add    rcx,0x4
  4019c2:	48 39 c8             	cmp    rax,rcx
  4019c5:	75 e9                	jne    4019b0 <ordinary+0xb0>
  4019c7:	48 39 c2             	cmp    rdx,rax
  4019ca:	0f 84 97 00 00 00    	je     401a67 <ordinary+0x167>
  4019d0:	41 89 d0             	mov    r8d,edx
  4019d3:	41 29 c0             	sub    r8d,eax
  4019d6:	48 89 c1             	mov    rcx,rax
  4019d9:	41 83 e0 07          	and    r8d,0x7
  4019dd:	74 24                	je     401a03 <ordinary+0x103>
  4019df:	48 89 c1             	mov    rcx,rax
  4019e2:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  4019e9:	1f 84 00 00 00 00 00 
  4019f0:	44 8b 0c 8e          	mov    r9d,DWORD PTR [rsi+rcx*4]
  4019f4:	41 ff c1             	inc    r9d
  4019f7:	44 89 0c 8f          	mov    DWORD PTR [rdi+rcx*4],r9d
  4019fb:	48 ff c1             	inc    rcx
  4019fe:	49 ff c8             	dec    r8
  401a01:	75 ed                	jne    4019f0 <ordinary+0xf0>
  401a03:	48 29 d0             	sub    rax,rdx
  401a06:	48 83 f8 f8          	cmp    rax,0xfffffffffffffff8
  401a0a:	77 5b                	ja     401a67 <ordinary+0x167>
  401a0c:	0f 1f 40 00          	nop    DWORD PTR [rax+0x0]
  401a10:	8b 04 8e             	mov    eax,DWORD PTR [rsi+rcx*4]
  401a13:	ff c0                	inc    eax
  401a15:	89 04 8f             	mov    DWORD PTR [rdi+rcx*4],eax
  401a18:	8b 44 8e 04          	mov    eax,DWORD PTR [rsi+rcx*4+0x4]
  401a1c:	ff c0                	inc    eax
  401a1e:	89 44 8f 04          	mov    DWORD PTR [rdi+rcx*4+0x4],eax
  401a22:	8b 44 8e 08          	mov    eax,DWORD PTR [rsi+rcx*4+0x8]
  401a26:	ff c0                	inc    eax
  401a28:	89 44 8f 08          	mov    DWORD PTR [rdi+rcx*4+0x8],eax
  401a2c:	8b 44 8e 0c          	mov    eax,DWORD PTR [rsi+rcx*4+0xc]
  401a30:	ff c0                	inc    eax
  401a32:	89 44 8f 0c          	mov    DWORD PTR [rdi+rcx*4+0xc],eax
  401a36:	8b 44 8e 10          	mov    eax,DWORD PTR [rsi+rcx*4+0x10]
  401a3a:	ff c0                	inc    eax
  401a3c:	89 44 8f 10          	mov    DWORD PTR [rdi+rcx*4+0x10],eax
  401a40:	8b 44 8e 14          	mov    eax,DWORD PTR [rsi+rcx*4+0x14]
  401a44:	ff c0                	inc    eax
  401a46:	89 44 8f 14          	mov    DWORD PTR [rdi+rcx*4+0x14],eax
  401a4a:	8b 44 8e 18          	mov    eax,DWORD PTR [rsi+rcx*4+0x18]
  401a4e:	ff c0                	inc    eax
  401a50:	89 44 8f 18          	mov    DWORD PTR [rdi+rcx*4+0x18],eax
  401a54:	8b 44 8e 1c          	mov    eax,DWORD PTR [rsi+rcx*4+0x1c]
  401a58:	ff c0                	inc    eax
  401a5a:	89 44 8f 1c          	mov    DWORD PTR [rdi+rcx*4+0x1c],eax
  401a5e:	48 83 c1 08          	add    rcx,0x8
  401a62:	48 39 ca             	cmp    rdx,rcx
  401a65:	75 a9                	jne    401a10 <ordinary+0x110>
  401a67:	c5 f8 77             	vzeroupper
  401a6a:	c3                   	ret
  401a6b:	0f 1f 44 00 00       	nop    DWORD PTR [rax+rax*1+0x0]

0000000000401a70 <restricted>:
  401a70:	48 85 d2             	test   rdx,rdx
  401a73:	0f 84 b0 00 00 00    	je     401b29 <restricted+0xb9>
  401a79:	48 83 fa 03          	cmp    rdx,0x3
  401a7d:	77 07                	ja     401a86 <restricted+0x16>
  401a7f:	31 c0                	xor    eax,eax
  401a81:	e9 93 00 00 00       	jmp    401b19 <restricted+0xa9>
  401a86:	48 83 fa 20          	cmp    rdx,0x20
  401a8a:	73 04                	jae    401a90 <restricted+0x20>
  401a8c:	31 c0                	xor    eax,eax
  401a8e:	eb 61                	jmp    401af1 <restricted+0x81>
  401a90:	c4 e2 7d 58 05 73 05 	vpbroadcastd ymm0,DWORD PTR [rip+0x573]        # 40200c <_IO_stdin_used+0xc>
  401a97:	00 00 
  401a99:	48 89 d0             	mov    rax,rdx
  401a9c:	48 83 e0 e0          	and    rax,0xffffffffffffffe0
  401aa0:	31 c9                	xor    ecx,ecx
  401aa2:	66 66 66 66 66 2e 0f 	data16 data16 data16 data16 cs nop WORD PTR [rax+rax*1+0x0]
  401aa9:	1f 84 00 00 00 00 00 
  401ab0:	c5 fd fe 0c 8e       	vpaddd ymm1,ymm0,YMMWORD PTR [rsi+rcx*4]
  401ab5:	c5 fd fe 54 8e 20    	vpaddd ymm2,ymm0,YMMWORD PTR [rsi+rcx*4+0x20]
  401abb:	c5 fd fe 5c 8e 40    	vpaddd ymm3,ymm0,YMMWORD PTR [rsi+rcx*4+0x40]
  401ac1:	c5 fd fe 64 8e 60    	vpaddd ymm4,ymm0,YMMWORD PTR [rsi+rcx*4+0x60]
  401ac7:	c5 fe 7f 0c 8f       	vmovdqu YMMWORD PTR [rdi+rcx*4],ymm1
  401acc:	c5 fe 7f 54 8f 20    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x20],ymm2
  401ad2:	c5 fe 7f 5c 8f 40    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x40],ymm3
  401ad8:	c5 fe 7f 64 8f 60    	vmovdqu YMMWORD PTR [rdi+rcx*4+0x60],ymm4
  401ade:	48 83 c1 20          	add    rcx,0x20
  401ae2:	48 39 c8             	cmp    rax,rcx
  401ae5:	75 c9                	jne    401ab0 <restricted+0x40>
  401ae7:	48 39 c2             	cmp    rdx,rax
  401aea:	74 3d                	je     401b29 <restricted+0xb9>
  401aec:	f6 c2 1c             	test   dl,0x1c
  401aef:	74 28                	je     401b19 <restricted+0xa9>
  401af1:	48 89 c1             	mov    rcx,rax
  401af4:	48 89 d0             	mov    rax,rdx
  401af7:	48 83 e0 fc          	and    rax,0xfffffffffffffffc
  401afb:	c5 f9 76 c0          	vpcmpeqd xmm0,xmm0,xmm0
  401aff:	90                   	nop
  401b00:	c5 fa 6f 0c 8e       	vmovdqu xmm1,XMMWORD PTR [rsi+rcx*4]
  401b05:	c5 f1 fa c8          	vpsubd xmm1,xmm1,xmm0
  401b09:	c5 fa 7f 0c 8f       	vmovdqu XMMWORD PTR [rdi+rcx*4],xmm1
  401b0e:	48 83 c1 04          	add    rcx,0x4
  401b12:	48 39 c8             	cmp    rax,rcx
  401b15:	75 e9                	jne    401b00 <restricted+0x90>
  401b17:	eb 0b                	jmp    401b24 <restricted+0xb4>
  401b19:	8b 0c 86             	mov    ecx,DWORD PTR [rsi+rax*4]
  401b1c:	ff c1                	inc    ecx
  401b1e:	89 0c 87             	mov    DWORD PTR [rdi+rax*4],ecx
  401b21:	48 ff c0             	inc    rax
  401b24:	48 39 c2             	cmp    rdx,rax
  401b27:	75 f0                	jne    401b19 <restricted+0xa9>
  401b29:	c5 f8 77             	vzeroupper
  401b2c:	c3                   	ret
