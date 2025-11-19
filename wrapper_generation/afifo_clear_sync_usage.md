# AFIFO跨时钟域同步清空控制模块

## 模块概述

`afifo_clear_sync.v` 是一个专门设计用于异步FIFO跨时钟域同步清空的控制模块。该模块实现了安全的跨域信号同步、完整的握手协议以及统一的主时钟域状态管理机制，确保AFIFO执行同步清空操作，避免output对下游模块产生亚稳态。

## 功能说明

### 核心功能
1. **跨域同步**: 将外部清空请求安全地同步到读写时钟域
2. **握手协议**: 实现完整的清空请求-应答握手机制
3. **状态管理**: 统一在主时钟域进行清空完成状态汇总
4. **延迟控制**: 可配置的清空完成延迟周期
5. ****: 

### 工作原理
1. **请求阶段**: 外部`sync_clear_req`通过两个独立的同步器分别同步到写域和读域
2. **执行阶段**: 各时钟域接收到清空信号后执行内部清空操作
3. **检测阶段**: 模块内部检测各域清空完成状态，经过可配置延迟后
4. **反馈阶段**: 完成状态统一同步到主时钟域，生成全局应答信号

## 与其他模块连接示意图

```mermaid
graph TB
    %% 系统级连接
    subgraph "系统控制层"
        SYS_CTRL["系统控制器"]
        CLEAR_REQ["fifo_clear_req"]
        CLEAR_ACK["fifo_clear_ack"]
        CLEAR_BUSY["fifo_clear_busy"]
    end
    
    subgraph "AFIFO清空控制模块"
        AFIFO_CLEAR["afifo_clear_sync"]
        WR_CLEAR_OUT["wr_domain_clear"]
        RD_CLEAR_OUT["rd_domain_clear"]
    end
    
    subgraph "AFIFO数据通路"
        AFIFO_WR["AFIFO写域"]
        AFIFO_RD["AFIFO读域"]
        WR_DATA["写数据通路"]
        RD_DATA["读数据通路"]
    end
    
    subgraph "时钟域"
        WR_CLK["wr_clk域"]
        RD_CLK["rd_clk域"] 
        MAIN_CLK["main_clk域"]
    end
    
    %% 连接关系
    SYS_CTRL --> CLEAR_REQ
    CLEAR_REQ --> AFIFO_CLEAR
    AFIFO_CLEAR --> CLEAR_ACK
    AFIFO_CLEAR --> CLEAR_BUSY
    CLEAR_ACK --> SYS_CTRL
    CLEAR_BUSY --> SYS_CTRL
    
    AFIFO_CLEAR --> WR_CLEAR_OUT
    AFIFO_CLEAR --> RD_CLEAR_OUT
    WR_CLEAR_OUT --> AFIFO_WR
    RD_CLEAR_OUT --> AFIFO_RD
    
    WR_CLK --> AFIFO_WR
    WR_CLK --> AFIFO_CLEAR
    RD_CLK --> AFIFO_RD
    RD_CLK --> AFIFO_CLEAR
    MAIN_CLK --> AFIFO_CLEAR

    
    AFIFO_WR --> WR_DATA
    AFIFO_RD --> RD_DATA
    
    %% 样式
    classDef sysCtrl fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef clearCtrl fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef afifoData fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef clockDomain fill:#fff3e0,stroke:#e65100,stroke-width:2px
    
    class SYS_CTRL,CLEAR_REQ,CLEAR_ACK,CLEAR_BUSY sysCtrl
    class AFIFO_CLEAR,WR_CLEAR_OUT,RD_CLEAR_OUT clearCtrl
    class AFIFO_WR,AFIFO_RD,WR_DATA,RD_DATA afifoData
    class WR_CLK,RD_CLK clockDomain
```

### 典型连接示例

