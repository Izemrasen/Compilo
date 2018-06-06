#!/usr/bin/env python3

import os
import sys
import argparse


debug = False

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


def set_reg(str_reg, val):
	if str_reg in reg:
		reg[str_reg] = val
	else:
		handle_err("Register doesn't exist")


def process(instrs):
	global ip
	i = instrs[ip]
	# Output buffer
	output = ''
	
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
	if len(sys.argv) > 2 and sys.argv[2] == "-d":
		global debug
		debug = True
	
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
	#print()
	sys.exit(0)

if __name__ == '__main__':
	main()
