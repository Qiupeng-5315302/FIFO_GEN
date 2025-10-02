
import sys
import re

PORT_NUM = sys.argv[1]
MEMORY_TYPE = sys.argv[2]
RAM_DEPTH = int(sys.argv[3])
DATA_WIDTH = int(sys.argv[4])
PERIP_VT = sys.argv[5]
BIT_WRITE = int(sys.argv[6])
MULTIP = int(sys.argv[7])
BANK = int(sys.argv[8])
REDUNDANCY = int(sys.argv[9])
LOW_POWER = int(sys.argv[10])
INPUT_PIPE = int(sys.argv[11])
OUTPUT_PIPE = int(sys.argv[12])
ADDR_WIDTH = int(sys.argv[13])
MODULE_NAME = sys.argv[14]
FILE_PATH = sys.argv[15]

command = sys.argv[16:]


def gen_file_path(module_name):
    get_file_path_re = re.compile(r"as6([a-z])_([a-z0-9_]*)")
    if get_file_path_re.match(module_name):
        file_path_match = get_file_path_re.match(module_name)
        file_path = "AS6T28{0}/AS6{0}_{1}".format(
            file_path_match.group(1).upper(), file_path_match.group(2).upper()
        )
    return file_path


class base_case:
    get_parity_width_re = re.compile(
        r".*?input.*?\[ *([0-9]+) *- *1: *0 *\] *parity_in"
    )

    module_name_re = re.compile(r"(.*?)module(.*?)\w+(.*?)$")
    addr_width_re = re.compile(r"(.*?)parameter(.*?)ADDR_WIDTH(.*?)[0-9]+(.*?;)")
    data_width_re = re.compile(r"(.*?)parameter(.*?)DATA_WIDTH(.*?)[0-9]+(.*?;)")
    parity_width_re = re.compile(r"(.*?)parameter(.*?)PARITY_WIDTH(.*?)[0-9]+(.*?;)")
    flipflop_re = re.compile(r"(.*?)parameter(.*?)FLIPFLOP(.*?)[0-9]+(.*?;)")
    ecc_top_re = re.compile(r"(.*?)ecc_[0-9]+_top(.*?)$")
    sram_wrapper_re = re.compile(r"(.*?)sram_wrapper(.*?)$")
    ram_instance_re = re.compile(r"(\) *u0_|)ram_wrapper(.*?)$")
    fifo_instance_re = re.compile(r"(?!fwft_)(\) *u0_|)fifo_wrapper(.*?)$")

    def __init__(
        self,
        PORT_NUM,
        MEMORY_TYPE,
        RAM_DEPTH,
        DATA_WIDTH,
        PERIP_VT,
        BIT_WRITE,
        MULTIP,
        BANK,
        REDUNDANCY,
        LOW_POWER,
        INPUT_PIPE,
        OUTPUT_PIPE,
        ADDR_WIDTH,
        MODULE_NAME,
        template_fp,
    ):
        self.PORT_NUM = PORT_NUM
        self.MEMORY_TYPE = MEMORY_TYPE
        self.RAM_DEPTH = RAM_DEPTH
        self.DATA_WIDTH = DATA_WIDTH
        self.PERIP_VT = PERIP_VT
        self.BIT_WRITE = BIT_WRITE
        self.MULTIP = MULTIP
        self.BANK = BANK
        self.REDUNDANCY = REDUNDANCY
        self.LOW_POWER = LOW_POWER
        self.INPUT_PIPE = INPUT_PIPE
        self.OUTPUT_PIPE = OUTPUT_PIPE
        self.ADDR_WIDTH = ADDR_WIDTH
        self.MODULE_NAME = MODULE_NAME
        self.template_fp = template_fp
        self.PARITY_WIDTH = self.get_parity_width()
        self.output_module_list = self.get_template()
        self.write_module_name()
        self.write_addr_width()
        self.write_data_width()

    def get_parity_width(self):
        with open("../ecc_module/ecc_{}_top.v".format(DATA_WIDTH)) as ecc_fp:
            for line in ecc_fp:
                if self.get_parity_width_re.match(line):
                    get_parity_width_match = self.get_parity_width_re.match(line)
                    parity_width = int(get_parity_width_match.group(1))
        return parity_width

    def get_template(self):
        output_module_list = []
        for line in self.template_fp:
            output_module_list.append(line)
        return output_module_list

    def write_module_name(self):
        for n in range(0, len(self.output_module_list)):
            if self.module_name_re.match(self.output_module_list[n]):
                module_name_match = self.module_name_re.match(
                    self.output_module_list[n]
                )
                tmp = "{}module {}_1r1w_{}x{}_ram_wrapper{}\n".format(
                    module_name_match.group(1),
                    self.MODULE_NAME,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH,
                    module_name_match.group(3),
                )
                self.output_module_list[n] = tmp

    def write_addr_width(self):
        for n in range(0, len(self.output_module_list)):
            if self.addr_width_re.match(self.output_module_list[n]):
                addr_width_match = self.addr_width_re.match(self.output_module_list[n])
                tmp = "parameter{}ADDR_WIDTH{}{}{}\n".format(
                    addr_width_match.group(2),
                    addr_width_match.group(3),
                    self.ADDR_WIDTH,
                    addr_width_match.group(4),
                )
                self.output_module_list[n] = tmp

    def write_data_width(self):
        for n in range(0, len(self.output_module_list)):
            if self.data_width_re.match(self.output_module_list[n]):
                data_width_match = self.data_width_re.match(self.output_module_list[n])
                tmp = "parameter{}DATA_WIDTH{}{}{}\n".format(
                    data_width_match.group(2),
                    data_width_match.group(3),
                    self.DATA_WIDTH,
                    data_width_match.group(4),
                )
                self.output_module_list[n] = tmp


