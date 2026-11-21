	.intel_syntax noprefix
	.file	"copy_add.cpp"
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0                          # -- Begin function ordinary
.LCPI0_0:
	.long	1                               # 0x1
	.text
	.globl	ordinary
	.p2align	4
	.type	ordinary,@function
ordinary:                               # @ordinary
.Lfunc_begin0:
	.cfi_startproc
# %bb.0:
	.file	1 "." "copy_add.cpp"
	.loc	1 5 31 prologue_end             # copy_add.cpp:5:31
	test	rdx, rdx
	.loc	1 5 5 is_stmt 0                 # copy_add.cpp:5:5
	je	.LBB0_17
# %bb.1:
	cmp	rdx, 4
	mov	rcx, rdi
	setae	al
	sub	rcx, rsi
	cmp	rcx, 127
	seta	cl
	test	al, cl
	jne	.LBB0_8
# %bb.2:
	.loc	1 0 5                           # copy_add.cpp:0:5
	xor	eax, eax
	jmp	.LBB0_3
.LBB0_8:
	.loc	1 5 5                           # copy_add.cpp:5:5
	cmp	rdx, 32
	jae	.LBB0_10
# %bb.9:
	.loc	1 0 5                           # copy_add.cpp:0:5
	xor	eax, eax
	.loc	1 5 5                           # copy_add.cpp:5:5
	jmp	.LBB0_14
.LBB0_10:
	.loc	1 0 5                           # copy_add.cpp:0:5
	vpbroadcastd	ymm0, dword ptr [rip + .LCPI0_0] # ymm0 = [1,1,1,1,1,1,1,1]
	.loc	1 5 5                           # copy_add.cpp:5:5
	mov	rax, rdx
	and	rax, -32
	xor	ecx, ecx
	.loc	1 0 5                           # :0:5
.Ltmp0:
	.p2align	4
.LBB0_11:                               # =>This Inner Loop Header: Depth=1
	.loc	1 6 25 is_stmt 1                # copy_add.cpp:6:25
	vpaddd	ymm1, ymm0, ymmword ptr [rsi + 4*rcx]
	vpaddd	ymm2, ymm0, ymmword ptr [rsi + 4*rcx + 32]
	vpaddd	ymm3, ymm0, ymmword ptr [rsi + 4*rcx + 64]
	vpaddd	ymm4, ymm0, ymmword ptr [rsi + 4*rcx + 96]
	.loc	1 6 16 is_stmt 0                # copy_add.cpp:6:16
	vmovdqu	ymmword ptr [rdi + 4*rcx], ymm1
	vmovdqu	ymmword ptr [rdi + 4*rcx + 32], ymm2
	vmovdqu	ymmword ptr [rdi + 4*rcx + 64], ymm3
	vmovdqu	ymmword ptr [rdi + 4*rcx + 96], ymm4
	.loc	1 5 36 is_stmt 1                # copy_add.cpp:5:36
	add	rcx, 32
	cmp	rax, rcx
	jne	.LBB0_11
# %bb.12:
	.loc	1 5 5 is_stmt 0                 # copy_add.cpp:5:5
	cmp	rdx, rax
	je	.LBB0_17
# %bb.13:
	test	dl, 28
	je	.LBB0_3
.LBB0_14:
	.loc	1 0 5                           # copy_add.cpp:0:5
	mov	rcx, rax
	.loc	1 5 5                           # copy_add.cpp:5:5
	mov	rax, rdx
	and	rax, -4
	vpcmpeqd	xmm0, xmm0, xmm0
	.loc	1 0 5                           # :0:5
.Ltmp1:
	.p2align	4
.LBB0_15:                               # =>This Inner Loop Header: Depth=1
	.loc	1 6 18 is_stmt 1                # copy_add.cpp:6:18
	vmovdqu	xmm1, xmmword ptr [rsi + 4*rcx]
	.loc	1 6 25 is_stmt 0                # copy_add.cpp:6:25
	vpsubd	xmm1, xmm1, xmm0
	.loc	1 6 16                          # copy_add.cpp:6:16
	vmovdqu	xmmword ptr [rdi + 4*rcx], xmm1
	.loc	1 5 36 is_stmt 1                # copy_add.cpp:5:36
	add	rcx, 4
	cmp	rax, rcx
	jne	.LBB0_15
