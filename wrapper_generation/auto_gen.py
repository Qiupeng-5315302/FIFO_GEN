
import sys
import re
import itertools


def gen_file_path(module_name):
    get_file_path_re = re.compile(r"as6([a-z])_([a-z0-9_]*)")

    if file_path_match := get_file_path_re.match(module_name):
        file_path_g1 = file_path_match.group(1).upper()
        file_path_g2 = file_path_match.group(2).upper()
        file_path    = "DS12U28{0}/AS6{0}_{1}".format(file_path_g1, file_path_g2)

    return file_path


def cal_ecc_width():
    numbers = itertools.count(start=2)

    for num in numbers:
        if 2 ** num >= num + DATA_WIDTH + ADDR_WIDTH + 1:
            break

    return num + 1


def gen_fifo(command):
    global TPUHD, FIFO, AFIFO, FWFT_FIFO, FWFT_AFIFO
    TPUHD      = PORT_NUM == "TPUHD"
    FIFO       = command  == "fifo"
    AFIFO      = command  == "afifo"
    FWFT_FIFO  = command  == "fwft_fifo"
    FWFT_AFIFO = command  == "fwft_afifo"

    base_fifo = ""


    def gen_ram_inst():
        ram_inst = ""

        if AFIFO:
            inst_file = "./TP_RAM_INST_AFIFO"
        elif FIFO:
            if TPUHD:
                inst_file = "./TPUHD_RAM_INST"
            else:
                inst_file = "./TP_RAM_INST"
        else:
            inst_file = "./TP_RAM_INST"

        with open(inst_file, mode="r") as fp_ram_inst:
            for line in fp_ram_inst:
                ram_inst += line

        ram_inst = ram_inst.format(
            module_name = MODULE_NAME,
            ram_depth   = RAM_DEPTH,
            data_width  = DATA_WIDTH,
        )

        return ram_inst


    if FWFT_AFIFO:
        module_file = "./module_fwft_afifo.v"
    elif FWFT_FIFO:
        module_file = "./module_fwft_fifo.v"
    elif AFIFO:
        module_file = "./module_afifo.v"
    elif FIFO:
        module_file = "./module_fifo.v"
    else:
        raise ValueError

    with open(module_file, mode="r") as fp_base_fifo:
        for line in fp_base_fifo:
            base_fifo += line

    if TPUHD:
        tpuhd_ram_cfg  = "input  [9:0]              reg_dft_sync_tpram_config;\n"
        tpuhd_port_cfg = "reg_dft_sync_tpram_config"
    else:
        tpuhd_ram_cfg  = "input  [8:0]              reg_dft_tpram_config;\n"
        tpuhd_port_cfg = "reg_dft_tpram_config"

    code_ram_inst = gen_ram_inst()

    base_fifo = base_fifo.format(
        module_name = MODULE_NAME,
        ram_depth   = RAM_DEPTH,
        data_width  = DATA_WIDTH,
        addr_width  = ADDR_WIDTH,
        ram_inst    = code_ram_inst,
        tpuhd_ram   = tpuhd_ram_cfg,
        tpuhd_port  = tpuhd_port_cfg,
    )
    return base_fifo


def gen_ram(command):
    global TPUHD, RAM
    TPUHD = PORT_NUM == "TPUHD"
    RAM   = command  == "ram"

    base_ram = ""

    if RAM:
        if TPUHD:
            module_file = "./tpuhd_ram.v"
        else:
            module_file = "./tp_ram.v"
    else:
        raise ValueError

    with open(module_file, mode="r") as fp_base_ram:
        for line in fp_base_ram:
            base_ram += line

    base_ram = base_ram.format(
        module_name       = MODULE_NAME,
        ram_depth         = RAM_DEPTH,
        data_width        = DATA_WIDTH,
        addr_width        = ADDR_WIDTH,
        parity_width      = ecc_width,
        data_addr_width   = DATA_WIDTH + ADDR_WIDTH,
        data_parity_width = DATA_WIDTH + ecc_width,
        port_num          = PORT_NUM,
        memory_type       = MEMORY_TYPE,
        perip_vt          = PERIP_VT,
        bit_write         = BIT_WRITE,
        multip            = MULTIP,
        bank              = BANK,
        redundancy        = REDUNDANCY,
        low_power         = LOW_POWER,
        input_type        = INPUT_PIPE,
        output_pipe       = OUTPUT_PIPE,
    )

    return base_ram


PORT_NUM    =     sys.argv[1]
MEMORY_TYPE =     sys.argv[2]
RAM_DEPTH   = int(sys.argv[3])
DATA_WIDTH  = int(sys.argv[4])
PERIP_VT    =     sys.argv[5]
BIT_WRITE   = int(sys.argv[6])
MULTIP      = int(sys.argv[7])
BANK        = int(sys.argv[8])
REDUNDANCY  = int(sys.argv[9])
LOW_POWER   = int(sys.argv[10])
INPUT_PIPE  = int(sys.argv[11])
OUTPUT_PIPE = int(sys.argv[12])
ADDR_WIDTH  = int(sys.argv[13])
MODULE_NAME =     sys.argv[14]
FILE_PATH   =     sys.argv[15]

commands    =     sys.argv[16:]

ecc_width = cal_ecc_width()
file_path = gen_file_path(FILE_PATH)

for command in commands:
    if "fifo" in command:
        o_file_path = "../../../../{}/mem/fifo_wrapper/{}_1r1w_{}x{}_{}_wrapper.v"
        o_file_path = o_file_path.format(file_path, MODULE_NAME, RAM_DEPTH, DATA_WIDTH, command)
        with open(o_file_path, mode="w") as fp:
            fp.write(gen_fifo(command))

for command in commands:
    if "ram" in command:
        o_file_path = "../../../../{}/mem/ram_wrapper/{}_1r1w_{}x{}_{}_wrapper.v"
        o_file_path = o_file_path.format(file_path, MODULE_NAME, RAM_DEPTH, DATA_WIDTH, command)
        with open(o_file_path, mode="w") as fp:
            fp.write(gen_ram(command))