class ram_case(base_case):
    def __init__(
        self,
        PORT_NUM,
        MEMORY_TYPE,
        RAM_DEPTH,
        DATA_WIDTH,
        PERIP_VT,
        BIT_WRITE,
        MULTIP,
        BANK,
        REDUNDANCY,
        LOW_POWER,
        INPUT_PIPE,
        OUTPUT_PIPE,
        ADDR_WIDTH,
        MODULE_NAME,
        template_fp,
    ):
        super().__init__(
            PORT_NUM,
            MEMORY_TYPE,
            RAM_DEPTH,
            DATA_WIDTH,
            PERIP_VT,
            BIT_WRITE,
            MULTIP,
            BANK,
            REDUNDANCY,
            LOW_POWER,
            INPUT_PIPE,
            OUTPUT_PIPE,
            ADDR_WIDTH,
            MODULE_NAME,
            template_fp,
        )
        self.write_parity_width()
        self.write_ecc_top()
        self.write_sram_wrapper()

    def write_module_name(self):
        for n in range(0, len(self.output_module_list)):
            if self.module_name_re.match(self.output_module_list[n]):
                module_name_match = self.module_name_re.match(
                    self.output_module_list[n]
                )
                tmp = "{}module {}_1r1w_{}x{}_ram_wrapper{}\n".format(
                    module_name_match.group(1),
                    self.MODULE_NAME,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH,
                    module_name_match.group(3),
                )
                self.output_module_list[n] = tmp

    def write_parity_width(self):
        for n in range(0, len(self.output_module_list)):
            if self.parity_width_re.match(self.output_module_list[n]):
                parity_width_match = self.parity_width_re.match(
                    self.output_module_list[n]
                )
                tmp = "parameter{}PARITY_WIDTH{}{}{}\n".format(
                    parity_width_match.group(2),
                    parity_width_match.group(3),
                    self.PARITY_WIDTH,
                    parity_width_match.group(4),
                )
                self.output_module_list[n] = tmp

    def write_ecc_top(self):
        for n in range(0, len(self.output_module_list)):
            if self.ecc_top_re.match(self.output_module_list[n]):
                ecc_top_match = self.ecc_top_re.match(self.output_module_list[n])
                tmp = "{}ecc_{}_top{}\n".format(
                    ecc_top_match.group(1),
                    self.DATA_WIDTH,
                    ecc_top_match.group(2),
                )
                self.output_module_list[n] = tmp

    def write_sram_wrapper(self):
        for n in range(0, len(self.output_module_list)):
            if self.sram_wrapper_re.match(self.output_module_list[n]):
                sram_wrapper_match = self.sram_wrapper_re.match(
                    self.output_module_list[n]
                )
                tmp = "{}{}{}{}X{}{}BW{}M{}B{}R{}P{}_I{}O{}{}\n".format(
                    sram_wrapper_match.group(1),
                    self.PORT_NUM,
                    self.MEMORY_TYPE,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH + self.PARITY_WIDTH,
                    self.PERIP_VT,
                    self.BIT_WRITE,
                    self.MULTIP,
                    self.BANK,
                    self.REDUNDANCY,
                    self.LOW_POWER,
                    self.INPUT_PIPE,
                    self.OUTPUT_PIPE,
                    sram_wrapper_match.group(2),
                )
                self.output_module_list[n] = tmp
        with open("./tmp_{}".format(FILE_PATH),mode = "a+") as tmp_fp:
            tmp_fp.write(
                " ".join(list(map(str,[
                    "../../memory_wrap/gen_mem_wrap",
                    self.PORT_NUM,
                    self.MEMORY_TYPE,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH + self.PARITY_WIDTH,
                    self.PERIP_VT,
                    self.BIT_WRITE,
                    self.MULTIP,
                    self.BANK,
                    self.REDUNDANCY,
                    self.LOW_POWER,
                    self.INPUT_PIPE,
                    self.OUTPUT_PIPE,
                    self.ADDR_WIDTH,
                    self.MODULE_NAME,
                    "\n",]))
                )
            )


