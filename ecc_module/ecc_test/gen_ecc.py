
import sys
import re
import itertools
import math



def is_even(x):
    return x[1]%2==0

def to_bin(value, num):#十进制数据，二进制位宽
	bin_chars = ""
	temp = value
	for i in range(num):
		bin_char = bin(temp % 2)[-1]
		temp = temp // 2
		bin_chars = bin_char + bin_chars
	return bin_chars.upper()#输出指定位宽的二进制字符串

def cal_ecc_wdth(data_wdth):
    numbers = itertools.count(start=2)
    for num in numbers:
        if (2**num >= num + data_wdth+1):
            break
    return num + 1

class ecc_case():
    case_syndrome_re = re.compile(r"(.*?)case\(syndrome\)")
    function_ecc_encode_re = re.compile(r"(.*?)function.*ecc_encode")

    def __init__(
	    self,
	    template_fp,
        data_wdth
    ):
        self.data_wdth = data_wdth
        self.parity_wdth = self.cal_ecc_wdth()
        self.template_fp = template_fp
        self.output_module_list_temp = self.get_template()
        self.index_all=self.gen_index_all()
        self.ele_loc=self.gen_ele_loc()
        self.encode_array=self.gen_encode_array()
        self.syndrome_array=self.gen_syndrome_array()
        self.output_module_list = self.gen_module()
        self.lineBuf=self.replace_wdth()
        
        #print('gen_ecc')

    def cal_ecc_wdth(self):
        numbers = itertools.count(start=2)
        for num in numbers:
            if (2**num >= num+self.data_wdth+1):
                break
        #print('ecc_wdth')
        #print(num + 1)
        return num + 1

    def gen_index_all(self):
        index_all = []
        numbers = itertools.count(start=1)
        for num in numbers:
            if (num < self.parity_wdth + self.data_wdth):
                index_all.append(num)
            else:
                break
        #print('index_all')        
        #print(index_all)
        return index_all


    def gen_ele_loc(self):
        ele_loc_p = []
        p_cnt = 0
        d_cnt = 0
        for num in self.index_all:
            if ((num&(num-1))==0):
                ele_loc_p.append('p[' + str(p_cnt) + ']')
                p_cnt = p_cnt + 1 
            else:
                ele_loc_p.append('d[' + str(d_cnt) + ']')
                d_cnt = d_cnt + 1 
        #print('ele_loc_p')
        #print(ele_loc_p)
        return ele_loc_p


    def gen_encode_array(self):
        encode_array = []
        ele_cnt = []
        encode_array_last = []
        p_array_cnt = 0
        shift_cnt = 0
        for p_array in range(self.parity_wdth-1):
            ele_array = []
            for num in self.index_all:
                num_shift= num >> p_array_cnt
                if (num_shift & 1):
                    ele_array.append(self.ele_loc[num-1])
            encode_array.append(ele_array)
            p_array_cnt = p_array_cnt + 1 
        #print(encode_array)
        #print('encode_array')

        for ele in self.ele_loc:
            ele_cnt.append([ele,0])
        #print(ele_cnt)
        #print('ele_cnt')

        for row in encode_array:
            for col in row:
                for ele_row in ele_cnt:
                    #print(ele_row[0],ele_row[1],col)
                    if(col==ele_row[0]):
                        ele_row[1] =ele_row[1] + 1

        even_numbers = list(filter(is_even,ele_cnt))
        #print('even_numbers')
        #print(even_numbers)
        
        encode_array_last.append('p[' + str(self.parity_wdth-1) + ']')
        for row in even_numbers:
            encode_array_last.append(row[0])

        encode_array.append(encode_array_last)
        #for row in encode_array:
            #print('row')
            #print(row)
        #print('encode_array')
        #print(encode_array)
        return encode_array


    def gen_syndrome_array(self):
        syndrome_array=[]
        for row in range(self.data_wdth):
            col0_int=self.ele_loc.index('d['+str(row)+']')+1
            col0_part0=to_bin(col0_int,self.parity_wdth-1)
            if 'd['+str(row)+']' in self.encode_array[-1]:
                col0_part1 = str(self.parity_wdth)+'\'b1'
            else:
                col0_part1 = str(self.parity_wdth)+'\'b0'
            col0 = col0_part1 + col0_part0
            col1 = str(self.data_wdth) + '\'b' + str(to_bin(2**row,self.data_wdth))
            syndrome_array.append([col0,col1])

        for row in range(self.parity_wdth-1,-1,-1):
            col0 = str(self.parity_wdth) + '\'b' + str(to_bin(2**row,self.parity_wdth))
            col1 = str(self.data_wdth) + '\'b' + str(to_bin(0,self.data_wdth))
            syndrome_array.append([col0,col1])
        #for row in syndrome_array:
            #print(row)
        return syndrome_array

    def get_template(self):
        output_module_list_temp = []
        for line in self.template_fp:
            output_module_list_temp.append(line)
        return output_module_list_temp

    def gen_module(self):
        output_module_list = []
        for line in self.output_module_list_temp:
            if self.case_syndrome_re.match(line):
                output_module_list.append(line+'\n')
                #print(line)
                output_module_list.append('    ' + str(self.parity_wdth) + "\'b" + str(to_bin(0,self.parity_wdth))+" : begin mask = "+str(self.data_wdth)+"\'b"+str(to_bin(0,self.data_wdth))+"; error = 2'b00; end\n\n")
                for row in self.syndrome_array:
                    output_module_list.append('    ' + str(row[0])+' : begin mask = ' + str(row[1])+ "; error = 2'b01; end" + '\n\n')
                output_module_list.append("    default : begin mask = "+str(self.data_wdth)+"\'b"+str(to_bin(0,self.data_wdth))+"; error = 2'b10; end\n")
                continue
            if self.function_ecc_encode_re.match(line):
                output_module_list.append(line+'\n')
                output_module_list.append('    input [ DATA_WIDTH-1:0] d;\n\n')
                output_module_list.append('    reg [ PARITY_WIDTH-1:0] p;\n\n')
                output_module_list.append('    begin\n\n')
                for row in self.encode_array:
                    for col in row:
                        if 'p' in col:
                            output_module_list.append('    ' + col + ' = ')
                        elif  col == row[-1]:
                            output_module_list.append(col + ' ;\n\n')
                        else:
                            output_module_list.append(col+' + ')
                continue
            output_module_list.append(line)
        return output_module_list

    def replace_wdth(self):
        lineBuf=''
        for line in self.output_module_list:
            lineBuf += line
        lineBuf=lineBuf.format(
            data_wdth=self.data_wdth,
            parity_wdth=self.parity_wdth
        )
        #print(lineBuf)
        return lineBuf

