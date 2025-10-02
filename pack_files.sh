
#!/bin/bash

# --- 配置 ---
# 需要搜索的目录，'.' 代表当前目录
SEARCH_DIR="."

# 输出文件名
OUTPUT_FILE="packed_files.txt"
# --- 配置结束 ---

# 检查输出文件是否存在，如果存在则删除，以防重复打包
if [ -f "$OUTPUT_FILE" ]; then
    rm "$OUTPUT_FILE"
    echo "已删除旧的打包文件: $OUTPUT_FILE"
fi

echo "开始打包 '$SEARCH_DIR' 目录下的所有文本文件到 '$OUTPUT_FILE'..."

# 使用find命令查找所有普通文件，然后逐一判断其类型
find "$SEARCH_DIR" -type f -print0 | while IFS= read -r -d '' file; do
    # 使用 file 命令来检查文件的MIME类型
    # -b, --brief     不输出文件名
    # --mime-type   输出MIME类型字符串
    MIME_TYPE=$(file -b --mime-type "$file")

    # 检查MIME类型是否以 "text/" 开头，这是判断一个文件是否为文本文件的可靠方法
    if [[ "$MIME_TYPE" == text/* ]]; then
        # 获取相对路径
        relative_path="${file#$SEARCH_DIR/}"
        relative_path="${relative_path#./}"

        echo "正在处理文本文件: $file"
        # 将包含相对路径的头部追加到输出文件
        echo "---_PATH_START_---${relative_path}---_PATH_END_---" >> "$OUTPUT_FILE"
        # 将文件内容追加到输出文件
        cat "$file" >> "$OUTPUT_FILE"
        # 追加一个换行符，以防原文件末尾没有换行符
        echo "" >> "$OUTPUT_FILE"
        # 将尾部追加到输出文件
        echo "