# %bb.16:
	.loc	1 5 5 is_stmt 0                 # copy_add.cpp:5:5
	cmp	rdx, rax
	je	.LBB0_17
.LBB0_3:
	.loc	1 5 5 is_stmt 1                 # copy_add.cpp:5:5
	mov	r8d, edx
	sub	r8d, eax
	mov	rcx, rax
	and	r8d, 7
	je	.LBB0_6
# %bb.4:
	.loc	1 0 5 is_stmt 0                 # copy_add.cpp:0:5
	mov	rcx, rax
	.p2align	4
.LBB0_5:                                # =>This Inner Loop Header: Depth=1
	.loc	1 6 18 is_stmt 1                # copy_add.cpp:6:18
	mov	r9d, dword ptr [rsi + 4*rcx]
	.loc	1 6 25 is_stmt 0                # copy_add.cpp:6:25
	inc	r9d
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx], r9d
	.loc	1 5 36 is_stmt 1                # copy_add.cpp:5:36
	inc	rcx
	.loc	1 5 5 is_stmt 0                 # copy_add.cpp:5:5
	dec	r8
	jne	.LBB0_5
.LBB0_6:
	sub	rax, rdx
	cmp	rax, -8
	ja	.LBB0_17
	.loc	1 0 5                           # :0:5
.Ltmp2:
	.p2align	4
.LBB0_7:                                # =>This Inner Loop Header: Depth=1
	.loc	1 6 18 is_stmt 1                # copy_add.cpp:6:18
	mov	eax, dword ptr [rsi + 4*rcx]
	.loc	1 6 25 is_stmt 0                # copy_add.cpp:6:25
	inc	eax
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx], eax
	.loc	1 6 18                          # copy_add.cpp:6:18
	mov	eax, dword ptr [rsi + 4*rcx + 4]
	.loc	1 6 25                          # copy_add.cpp:6:25
	inc	eax
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx + 4], eax
	.loc	1 6 18                          # copy_add.cpp:6:18
	mov	eax, dword ptr [rsi + 4*rcx + 8]
	.loc	1 6 25                          # copy_add.cpp:6:25
	inc	eax
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx + 8], eax
	.loc	1 6 18                          # copy_add.cpp:6:18
	mov	eax, dword ptr [rsi + 4*rcx + 12]
	.loc	1 6 25                          # copy_add.cpp:6:25
	inc	eax
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx + 12], eax
	.loc	1 6 18                          # copy_add.cpp:6:18
	mov	eax, dword ptr [rsi + 4*rcx + 16]
	.loc	1 6 25                          # copy_add.cpp:6:25
	inc	eax
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx + 16], eax
	.loc	1 6 18                          # copy_add.cpp:6:18
	mov	eax, dword ptr [rsi + 4*rcx + 20]
	.loc	1 6 25                          # copy_add.cpp:6:25
	inc	eax
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx + 20], eax
	.loc	1 6 18                          # copy_add.cpp:6:18
	mov	eax, dword ptr [rsi + 4*rcx + 24]
	.loc	1 6 25                          # copy_add.cpp:6:25
	inc	eax
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx + 24], eax
	.loc	1 6 18                          # copy_add.cpp:6:18
	mov	eax, dword ptr [rsi + 4*rcx + 28]
	.loc	1 6 25                          # copy_add.cpp:6:25
	inc	eax
	.loc	1 6 16                          # copy_add.cpp:6:16
	mov	dword ptr [rdi + 4*rcx + 28], eax
	.loc	1 5 36 is_stmt 1                # copy_add.cpp:5:36
	add	rcx, 8
	.loc	1 5 31 is_stmt 0                # copy_add.cpp:5:31
	cmp	rdx, rcx
	jne	.LBB0_7
