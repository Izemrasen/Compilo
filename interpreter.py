#!/usr/bin/env python3

import os
import sys
import argparse

debug = True

ip = 0								# Instruction pointer
reg = dict(zip(						# Registers
 ['R' + str(x) for x in range(16)],
 [0 for x in range(16)]))
mem = [0 for i in range(1024)]		# Data memory

def handle_err(msg):
	msg = "Error (l. {}): {}".format(ip + 1, msg)
	print(msg)
	sys.exit(1)

def debug(i):
	#print(reg)
	#print(mem)
	print("{}:\t{}".format(ip, i))

def get_reg(str_reg):
	if str_reg in reg:
		return reg[str_reg]
	else:
		handle_err("Register doesn't exist")
		return None

def set_reg(str_reg, val):
	if str_reg in reg:
		reg[str_reg] = val
	else:
		handle_err("Register doesn't exist")

def process(instrs):
	global ip
	i = instrs[ip]
	
	# Handle mssing arguments
	try:
		i = i.split('\t')
		op = i[0]
		a = i[1]
		b = i[2]
		c = i[3]
	except IndexError:
		#print("Warning (l. %d): Possibly missing arguments" % ip)
		pass
	
	# Process instructions
	if debug:
		debug(instrs[ip])
	if op[:1] == '#':	# Comments
		pass
	elif op == 'JMP':
		a = int(a)
		ip += a
	elif op == 'JMPC':
		if get_reg(b) == 0:
			a = int(a)
			ip += a
		else:
			pass
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
	elif op == 'ADD':
		val1 = get_reg(b)
		val2 = get_reg(c)
		set_reg(a, int(val1 + val2))
	elif op == 'MUL':
		val1 = get_reg(b)
		val2 = get_reg(c)
		set_reg(a, int(val1 * val2))
	elif op == 'SOU':
		val1 = get_reg(b)
		val2 = get_reg(c)
		set_reg(a, int(val1 - val2))
	elif op == 'DIV':
		val1 = get_reg(b)
		val2 = get_reg(c)
		set_reg(a, int(val1 / val2))
	elif op == 'PRINT':	# Easter egg
		char_ptr = int(a)
		byte = mem[char_ptr]
		while byte != 0:
			byte = mem[char_ptr]
			print(chr(byte), end='', flush=True)
			char_ptr += 1
			byte = mem[char_ptr]
	else:
		handle_err("Unknown instruction")
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
	
	#debug(instrs)
	
	f.close()
	sys.exit(0)

if __name__ == '__main__':
	main()