start_wdth = 10
end_wdth = 200

gen_ecc_list = []
with open("./ecc_cal.v", mode="r") as fp:
    for i in range(start_wdth,end_wdth):
        fp.seek(0)
        ecc=ecc_case(fp,i)
        gen_ecc_list.append(ecc)
    for ecc_obj in gen_ecc_list:        
        with open(
            "./ecc_{}_cal.v".format(ecc_obj.data_wdth),
            mode="w",
        ) as output_fp:
            #for line in ecc_obj.output_module_list:
            output_fp.write(ecc_obj.lineBuf)

gen_ecc_fault_dect_list = []
with open("./ecc_fault_detc.v", mode="r") as fp1:
    for data_wdth in range(start_wdth,end_wdth):
        parity_wdth=cal_ecc_wdth(data_wdth)
        fp1.seek(0)
        lineBuf=fp1.read()
        lineBuf=lineBuf.format(
            data_wdth=data_wdth,
            parity_wdth=parity_wdth,
        )
        gen_ecc_fault_dect_list.append(lineBuf)
    for data_wdth in range(start_wdth,end_wdth):        
        with open(
            "./ecc_{}_fault_detc.v".format(data_wdth),
            mode="w",
        ) as output_fp:
            output_fp.write(gen_ecc_fault_dect_list.pop(0))


