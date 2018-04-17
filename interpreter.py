#!/usr/bin/env python3

import os
import sys
import argparse

ip = 0							# Instruction pointer
reg = [0 for x in range(16)]	# Registers
reg_map = { "R0": 0, "R1": 1, "R2": 2, "R3": 3}
mem = [0 for x in range(1024)]	# Data memory

def get_reg(string_reg):
	global reg
	index = reg_map[string_reg]
	return reg[index]

def set_reg(string_reg, val):
	global reg
	index = reg_map[string_reg]
	reg[index] = val

def debug(instrs):
	print(reg)
	print(mem)
	i = instrs[ip]
	(op, a, b, c) = i.split('\t')
	print(ip, ":", op, a, b, c)

def process(instrs):
	global ip
#	instr = instr.replace('\n', '')
	i = instrs[ip]
	(op, a, b, c) = i.split('\t')
	
	if op == "JMP":
		a = int(a)
		ip += a
	elif op == "JMPC" and get_reg(b) == 0:
		a = int(a)
		ip += a
	elif op == "AFC":
		b = int(b)
		set_reg(a, b)
	elif op == "LOAD":
		b = int(b)
		set_reg(a, mem[b])
	elif op == "STORE":
		a = int(a)
		mem[a] = get_reg(b)
	elif op == "EQU":
		val = 1 if get_reg(b) == get_reg(c) else 0
		set_reg(a, val)
	elif op == "INF":
		val = 1 if get_reg(b) < get_reg(c) else 0
		set_reg(a, val)
	elif op == "INFE":
		val = 1 if get_reg(b) <= get_reg(c) else 0
		set_reg(a, val)
	elif op == "SUP":
		val = 1 if get_reg(b) > get_reg(c) else 0
		set_reg(a, val)
	elif op == "SUPE":
		val = 1 if get_reg(b) >= get_reg(c) else 0
		set_reg(a, val)
	debug(instrs)
	ip += 1

def main():
	if len(sys.argv) < 2:
		print("Missing arguments")
		exit(1)
	
	# Open assembly source
	filename = sys.argv[1]
	f = open(filename)
	instrs = f.read().split('\n')
	# Debug
	cnt = 0
	for i in instrs:
		print(cnt, ":", i)
		cnt += 1
	print('\n\n')
	
	# Process instructions
	instr_count = len(instrs)
	
	while ip < instr_count:
		process(instrs)
	
	f.close()
	sys.exit(0)

if __name__ == '__main__':
	main()
