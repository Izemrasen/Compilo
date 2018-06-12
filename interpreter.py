#!/usr/bin/env python3

import os
import sys
import argparse


debug = False
binary = bytearray() # Buffer for binary code

ip = 0								# Instruction pointer
reg = dict(zip(						# Registers
 ['R' + str(x) for x in range(16)],
 [0 for x in range(16)]))
mem = [0 for i in range(1024)]		# Data memory


def handle_err(msg):
	msg = "Error (l. {}): {}".format(ip + 1, msg)
	print(msg)
	sys.exit(1)


def print_instr(i):
	print("{}:\t{}\t\t".format(ip, i), end='')



def print_mem():
	print(reg['R0'], reg['R1'], reg['R2'], '\t\t', end='')
	for i in range(0, 10):
		print(str(mem[i]) + " ", end='')
	print()

def get_reg(str_reg):
	if str_reg in reg:
		return reg[str_reg]
	else:
		handle_err("Register doesn't exist")
		return None

def get_reg_num(str_reg):
	return int(str_reg[1:])

def set_reg(str_reg, val):
	if str_reg in reg:
		reg[str_reg] = val
	else:
		handle_err("Register doesn't exist")

def pad(byte, max_len):
	return bytearray([byte]).rjust(max_len, b'\x00')

def gen_bin(instrs):
	global ip
	global binary
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
	if op[:1] == '#' or op[:1] == '\n' or op == '':	# Ignore
		pass
	elif op == 'ADD':
		binary.extend([0x01, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	elif op == 'MUL':
		binary.extend([0x02, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	elif op == 'SOU':
		binary.extend([0x03, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	elif op == 'DIV':
		binary.extend([0x04, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	# TODO: COP
	elif op == 'AFC':
		b = int(b)
		binary.extend([0x06, get_reg_num(a)])
		binary.extend(pad(b, 2))
	elif op == 'LOAD':
		b = int(b)
		binary.extend([0x07, get_reg_num(a)])
		binary.extend(pad(b, 2))
	elif op == 'LOADI':
		binary.extend([0x08, get_reg_num(a), get_reg_num(b)])
		binary.extend([0x00])
	elif op == 'STORE':
		a = int(a)
		binary.extend([0x09])
		binary.extend(pad(a, 2))
		binary.extend([get_reg_num(b)])
	elif op == 'STOREI':
		binary.extend([0x0a, get_reg_num(a), get_reg_num(b)])
		binary.extend([0x00])
	elif op == 'EQU':
		binary.extend([0x0b, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	elif op == 'INF':
		binary.extend([0x0c, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	elif op == 'INFE':
		binary.extend([0x0d, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	elif op == 'SUP':
		binary.extend([0x0e, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	elif op == 'SUPE':
		binary.extend([0x0f, get_reg_num(a), get_reg_num(b), \
			get_reg_num(c)])
	elif op == 'JMP':
		a = int(a)
		binary.extend([0x10])
		binary.extend(pad(ip + a + 1, 2))
		binary.extend([0x00])
	elif op == 'JMPC':
		a = int(a)
		binary.extend([0x11])
		binary.extend(pad(ip + a + 1, 2))
		binary.extend([get_reg_num(b)])
	elif op == 'PRINT':
		binary.extend([0x12])
		binary.extend(pad(get_reg_num(a), 3))
	else:
		handle_err("Unknown instruction")
	ip += 1

def process(instrs):
	global ip
	i = instrs[ip]
	output = '' # Output buffer
	
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
	
	# Debug
	if debug:
		print_instr(instrs[ip])
	
	# Process instructions
	if op[:1] == '#' or op[:1] == '\n' or op == '':	# Ignore
		op = None
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
	# TODO: COP
	elif op == 'AFC':
		b = int(b)
		set_reg(a, b)
	elif op == 'LOAD':
		b = int(b)
		set_reg(a, mem[b])
	elif op == 'LOADI':
		set_reg(a, mem[get_reg(b)])
	elif op == 'STORE':
		a = int(a)
		mem[a] = get_reg(b)
	elif op == 'STOREI':
		mem[get_reg(a)] = get_reg(b)
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
	elif op == 'JMP':
		a = int(a)
		ip += a
	elif op == 'JMPC':
		if get_reg(b) == 0:
			a = int(a)
			ip += a
		else:
			pass
	elif op == 'PRINT':
		char_ptr = get_reg(a)
		byte = mem[char_ptr]
		# Buffer output
		while byte != 0:
			byte = mem[char_ptr]
			output = '{}{}'.format(output, chr(byte))
			char_ptr += 1
			byte = mem[char_ptr]
	else:
		handle_err("Unknown instruction")
	if debug:
		print_mem()
	
	# Print output
	if output:
		print(output)
	
	ip += 1


def main():
	if len(sys.argv) < 2:
		print("Missing arguments")
		sys.exit(1)
	
	# Open assembly source
	filename = sys.argv[1]
	f = open(filename)
	instrs = f.read().split('\n')
	f.close()
	instr_count = len(instrs)
	
	if len(sys.argv) > 2: # XXX: Gross handling of arguments
		if sys.argv[2] == "-b":
			# Generate binary
			while ip < instr_count:
				print(ip, end='')
				gen_bin(instrs)
			# Export binary
			f = open("a.bin", "wb")
			f.write(binary)
			f.close()
		else:
			if sys.argv[2] == "-d":
				global debug
				debug = True
	# Process instructions
	while ip < instr_count:
		process(instrs)
	
	sys.exit(0)

if __name__ == '__main__':
	main()
