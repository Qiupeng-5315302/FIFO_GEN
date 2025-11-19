/***************************************
#
#           Filename: afifo_clear_sync.v
#
#           Function: AFIFO跨时钟域同步清空控制模块
#                    - 将外部清空请求同步到读写时钟域
#                    - 实现握手协议确保清空完成
#                    - 统一使用主时钟域进行状态同步
#
#           Features: - 使用dig_cell.v中的sync2_cell_rstb进行跨域同步
#                    - 清空请求同步到wr_clk和rd_clk域
#                    - 完成状态统一同步到main_clk域
#                    - 完整的握手协议实现
#                    - 可配置的延迟周期
#
#           Notice:   - 需要提供main_clk和main_rst_n主时钟域信号
#                    - sync_clear_req需保持至少3个较慢时钟周期
#                    - 依赖dig_cell.v和bus_delay模块
#                    - 清空完成状态在主时钟域产生
#
#           Developer: AI Assistant
#           CreateTime: 2025-10-10
#
***************************************/

module afifo_clear_sync #(
    parameter CLEAR_DONE_DELAY_CYCLES = 3  // 清空完成延迟周期数
)(
    // 时钟和复位
    input  wire wr_clk,                  // 写时钟
    input  wire wr_rst_n,                // 写域复位（低有效）
    input  wire rd_clk,                  // 读时钟
    input  wire rd_rst_n,                // 读域复位（低有效）
    input  wire main_clk,                // 主控制时钟
    input  wire main_rst_n,              // 主域复位（低有效）

    // 同步清空控制接口
    input  wire sync_clear_req,          // 外部同步清空请求
    output wire sync_clear_ack,          // 同步清空完成应答
    output wire sync_clear_busy,         // 同步清空进行中标志
    
    // 各时钟域的清空控制输出
    output wire wr_domain_clear,         // 写域清空信号
    output wire rd_domain_clear          // 读域清空信号
);
    reg     wr_clear_done;
    reg     d_clear_done;
    wire    wr_done_sync;
    wire    rd_done_sync;
    wire    rd_clear_done_delay;
    wire    wr_clear_done_delay;
    
    // =========================================================================
    // 清空请求同步到各时钟域
    // =========================================================================
    
    // 同步清空请求到写时钟域
    sync2_cell_rstb u_wr_clear_sync (
        .clk     (wr_clk),
        .reset_n (wr_rst_n),
        .data    (sync_clear_req),
        .qout    (wr_domain_clear)
    );
    
    // 同步清空请求到读时钟域
    sync2_cell_rstb u_rd_clear_sync (
        .clk     (rd_clk),
        .reset_n (rd_rst_n),
        .data    (sync_clear_req),
        .qout    (rd_domain_clear)
    );
    
    // =========================================================================
    // 各时钟域清空完成检测
    // =========================================================================
    
    // 写域清空完成标志
    always @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_clear_done <= 1'b0;
        end else if (wr_domain_clear && !wr_clear_done) begin
            wr_clear_done <= 1'b1;              // 检测到清空信号，标记完成
        end else if (!wr_domain_clear) begin
            wr_clear_done <= 1'b0;              // 使用域内同步信号复位，避免CDC问题
        end
    end
    
    // 读域清空完成标志
    always @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_clear_done <= 1'b0;
        end else if (rd_domain_clear && !rd_clear_done) begin
            rd_clear_done <= 1'b1;              // 检测到清空信号，标记完成
        end else if (!rd_domain_clear) begin
            rd_clear_done <= 1'b0;              // 使用域内同步信号复位，避免CDC问题
        end
    end
    

    bus_delay #(
        .DELAY_CYCLES(CLEAR_DONE_DELAY_CYCLES),
        .BUS_WIDTH(1)
    )u_bus_delay_wr_clear_done(
        .clk(wr_clk),
        .rst_n(wr_rst_n),
        .inbus(wr_clear_done),
        .outbus(wr_clear_done_delay)
    );
    

    bus_delay #(
        .DELAY_CYCLES(CLEAR_DONE_DELAY_CYCLES),
        .BUS_WIDTH(1)
    )u_bus_delay_rd_clear_done(
        .clk(rd_clk),
        .rst_n(rd_rst_n),
        .inbus(rd_clear_done),
        .outbus(rd_clear_done_delay)
    );

    // 写域清空信号
    // 读域清空信号

    // =========================================================================
    // 清空完成状态同步
    // =========================================================================

    // 写域完成状态同步逻辑
    sync2_cell_rstb u_wr_done_sync (
        .clk     (main_clk),
        .reset_n (main_rst_n),
        .data    (wr_clear_done_delay),
        .qout    (wr_done_sync)
    );
    
    // 读域完成状态同步逻辑
    sync2_cell_rstb u_rd_done_sync (
        .clk     (main_clk),
        .reset_n (main_rst_n),
        .data    (rd_clear_done_delay),
        .qout    (rd_done_sync)
    );

    
    // =========================================================================
    // 同步清空状态输出逻辑
    // =========================================================================
    
    // 清空完成应答：两个域都完成清空
    assign sync_clear_ack = wr_done_sync && rd_done_sync;
    
    // 清空忙状态：请求已发出但未完成
    assign sync_clear_busy = sync_clear_req && !sync_clear_ack;

endmodule