.LBB0_17:
	.loc	1 7 1 is_stmt 1                 # copy_add.cpp:7:1
	vzeroupper
	ret
.Ltmp3:
.Lfunc_end0:
	.size	ordinary, .Lfunc_end0-ordinary
	.cfi_endproc
                                        # -- End function
	.section	.rodata.cst4,"aM",@progbits,4
	.p2align	2, 0x0                          # -- Begin function restricted
.LCPI1_0:
	.long	1                               # 0x1
	.text
	.globl	restricted
	.p2align	4
	.type	restricted,@function
restricted:                             # @restricted
.Lfunc_begin1:
	.cfi_startproc
# %bb.0:
	.loc	1 11 31 prologue_end            # copy_add.cpp:11:31
	test	rdx, rdx
	.loc	1 11 5 is_stmt 0                # copy_add.cpp:11:5
	je	.LBB1_13
# %bb.1:
	cmp	rdx, 3
	ja	.LBB1_4
# %bb.2:
	.loc	1 0 5                           # copy_add.cpp:0:5
	xor	eax, eax
	jmp	.LBB1_3
.LBB1_4:
	.loc	1 11 5                          # copy_add.cpp:11:5
	cmp	rdx, 32
	jae	.LBB1_6
# %bb.5:
	.loc	1 0 5                           # copy_add.cpp:0:5
	xor	eax, eax
	.loc	1 11 5                          # copy_add.cpp:11:5
	jmp	.LBB1_10
.LBB1_6:
	.loc	1 0 5                           # copy_add.cpp:0:5
	vpbroadcastd	ymm0, dword ptr [rip + .LCPI1_0] # ymm0 = [1,1,1,1,1,1,1,1]
	.loc	1 11 5                          # copy_add.cpp:11:5
	mov	rax, rdx
	and	rax, -32
	xor	ecx, ecx
	.loc	1 0 5                           # :0:5
.Ltmp4:
	.p2align	4
.LBB1_7:                                # =>This Inner Loop Header: Depth=1
	.loc	1 12 25 is_stmt 1               # copy_add.cpp:12:25
	vpaddd	ymm1, ymm0, ymmword ptr [rsi + 4*rcx]
	vpaddd	ymm2, ymm0, ymmword ptr [rsi + 4*rcx + 32]
	vpaddd	ymm3, ymm0, ymmword ptr [rsi + 4*rcx + 64]
	vpaddd	ymm4, ymm0, ymmword ptr [rsi + 4*rcx + 96]
	.loc	1 12 16 is_stmt 0               # copy_add.cpp:12:16
	vmovdqu	ymmword ptr [rdi + 4*rcx], ymm1
	vmovdqu	ymmword ptr [rdi + 4*rcx + 32], ymm2
	vmovdqu	ymmword ptr [rdi + 4*rcx + 64], ymm3
	vmovdqu	ymmword ptr [rdi + 4*rcx + 96], ymm4
	.loc	1 11 36 is_stmt 1               # copy_add.cpp:11:36
	add	rcx, 32
	cmp	rax, rcx
	jne	.LBB1_7
# %bb.8:
	.loc	1 11 5 is_stmt 0                # copy_add.cpp:11:5
	cmp	rdx, rax
	je	.LBB1_13
# %bb.9:
	test	dl, 28
	je	.LBB1_3
.LBB1_10:
	.loc	1 0 5                           # copy_add.cpp:0:5
	mov	rcx, rax
	.loc	1 11 5                          # copy_add.cpp:11:5
	mov	rax, rdx
	and	rax, -4
	vpcmpeqd	xmm0, xmm0, xmm0
	.loc	1 0 5                           # :0:5
.Ltmp5:
	.p2align	4