```verilog
// 1. 系统级控制器
system_controller u_sys_ctrl (
    .fifo_clear_request(fifo_clear_req),    // 发起清空请求
    .fifo_clear_complete(fifo_clear_ack),   // 接收清空完成
    .fifo_clear_status(fifo_clear_busy)     // 监控清空状态
);

// 2. 跨域同步清空模块
afifo_clear_sync #(
    .CLEAR_DONE_DELAY_CYCLES(3)
) u_clear_sync (
    .wr_clk(wr_clk),
    .wr_rst_n(wr_rst_n),
    .rd_clk(rd_clk),
    .rd_rst_n(rd_rst_n),
    .main_clk(main_clk),                    // 主时钟域
    .main_rst_n(main_rst_n),               // 主域复位
    .sync_clear_req(fifo_clear_req),
    .sync_clear_ack(fifo_clear_ack),
    .sync_clear_busy(fifo_clear_busy),
    .wr_domain_clear(wr_domain_clear),
    .rd_domain_clear(rd_domain_clear)
);

// 3. AFIFO数据通路
afifo_wrapper u_afifo (
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .wr_domain_clear(wr_domain_clear),      // 接收写域清空
    .rd_domain_clear(rd_domain_clear),      // 接收读域清空
    // ... 其他标准AFIFO端口
);
```

## 内部实现示意图

```mermaid
graph TB
    %% 外部接口
    subgraph "外部接口层"
        EXT_REQ["sync_clear_req<br/>外部清空请求"]
        EXT_ACK["sync_clear_ack<br/>清空完成应答"]
        EXT_BUSY["sync_clear_busy<br/>清空忙状态"]
    end
    
    %% 请求同步层
    subgraph "请求同步层"
        WR_SYNC["sync2_cell_rstb<br/>写域同步器"]
        RD_SYNC["sync2_cell_rstb<br/>读域同步器"]
    end
    
    %% 时钟域处理层
    subgraph "写时钟域 (wr_clk)"
        direction TB
        WR_CLK["wr_clk"]
        WR_RST["wr_rst_n"]
        WR_CLEAR_OUT["wr_domain_clear<br/>写域清空输出"]
        WR_DONE_REG["wr_clear_done<br/>写域完成标志"]
        WR_DELAY["bus_delay<br/>(参数化延迟)"]
        WR_DONE_DELAY["wr_clear_done_delay<br/>写域延迟输出"]
    end
    
    subgraph "读时钟域 (rd_clk)"
        direction TB
        RD_CLK["rd_clk"]
        RD_RST["rd_rst_n"]
        RD_CLEAR_OUT["rd_domain_clear<br/>读域清空输出"]
        RD_DONE_REG["rd_clear_done<br/>读域完成标志"]
        RD_DELAY["bus_delay<br/>(参数化延迟)"]
        RD_DONE_DELAY["rd_clear_done_delay<br/>读域延迟输出"]
    end
    
    %% 主时钟域层
    subgraph "主时钟域层"
        MAIN_CLK["main_clk"]
        MAIN_RST["main_rst_n"]
        WR_MAIN_SYNC["wr_done主域同步器"]
        RD_MAIN_SYNC["rd_done主域同步器"]
    end
    
    %% 参数配置层
    subgraph "参数配置层"
        PARAM_DELAY["CLEAR_DONE_DELAY_CYCLES<br/>完成延迟周期"]
    end
    
    %% 状态汇总层
    subgraph "状态汇总层"
        ACK_LOGIC["sync_clear_ack<br/>&"]
        BUSY_LOGIC["sync_clear_busy<br/>&"]
    end
    
    %% 信号流向 - 请求路径
    EXT_REQ --> WR_SYNC
    EXT_REQ --> RD_SYNC
    
    %% 时钟域内信号流
    WR_CLK --> WR_SYNC
    WR_RST --> WR_SYNC
    WR_SYNC --> WR_CLEAR_OUT
    WR_CLEAR_OUT --> WR_DONE_REG
    WR_DONE_REG --> WR_DELAY
    WR_DELAY --> WR_DONE_DELAY
    
    RD_CLK --> RD_SYNC
    RD_RST --> RD_SYNC
    RD_SYNC --> RD_CLEAR_OUT
    RD_CLEAR_OUT --> RD_DONE_REG
    RD_DONE_REG --> RD_DELAY
    RD_DELAY --> RD_DONE_DELAY
    
    %% 参数化控制
    PARAM_DELAY -.-> WR_DELAY
    PARAM_DELAY -.-> RD_DELAY
    
    %% 主时钟域同步
    WR_DONE_DELAY --> WR_MAIN_SYNC
    RD_DONE_DELAY --> RD_MAIN_SYNC
    MAIN_CLK --> WR_MAIN_SYNC
    MAIN_CLK --> RD_MAIN_SYNC
    MAIN_RST --> WR_MAIN_SYNC
    MAIN_RST --> RD_MAIN_SYNC
    
    %% 应答路径
    WR_MAIN_SYNC --> ACK_LOGIC
    RD_MAIN_SYNC --> ACK_LOGIC
    ACK_LOGIC --> EXT_ACK
    
    %% 忙状态路径
    EXT_REQ --> BUSY_LOGIC
    ACK_LOGIC --~--> BUSY_LOGIC
    BUSY_LOGIC --> EXT_BUSY
    
    %% 样式定义
    classDef external fill:#e1f5fe,stroke:#01579b,stroke-width:3px
    classDef sync fill:#f8bbd9,stroke:#c2185b,stroke-width:2px
    classDef wrDomain fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef rdDomain fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef param fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef logic fill:#fce4ec,stroke:#880e4f,stroke-width:2px
    
    class EXT_REQ,EXT_ACK,EXT_BUSY external
    class WR_SYNC,RD_SYNC sync
    class WR_CLK,WR_RST,WR_CLEAR_OUT,WR_DONE_REG,WR_DELAY,WR_DONE_SYNC wrDomain
    class RD_CLK,RD_RST,RD_CLEAR_OUT,RD_DONE_REG,RD_DELAY,RD_DONE_SYNC rdDomain
    class PARAM_DELAY,PARAM_WR,PARAM_RD param
    class ACK_LOGIC,BUSY_LOGIC logic
```

