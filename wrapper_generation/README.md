# FIFO 及 RAM 封装代码生成器

## 概述

本工具集包含一系列脚本与模板，用于自动生成各种类型的 FIFO (先进先出存储器) 和 RAM (随机存取存储器) 模块的 Verilog 封装 (Wrapper) 代码。

生成器的核心是 `auto_gen.py` 这一 Python 脚本。它通过接收一系列命令行参数，处理 Verilog 模板文件 (`.v`) 和实例化模板 (`TP_*_INST`)，从而产生用户定制的 Verilog 封装文件。

## 文件说明

- **`auto_gen.py`**: 主要的生成脚本。它负责读取模板，替换参数，并最终写入 Verilog 输出文件。
- **`auto_gen_*`**: 辅助性的 Shell 脚本，功能可能是使用预设好的参数来调用 `auto_gen.py`，以生成特定类型的模块 (例如 `app`, `mep`, `pcs`)。
- **`module_*.v`**: 针对不同 FIFO 架构的 Verilog 模板文件集合：
    - `module_fifo.v`: 标准同步 FIFO。
    - `module_afifo.v`: 异步 FIFO。
    - `module_fwft_fifo.v`: 支持首字直通 (First-Word-Fall-Through) 的同步 FIFO。
    - `module_fwft_afifo.v`: 支持首字直通的异步 FIFO。
- **`tp_ram.v` / `tpuhd_ram.v`**: RAM 模块本身的 Verilog 模板。
- **`TP_RAM_INST*`**: 包含 RAM 宏实例化的文本文件模板，其内容将被插入到最终生成的 FIFO 封装代码中。

## 使用方法

使用该工具的主要方式是在命令行中运行 `auto_gen.py` 脚本，并附上一系列参数。

### 命令语法

```sh
python auto_gen.py <参数1> <参数2> ... <参数15> <命令1> [<命令2> ...]
```

### 参数说明

脚本需要至少15个初始化参数，其后跟随一个或多个指定生成类型的命令。

| 参数序号 | 参数名          | 描述                                              | 示例值        |
|----------|-----------------|---------------------------------------------------|---------------|
| 1        | `PORT_NUM`      | 指定端口类型，"TPUHD"会启用特定配置。              | `TPUHD` 或 `1`|
| 2        | `MEMORY_TYPE`   | 定义存储器类型。                                  | `SP`          |
| 3        | `RAM_DEPTH`     | 存储器深度 (字的數量)。                           | `1024`        |
| 4        | `DATA_WIDTH`    | 数据位宽 (每个字的比特数)。                       | `128`         |
| 5        | `PERIP_VT`      | 外围电路 VT 类型。                                | `pvt`         |
| 6        | `BIT_WRITE`     | 位写使能标志。                                    | `0`           |
| 7        | `MULTIP`        | 乘法器配置。                                      | `1`           |
| 8        | `BANK`          | Bank 编号。                                       | `0`           |
| 9        | `REDUNDANCY`    | 冗余标志。                                        | `0`           |
| 10       | `LOW_POWER`     | 低功耗模式标志。                                  | `0`           |
| 11       | `INPUT_PIPE`    | 输入流水线级数。                                  | `1`           |
| 12       | `OUTPUT_PIPE`   | 输出流水线级数。                                  | `1`           |
| 13       | `ADDR_WIDTH`    | 地址总线位宽 (应与 `RAM_DEPTH` 匹配)。            | `10` (对应 1024 深度) |
| 14       | `MODULE_NAME`   | 生成模块的基础名称。                              | `my_fifo`     |
| 15       | `FILE_PATH`     | 用于生成输出目录的特殊路径关键字。                | `as6i_mep_ss` |
| 16+      | `commands`      | 一个或多个命令，指定要生成的内容。                | `fifo`, `ram` |

### 命令

- `fifo`: 生成标准同步 FIFO 封装。
- `afifo`: 生成异步 FIFO 封装。
- `fwft_fifo`: 生成 FWFT 同步 FIFO 封装。
- `fwft_afifo`: 生成 FWFT 异步 FIFO 封装。
- `ram`: 生成 RAM 封装。

### 示例

生成一个深度为512、数据位宽为64、地址位宽为9的同步 FIFO：

```sh
python auto_gen.py 1 SP 512 64 pvt 0 1 0 0 0 1 1 9 my_module_name as6i_mep_ss fifo
```

该命令将生成一个名为 `my_module_name_1r1w_512x64_fifo_wrapper.v` 的 Verilog 文件，并将其放置在由 `FILE_PATH` 参数决定的目录结构中。