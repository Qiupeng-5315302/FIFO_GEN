# FIFO_GEN - FIFO/RAM 封装生成与验证平台

[English](#english-version) | [中文](#中文版本)

---

## 中文版本

### 项目简介

FIFO_GEN 是一个用于**自动化生成和验证 FIFO (First-In-First-Out) 和 RAM 封装模块**的完整平台。本项目提供了参数化的 Verilog 代码生成工具和基于 cocotb 的自动化验证环境，适用于数字集成电路设计中的存储器和缓冲模块开发。

### 主要功能

- **参数化 Wrapper 生成**: 根据用户指定的参数（深度、位宽、端口类型等）自动生成定制化的 FIFO 和 RAM Verilog 模块
- **多种 FIFO 架构支持**: 
  - 标准同步 FIFO
  - First-Word-Fall-Through (FWFT) FIFO
  - 异步 FIFO (AFIFO)
  - 带 ECC 的 FIFO
- **RAM 模块生成**: 支持单端口和双端口 RAM 配置
- **自动化验证**: 基于 cocotb 的完整回归测试框架
- **中心化管理**: 作为项目中所有 Memory 和 FIFO IP 的统一来源

### 目录结构

```
FIFO_GEN/
├── wrapper_generation/    # 核心: Wrapper 生成脚本和模板
│   ├── auto_gen_local.py  # 主生成脚本
│   ├── module_*.v         # FIFO/RAM Verilog 模板
│   ├── dv/                # 验证环境 (Makefile & 回归脚本)
│   └── README.md          # 详细使用文档
├── sync_fifo/             # 同步 FIFO 示例模块
├── ecc_module/            # ECC (错误检查与纠正) 模块
├── ram_wrapper/           # RAM 封装模块
├── sram_wrapper/          # SRAM 封装模块
└── ram_bus_delay/         # RAM 总线延迟模块
```

### 快速开始

#### 1. 生成 FIFO Wrapper

```bash
cd wrapper_generation
python auto_gen_local.py TPUHD SRAM 2048 128 SVT 0 8 4 0 0 0 0 11 my_fifo output_dir fifo fwft_fifo
```

参数说明：
- `PORT_NUM`: 端口类型 (例如: TPUHD)
- `MEMORY_TYPE`: 存储器类型 (SRAM)
- `RAM_DEPTH`: 深度 (2048)
- `DATA_WIDTH`: 数据位宽 (128)
- 更多参数详见 `wrapper_generation/README.md`

#### 2. 运行验证测试

```bash
cd wrapper_generation/dv
./run_regression.sh
```

### 详细文档

- **Wrapper 生成详细指南**: [wrapper_generation/README.md](wrapper_generation/README.md)
- **异步 FIFO 清零功能**: [wrapper_generation/afifo_clear_sync_usage.md](wrapper_generation/afifo_clear_sync_usage.md)

### 技术特点

- **模板化设计**: 使用 Verilog 模板实现参数化，易于扩展和维护
- **Python 自动化**: 基于 Python 的生成脚本，支持批量生成
- **标准化验证**: 使用 cocotb + iverilog 构建可重复的验证流程
- **跨平台支持**: 在 WSL/Linux 环境下运行

### 贡献与反馈

欢迎提交 Issue 和 Pull Request 来改进本项目。

---

## English Version

### Project Overview

FIFO_GEN is a comprehensive platform for **automated generation and verification of FIFO (First-In-First-Out) and RAM wrapper modules**. This project provides parameterized Verilog code generation tools and a cocotb-based automated verification environment, suitable for memory and buffer module development in digital integrated circuit design.

### Key Features

- **Parameterized Wrapper Generation**: Automatically generate customized FIFO and RAM Verilog modules based on user-specified parameters (depth, width, port type, etc.)
- **Multiple FIFO Architectures**:
  - Standard Synchronous FIFO
  - First-Word-Fall-Through (FWFT) FIFO
  - Asynchronous FIFO (AFIFO)
  - FIFO with ECC support
- **RAM Module Generation**: Supports single-port and dual-port RAM configurations
- **Automated Verification**: Complete regression test framework based on cocotb
- **Centralized Management**: Serves as the single source for all Memory and FIFO IPs in the project

### Directory Structure

```
FIFO_GEN/
├── wrapper_generation/    # Core: Wrapper generation scripts and templates
│   ├── auto_gen_local.py  # Main generation script
│   ├── module_*.v         # FIFO/RAM Verilog templates
│   ├── dv/                # Verification environment (Makefile & regression scripts)
│   └── README.md          # Detailed usage documentation
├── sync_fifo/             # Synchronous FIFO example modules
├── ecc_module/            # ECC (Error Checking and Correction) modules
├── ram_wrapper/           # RAM wrapper modules
├── sram_wrapper/          # SRAM wrapper modules
└── ram_bus_delay/         # RAM bus delay modules
```

### Quick Start

#### 1. Generate FIFO Wrapper

```bash
cd wrapper_generation
python auto_gen_local.py TPUHD SRAM 2048 128 SVT 0 8 4 0 0 0 0 11 my_fifo output_dir fifo fwft_fifo
```

Parameter description:
- `PORT_NUM`: Port type (e.g., TPUHD)
- `MEMORY_TYPE`: Memory type (SRAM)
- `RAM_DEPTH`: Depth (2048)
- `DATA_WIDTH`: Data width (128)
- For more parameters, see `wrapper_generation/README.md`

#### 2. Run Verification Tests

```bash
cd wrapper_generation/dv
./run_regression.sh
```

### Detailed Documentation

- **Wrapper Generation Guide**: [wrapper_generation/README.md](wrapper_generation/README.md)
- **Async FIFO Clear Sync Feature**: [wrapper_generation/afifo_clear_sync_usage.md](wrapper_generation/afifo_clear_sync_usage.md)

### Technical Highlights

- **Template-Based Design**: Verilog templates enable parameterization, easy to extend and maintain
- **Python Automation**: Python-based generation scripts support batch generation
- **Standardized Verification**: Repeatable verification flow using cocotb + iverilog
- **Cross-Platform Support**: Runs on WSL/Linux environments

### Contributions

Issues and Pull Requests are welcome to improve this project.

---

## License

This project is provided as-is for educational and development purposes.