### 内部信号流程

1. **请求同步阶段**
   - 外部`sync_clear_req`同时输入到两个`sync2_cell_rstb`同步器
   - 分别在`wr_clk`和`rd_clk`域产生同步的清空信号

2. **域内处理阶段**
   - 各域检测到清空信号后立即设置完成标志
   - 通过可配置的`bus_delay`模块增加稳定延迟
   - 确保清空操作有足够时间完成

3. **完成同步阶段**
   - 根据参数配置选择完成信号的同步目标域
   - 使用额外的`sync2_cell_rstb`进行跨域同步
   - 实现灵活的时钟域汇总策略

4. **状态输出阶段**
   - `sync_clear_ack`: 两个域完成信号的逻辑与
   - `sync_clear_busy`: 请求有效但未完成的状态指示

## 参数化说明

### 参数定义

| 参数名称 | 类型 | 默认值 | 取值范围 | 功能说明 |
|----------|------|--------|----------|----------|
| `CLEAR_DONE_DELAY_CYCLES` | integer | 3 | 1-15 | 清空完成信号延迟周期数 |

### 参数详细说明

#### CLEAR_DONE_DELAY_CYCLES

**功能**: 控制清空完成信号的延迟周期数，确保内部状态稳定后再进行跨域同步

**选择建议**:
```verilog
// 标准应用 - 推荐值
.CLEAR_DONE_DELAY_CYCLES(3)
```

**设计说明**:
- 延迟周期数应该大于等于同步器级数，确保状态稳定
- AFIFO内部multi_bit_sync2_cell_rstb保持两级打拍不变，则不改变该参数
- 过小的延迟可能导致状态不稳定
- 过大的延迟会增加清空完成时间

### 时钟域配置

**新设计特点**:

- 统一使用`main_clk`域进行状态汇总
- 简化了参数配置，提高了可维护性
- 减少了时钟域选择的复杂性

**版本信息**: afifo_clear_sync v1.0  
**更新日期**: 2025年10月10日  
**兼容性**: 支持Verilog-2001及以上标准  
**依赖模块**: sync2_cell_rstb, bus_delay