class fifo_case(base_case):
    def __init__(
        self,
        PORT_NUM,
        MEMORY_TYPE,
        RAM_DEPTH,
        DATA_WIDTH,
        PERIP_VT,
        BIT_WRITE,
        MULTIP,
        BANK,
        REDUNDANCY,
        LOW_POWER,
        INPUT_PIPE,
        OUTPUT_PIPE,
        ADDR_WIDTH,
        MODULE_NAME,
        template_fp,
    ):
        super().__init__(
            PORT_NUM,
            MEMORY_TYPE,
            RAM_DEPTH,
            DATA_WIDTH,
            PERIP_VT,
            BIT_WRITE,
            MULTIP,
            BANK,
            REDUNDANCY,
            LOW_POWER,
            INPUT_PIPE,
            OUTPUT_PIPE,
            ADDR_WIDTH,
            MODULE_NAME,
            template_fp,
        )
        self.write_flipflop_width()
        self.write_module_instance()

    def write_module_name(self):
        for n in range(0, len(self.output_module_list)):
            if self.module_name_re.match(self.output_module_list[n]):
                module_name_match = self.module_name_re.match(
                    self.output_module_list[n]
                )
                tmp = "{}module {}_1r1w_{}x{}_fifo_wrapper{}\n".format(
                    module_name_match.group(1),
                    self.MODULE_NAME,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH,
                    module_name_match.group(3),
                )
                self.output_module_list[n] = tmp

    def write_flipflop_width(self):
        for n in range(0, len(self.output_module_list)):
            if self.flipflop_re.match(self.output_module_list[n]):
                flipflop_match = self.flipflop_re.match(self.output_module_list[n])
                tmp = "parameter{}FLIPFLOP{}{}{}\n".format(
                    flipflop_match.group(2),
                    flipflop_match.group(3),
                    0,
                    flipflop_match.group(4),
                )
                self.output_module_list[n] = tmp

    def write_module_instance(self):
        for n in range(0, len(self.output_module_list)):
            if self.ram_instance_re.match(self.output_module_list[n]):
                ram_instance_match = self.ram_instance_re.match(
                    self.output_module_list[n]
                )
                tmp = "{}{}_1r1w_{}x{}_ram_wrapper{}\n".format(
                    ram_instance_match.group(1),
                    self.MODULE_NAME,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH,
                    ram_instance_match.group(2),
                )
                self.output_module_list[n] = tmp

class fwft_fifo_case(fifo_case):
    def __init__(
        self,
        PORT_NUM,
        MEMORY_TYPE,
        RAM_DEPTH,
        DATA_WIDTH,
        PERIP_VT,
        BIT_WRITE,
        MULTIP,
        BANK,
        REDUNDANCY,
        LOW_POWER,
        INPUT_PIPE,
        OUTPUT_PIPE,
        ADDR_WIDTH,
        MODULE_NAME,
        template_fp,
    ):
        super().__init__(
            PORT_NUM,
            MEMORY_TYPE,
            RAM_DEPTH,
            DATA_WIDTH,
            PERIP_VT,
            BIT_WRITE,
            MULTIP,
            BANK,
            REDUNDANCY,
            LOW_POWER,
            INPUT_PIPE,
            OUTPUT_PIPE,
            ADDR_WIDTH,
            MODULE_NAME,
            template_fp,
        )

    def write_module_name(self):
        for n in range(0, len(self.output_module_list)):
            if self.module_name_re.match(self.output_module_list[n]):
                module_name_match = self.module_name_re.match(
                    self.output_module_list[n]
                )
                tmp = "{}module {}_1r1w_{}x{}_fwft_fifo_wrapper{}\n".format(
                    module_name_match.group(1),
                    self.MODULE_NAME,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH,
                    module_name_match.group(3),
                )
                self.output_module_list[n] = tmp

    def write_module_instance(self):
        for n in range(0, len(self.output_module_list)):
            if self.fifo_instance_re.match(self.output_module_list[n]):
                fifo_instance_match = self.fifo_instance_re.match(
                    self.output_module_list[n]
                )
                tmp = "{}{}_1r1w_{}x{}_fifo_wrapper{}\n".format(
                    fifo_instance_match.group(1),
                    self.MODULE_NAME,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH,
                    fifo_instance_match.group(2),
                )
                self.output_module_list[n] = tmp

