#!/usr/bin/env python3

import os
import sys
import argparse

ip = 0								# Instruction pointer
reg = dict(zip(						# Registers
 ['R' + str(x) for x in range(16)],
 [0 for x in range(16)]))
mem = [0 for i in range(1024)]		# Data memory

def get_reg(str_reg):
	return reg[str_reg]

def set_reg(str_reg, val):
	reg[str_reg] = val

def debug(instrs):
	print(reg)
	#print(mem)
	#print(instrs[ip])

def process(instrs):
	global ip
	i = instrs[ip]
	
	# Handle mssing arguments
	try:
		s = i.split('\t', maxsplit=4)
		op = s[0]
		a = s[1]
		b = s[2]
		c = s[3]
	except IndexError:
		#print("Warning on l. %d: Possibly missing arguments" % ip)
		pass
	
	# Process instructions
	if op[:1] == '#':	# Comments
		pass
	elif op == 'JMP':
		a = int(a)
		ip += a
	elif op == 'JMPC' and get_reg(b) == 0:
		a = int(a)
		ip += a
	elif op == 'AFC':
		b = int(b)
		set_reg(a, b)
	elif op == 'LOAD':
		b = int(b)
		set_reg(a, mem[b])
	elif op == 'STORE':
		a = int(a)
		mem[a] = get_reg(b)
	elif op == 'EQU':
		val = 1 if get_reg(b) == get_reg(c) else 0
		set_reg(a, val)
	elif op == 'INF':
		val = 1 if get_reg(b) < get_reg(c) else 0
		set_reg(a, val)
	elif op == 'INFE':
		val = 1 if get_reg(b) <= get_reg(c) else 0
		set_reg(a, val)
	elif op == 'SUP':
		val = 1 if get_reg(b) > get_reg(c) else 0
		set_reg(a, val)
	elif op == 'SUPE':
		val = 1 if get_reg(b) >= get_reg(c) else 0
		set_reg(a, val)
	elif op == 'PRINT':	# Easter egg
		char_ptr = int(a)
		byte = mem[char_ptr]
		while byte != 0:
			byte = mem[char_ptr]
			print(chr(byte), end='', flush=True)
			char_ptr += 1
			byte = mem[char_ptr]
	#debug(instrs)
	ip += 1

def main():
	if len(sys.argv) < 2:
		print("Missing arguments")
		sys.exit(1)
	
	# Open assembly source
	filename = sys.argv[1]
	f = open(filename)
	instrs = f.read().split('\n')
	
	# Process instructions
	instr_count = len(instrs)
	while ip < instr_count:
		process(instrs)
	
	debug(instrs)
	
	f.close()
	sys.exit(0)

if __name__ == '__main__':
	main()
