import re
import sys
import serial
import time

COM_PORT = "COM8"
BAUDRATE = 115200

OP = {
    "RTYPE": 0b000000,
    "ADDI":  0b000001,
    "LW":    0b000010,
    "SW":    0b000011,
    "BEQ":   0b000100,
    "BNE":   0b000101,
    "J":     0b000110,
    "LUI":   0b000111,
    "HALT":  0b111110,
    "NOP":   0b111111,
}

FUNCT = {
    "ADD":  0b0000,
    "SUB":  0b0001,
    "AND":  0b0010,
    "OR":   0b0011,
    "XOR":  0b0100,
    "MUL":  0b0101,
    "DIV":  0b0110,
    "MOD":  0b0111,
    "SLL":  0b1000,
    "SRL":  0b1001,
    "SRA":  0b1010,
    "SLT":  0b1011,
    "SLTU": 0b1100,
}

def reg(x):
    return int(x.upper().replace("R", ""))

def imm16(x):
    return int(x, 0) & 0xFFFF

def clean(line):
    line = line.split("#")[0]
    line = line.split(";")[0]
    return line.strip()

def tokenize(line):
    return [t for t in re.split(r"[,\s()]+", line.strip()) if t]

def encode_r(op, rd, rs1, rs2):
    return (
        (OP["RTYPE"] << 26) |
        (reg(rs1) << 21) |
        (reg(rs2) << 16) |
        (reg(rd)  << 11) |
        FUNCT[op]
    )

def encode_i(op, rd, rs1, imm):
    return (
        (OP[op] << 26) |
        (reg(rs1) << 21) |
        (reg(rd) << 16) |
        imm16(imm)
    )

def encode_mem(op, r, offset, base):
    return (
        (OP[op] << 26) |
        (reg(base) << 21) |
        (reg(r) << 16) |
        imm16(offset)
    )

def encode_branch(op, rs1, rs2, offset):
    return (
        (OP[op] << 26) |
        (reg(rs1) << 21) |
        (reg(rs2) << 16) |
        imm16(offset)
    )

def encode_lui(rd, imm):
    return (
        (OP["LUI"] << 26) |
        (reg(rd) << 16) |
        imm16(imm)
    )

def first_pass(lines):

    labels = {}
    cleaned = []

    pc = 0

    for line in lines:

        line = clean(line)

        if not line:
            continue

        if ":" in line:

            label, rest = line.split(":", 1)

            labels[label.strip()] = pc

            line = rest.strip()

            if not line:
                continue

        cleaned.append(line)
        pc += 1

    return labels, cleaned

def assemble(lines):

    labels, cleaned = first_pass(lines)

    machine = []

    for pc, line in enumerate(cleaned):

        t = tokenize(line)

        op = t[0].upper()

        if op in FUNCT:

            word = encode_r(
                op,
                t[1],
                t[2],
                t[3]
            )

        elif op == "ADDI":

            word = encode_i(
                op,
                t[1],
                t[2],
                t[3]
            )

        elif op in ("LW", "SW"):

            word = encode_mem(
                op,
                t[1],
                t[2],
                t[3]
            )

        elif op in ("BEQ", "BNE"):

            target = t[3]

            if target in labels:
                offset = labels[target] - (pc + 1)
            else:
                offset = int(target, 0)

            word = encode_branch(
                op,
                t[1],
                t[2],
                offset
            )

        elif op == "J":

            target = t[1]

            if target in labels:
                addr = labels[target]
            else:
                addr = int(target, 0)

            word = (
                (OP["J"] << 26) |
                (addr & 0x03FFFFFF)
            )

        elif op == "LUI":

            word = encode_lui(
                t[1],
                t[2]
            )

        elif op == "HALT":

            word = OP["HALT"] << 26

        elif op == "NOP":

            word = OP["NOP"] << 26

        else:

            raise Exception(
                f"Unknown instruction: {line}"
            )

        machine.append(word)

    return machine

def upload(machine):

    print(f"\nOpening {COM_PORT} ...")

    ser = serial.Serial(
        COM_PORT,
        BAUDRATE,
        timeout=1
    )

    time.sleep(2)

    print("Uploading program...\n")

    for instr in machine:

        hexline = f"{instr:08X}"

        print(hexline)

        ser.write(
            (hexline + "\n").encode()
        )

        time.sleep(0.05)

    ser.write(b"RUN\n")

    print("\nRUN sent.")
    print("\nFPGA Output:\n")

    try:
        while True:

            line = (
                ser.readline()
                .decode(errors="ignore")
                .strip()
            )

            if line:
                print(line)

    except KeyboardInterrupt:

        print("\nStopped.")

    ser.close()

def main():

    if len(sys.argv) != 2:

        print(
            "Usage:\n"
            "python assembler.py program.asm"
        )

        return

    with open(sys.argv[1], "r") as f:
        lines = f.readlines()

    machine = assemble(lines)

    upload(machine)

if __name__ == "__main__":
    main()