class afifo_case(fifo_case):
    def __init__(
        self,
        PORT_NUM,
        MEMORY_TYPE,
        RAM_DEPTH,
        DATA_WIDTH,
        PERIP_VT,
        BIT_WRITE,
        MULTIP,
        BANK,
        REDUNDANCY,
        LOW_POWER,
        INPUT_PIPE,
        OUTPUT_PIPE,
        ADDR_WIDTH,
        MODULE_NAME,
        template_fp,
    ):
        super().__init__(
            PORT_NUM,
            MEMORY_TYPE,
            RAM_DEPTH,
            DATA_WIDTH,
            PERIP_VT,
            BIT_WRITE,
            MULTIP,
            BANK,
            REDUNDANCY,
            LOW_POWER,
            INPUT_PIPE,
            OUTPUT_PIPE,
            ADDR_WIDTH,
            MODULE_NAME,
            template_fp,
        )

    def write_module_name(self):
        for n in range(0, len(self.output_module_list)):
            if self.module_name_re.match(self.output_module_list[n]):
                module_name_match = self.module_name_re.match(
                    self.output_module_list[n]
                )
                tmp = "{}module {}_1r1w_{}x{}_afifo_wrapper{}\n".format(
                    module_name_match.group(1),
                    self.MODULE_NAME,
                    self.RAM_DEPTH,
                    self.DATA_WIDTH,
                    module_name_match.group(3),
                )
                self.output_module_list[n] = tmp


file_path = gen_file_path(FILE_PATH)

if "fifo" in command:
    with open("../sync_fifo/fifo_wrapper.v", mode="r") as template_fp:
        fifo = fifo_case(
            PORT_NUM,
            MEMORY_TYPE,
            RAM_DEPTH,
            DATA_WIDTH,
            PERIP_VT,
            BIT_WRITE,
            MULTIP,
            BANK,
            REDUNDANCY,
            LOW_POWER,
            INPUT_PIPE,
            OUTPUT_PIPE,
            ADDR_WIDTH,
            MODULE_NAME,
            template_fp,
        )
        with open(
            "../../../../{}/mem/fifo_wrapper/{}_1r1w_{}x{}_fifo_wrapper.v".format(file_path,MODULE_NAME, RAM_DEPTH, DATA_WIDTH),
            mode="w",
        ) as output_fp:
            for line in fifo.output_module_list:
                output_fp.write(line)

if "fwft_fifo" in command:
    with open("../sync_fifo/fwft_fifo_wrapper.v", mode="r") as template_fp:
        fwft_fifo = fwft_fifo_case(
            PORT_NUM,
            MEMORY_TYPE,
            RAM_DEPTH,
            DATA_WIDTH,
            PERIP_VT,
            BIT_WRITE,
            MULTIP,
            BANK,
            REDUNDANCY,
            LOW_POWER,
            INPUT_PIPE,
            OUTPUT_PIPE,
            ADDR_WIDTH,
            MODULE_NAME,
            template_fp,
        )
        with open(
            "../../../../{}/mem/fifo_wrapper/{}_1r1w_{}x{}_fwft_fifo_wrapper.v".format(file_path,MODULE_NAME, RAM_DEPTH, DATA_WIDTH),
            mode="w",
        ) as output_fp:
            for line in fwft_fifo.output_module_list:
                output_fp.write(line)

if "afifo" in command:
    with open("../async_fifo/afifo_wrapper.v", mode="r") as template_fp:
        afifo = afifo_case(
            PORT_NUM,
            MEMORY_TYPE,
            RAM_DEPTH,
            DATA_WIDTH,
            PERIP_VT,
            BIT_WRITE,
            MULTIP,
            BANK,
            REDUNDANCY,
            LOW_POWER,
            INPUT_PIPE,
            OUTPUT_PIPE,
            ADDR_WIDTH,
            MODULE_NAME,
            template_fp,
        )
        with open(
            "../../../../{}/mem/fifo_wrapper/{}_1r1w_{}x{}_afifo_wrapper.v".format(file_path,MODULE_NAME, RAM_DEPTH, DATA_WIDTH),
            mode="w",
        ) as output_fp:
            for line in afifo.output_module_list:
                output_fp.write(line)

if "ram" in command:
    with open("./ram_wrapper.v", mode="r") as template_fp:
        ram = ram_case(
            PORT_NUM,
            MEMORY_TYPE,
            RAM_DEPTH,
            DATA_WIDTH,
            PERIP_VT,
            BIT_WRITE,
            MULTIP,
            BANK,
            REDUNDANCY,
            LOW_POWER,
            INPUT_PIPE,
            OUTPUT_PIPE,
            ADDR_WIDTH,
            MODULE_NAME,
            template_fp,
        )
        with open(
            "../../../../{}/mem/ram_wrapper/{}_1r1w_{}x{}_ram_wrapper.v".format(file_path,MODULE_NAME, RAM_DEPTH, DATA_WIDTH),
            mode="w",
        ) as output_fp:
            for line in ram.output_module_list:
                output_fp.write(line)