.LBB1_11:                               # =>This Inner Loop Header: Depth=1
	.loc	1 12 18 is_stmt 1               # copy_add.cpp:12:18
	vmovdqu	xmm1, xmmword ptr [rsi + 4*rcx]
	.loc	1 12 25 is_stmt 0               # copy_add.cpp:12:25
	vpsubd	xmm1, xmm1, xmm0
	.loc	1 12 16                         # copy_add.cpp:12:16
	vmovdqu	xmmword ptr [rdi + 4*rcx], xmm1
	.loc	1 11 36 is_stmt 1               # copy_add.cpp:11:36
	add	rcx, 4
	cmp	rax, rcx
	jne	.LBB1_11
	jmp	.LBB1_12
.LBB1_3:
	.loc	1 12 18                         # copy_add.cpp:12:18
	mov	ecx, dword ptr [rsi + 4*rax]
	.loc	1 12 25 is_stmt 0               # copy_add.cpp:12:25
	inc	ecx
	.loc	1 12 16                         # copy_add.cpp:12:16
	mov	dword ptr [rdi + 4*rax], ecx
	.loc	1 11 36 is_stmt 1               # copy_add.cpp:11:36
	inc	rax
.LBB1_12:
	.loc	1 11 0 is_stmt 0                # copy_add.cpp:11
	cmp	rdx, rax
	.loc	1 11 5                          # copy_add.cpp:11:5
	jne	.LBB1_3
.LBB1_13:
	.loc	1 13 1 is_stmt 1                # copy_add.cpp:13:1
	vzeroupper
	ret
.Ltmp6:
.Lfunc_end1:
	.size	restricted, .Lfunc_end1-restricted
	.cfi_endproc
                                        # -- End function
	.section	.debug_abbrev,"",@progbits
	.byte	1                               # Abbreviation Code
	.byte	17                              # DW_TAG_compile_unit
	.byte	0                               # DW_CHILDREN_no
	.byte	37                              # DW_AT_producer
	.byte	14                              # DW_FORM_strp
	.byte	19                              # DW_AT_language
	.byte	5                               # DW_FORM_data2
	.byte	3                               # DW_AT_name
	.byte	14                              # DW_FORM_strp
	.byte	16                              # DW_AT_stmt_list
	.byte	23                              # DW_FORM_sec_offset
	.byte	27                              # DW_AT_comp_dir
	.byte	14                              # DW_FORM_strp
	.byte	17                              # DW_AT_low_pc
	.byte	1                               # DW_FORM_addr
	.byte	18                              # DW_AT_high_pc
	.byte	6                               # DW_FORM_data4
	.byte	0                               # EOM(1)
	.byte	0                               # EOM(2)
	.byte	0                               # EOM(3)
	.section	.debug_info,"",@progbits
.Lcu_begin0:
	.long	.Ldebug_info_end0-.Ldebug_info_start0 # Length of Unit
.Ldebug_info_start0:
	.short	4                               # DWARF version number
	.long	.debug_abbrev                   # Offset Into Abbrev. Section
	.byte	8                               # Address Size (in bytes)
	.byte	1                               # Abbrev [1] 0xb:0x1f DW_TAG_compile_unit
	.long	.Linfo_string0                  # DW_AT_producer
	.short	33                              # DW_AT_language
	.long	.Linfo_string1                  # DW_AT_name
	.long	.Lline_table_start0             # DW_AT_stmt_list
	.long	.Linfo_string2                  # DW_AT_comp_dir
	.quad	.Lfunc_begin0                   # DW_AT_low_pc
	.long	.Lfunc_end1-.Lfunc_begin0       # DW_AT_high_pc
.Ldebug_info_end0:
	.section	.debug_str,"MS",@progbits,1
.Linfo_string0:
	.asciz	"Ubuntu clang version 21.1.8 (6ubuntu1)" # string offset=0
.Linfo_string1:
	.asciz	"copy_add.cpp"                  # string offset=39
.Linfo_string2:
	.asciz	"."                             # string offset=52
	.ident	"Ubuntu clang version 21.1.8 (6ubuntu1)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.section	.debug_line,"",@progbits
.Lline_table_start0:
