#!/bin/bash

# GhostTrack Web 离线包压缩工具
# 将导出的镜像和配置文件打包压缩

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📦 GhostTrack Web 离线包压缩工具${NC}"
echo "=============================================="

# 检查是否有导出目录
EXPORT_DIRS=$(find . -maxdepth 1 -name "ghosttrack-offline-*" -type d 2>/dev/null)

if [ -z "$EXPORT_DIRS" ]; then
    echo -e "${RED}❌ 未找到离线导出目录${NC}"
    echo "请先运行 ./docker-export.sh 创建离线包"
    exit 1
fi

echo -e "${BLUE}🔍 发现以下导出目录:${NC}"
index=1
dir_array=()
for dir in $EXPORT_DIRS; do
    size=$(du -sh "$dir" | cut -f1)
    echo -e "  ${YELLOW}$index) $(basename "$dir")${NC} (${size})"
    dir_array[$index]="$dir"
    index=$((index + 1))
done

echo ""
read -p "请选择要压缩的目录 (输入序号): " choice

if [[ ! "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -ge "$index" ]; then
    echo -e "${RED}❌ 无效选择${NC}"
    exit 1
fi

SELECTED_DIR="${dir_array[$choice]}"
DIR_NAME=$(basename "$SELECTED_DIR")

echo -e "${BLUE}📁 选择目录: ${YELLOW}$DIR_NAME${NC}"

# 选择压缩格式
echo ""
echo -e "${YELLOW}选择压缩格式:${NC}"
echo "1) tar.gz (推荐，兼容性好)"
echo "2) tar.bz2 (更小体积，压缩时间长)"
echo "3) zip (Windows友好)"
echo ""

read -p "请选择 (1-3): " format_choice

case $format_choice in
    1)
        COMPRESS_CMD="tar -czf"
        EXTENSION="tar.gz"
        echo -e "${BLUE}📦 压缩格式: ${YELLOW}tar.gz${NC}"
        ;;
    2)
        COMPRESS_CMD="tar -cjf"
        EXTENSION="tar.bz2"
        echo -e "${BLUE}📦 压缩格式: ${YELLOW}tar.bz2${NC}"
        ;;
    3)
        if ! command -v zip &> /dev/null; then
            echo -e "${RED}❌ zip 命令未找到，请安装 zip 工具${NC}"
            exit 1
        fi
        COMPRESS_CMD="zip -r"
        EXTENSION="zip"
        echo -e "${BLUE}📦 压缩格式: ${YELLOW}zip${NC}"
        ;;
    *)
        echo -e "${RED}❌ 无效选择${NC}"
        exit 1
        ;;
esac

# 创建压缩包
OUTPUT_FILE="${DIR_NAME}.${EXTENSION}"

echo ""
echo -e "${BLUE}🗜️  开始压缩...${NC}"
echo -e "   源目录: ${YELLOW}$SELECTED_DIR${NC}"
echo -e "   输出文件: ${YELLOW}$OUTPUT_FILE${NC}"
echo ""

# 显示压缩进度
if [ "$format_choice" = "3" ]; then
    # zip格式
    $COMPRESS_CMD "$OUTPUT_FILE" "$SELECTED_DIR"
else
    # tar格式
    $COMPRESS_CMD "$OUTPUT_FILE" "$SELECTED_DIR"
fi

# 检查压缩结果
if [ -f "$OUTPUT_FILE" ]; then
    ORIGINAL_SIZE=$(du -sh "$SELECTED_DIR" | cut -f1)
    COMPRESSED_SIZE=$(du -sh "$OUTPUT_FILE" | cut -f1)
    
    echo ""
    echo -e "${GREEN}✅ 压缩完成！${NC}"
    echo "=============================================="
    echo -e "${BLUE}📊 压缩统计:${NC}"
    echo -e "   原始大小: ${YELLOW}$ORIGINAL_SIZE${NC}"
    echo -e "   压缩后:   ${YELLOW}$COMPRESSED_SIZE${NC}"
    echo -e "   压缩文件: ${YELLOW}$OUTPUT_FILE${NC}"
    
    # 计算MD5校验和
    if command -v md5sum &> /dev/null; then
        MD5=$(md5sum "$OUTPUT_FILE" | cut -d' ' -f1)
        echo -e "   MD5校验:  ${YELLOW}$MD5${NC}"
    elif command -v md5 &> /dev/null; then
        MD5=$(md5 -q "$OUTPUT_FILE")
        echo -e "   MD5校验:  ${YELLOW}$MD5${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}🚀 传输建议:${NC}"
    echo ""
    echo -e "${BLUE}💡 上传到VPS:${NC}"
    echo "scp $OUTPUT_FILE user@your-vps:/path/to/deploy/"
    echo ""
    echo -e "${BLUE}💡 在VPS上解压:${NC}"
    case $format_choice in
        1)
            echo "tar -xzf $OUTPUT_FILE"
            ;;
        2)
            echo "tar -xjf $OUTPUT_FILE"
            ;;
        3)
            echo "unzip $OUTPUT_FILE"
            ;;
    esac
    echo "cd $DIR_NAME"
    echo "./deploy-offline.sh"
    
    echo ""
    echo -e "${GREEN}🎉 离线部署包已压缩完成！${NC}"
    
else
    echo -e "${RED}❌ 压缩失败${NC}"
    exit 1
fi