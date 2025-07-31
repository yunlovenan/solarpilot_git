#!/bin/bash

# 设置Jenkins定时任务的脚本
# 每天15:00自动运行移动端测试

echo "设置Jenkins定时任务..."

# 获取当前脚本的绝对路径
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEDULED_SCRIPT="$SCRIPT_DIR/scheduled-run.sh"

# 检查定时脚本是否存在
if [ ! -f "$SCHEDULED_SCRIPT" ]; then
    echo "错误：找不到定时运行脚本 $SCHEDULED_SCRIPT"
    exit 1
fi

# 确保脚本有执行权限
chmod +x "$SCHEDULED_SCRIPT"

# 创建临时crontab文件
TEMP_CRON=$(mktemp)

# 导出当前crontab
crontab -l > "$TEMP_CRON" 2>/dev/null || echo "" > "$TEMP_CRON"

# 检查是否已经存在相同的定时任务
if grep -q "scheduled-run.sh" "$TEMP_CRON"; then
    echo "发现已存在的定时任务，将更新为新的配置..."
    # 删除旧的定时任务行
    sed -i '' '/scheduled-run.sh/d' "$TEMP_CRON"
fi

# 添加新的定时任务（每天15:00运行）
echo "# Jenkins移动端测试定时任务 - 每天15:00运行" >> "$TEMP_CRON"
echo "0 15 * * * $SCHEDULED_SCRIPT" >> "$TEMP_CRON"

# 安装新的crontab
crontab "$TEMP_CRON"

# 清理临时文件
rm "$TEMP_CRON"

echo "✅ 定时任务设置成功！"
echo "📅 任务将在每天15:00自动运行"
echo "📝 日志文件位置: $SCRIPT_DIR/logs/"
echo ""
echo "当前crontab配置:"
crontab -l
echo ""
echo "如需修改时间，请运行: crontab -e"
echo "如需删除定时任务，请运行: crontab -r"
