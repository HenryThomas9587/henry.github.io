#!/bin/bash
# VuePress 笔记配置生成器
# 自动扫描 docs/notes 目录，生成 navbar.ts 和 notes.ts 配置

set -e

NOTES_DIR="docs/notes"
EN_NOTES_DIR="docs/en/notes"
NAVBAR_FILE="docs/.vuepress/navbar.ts"
NOTES_FILE="docs/.vuepress/notes.ts"

# 颜色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== VuePress 笔记配置生成器 ===${NC}\n"

# 扫描笔记目录
scan_notes() {
    local base_dir=$1
    local notes=()

    if [ ! -d "$base_dir" ]; then
        return
    fi

    # 查找所有顶级目录（排除以 . 开头的目录）
    for dir in "$base_dir"/*/; do
        if [ -d "$dir" ]; then
            local dirname=$(basename "$dir")
            # 排除隐藏目录和特殊目录
            if [[ ! "$dirname" =~ ^\. ]] && [ "$dirname" != "node_modules" ]; then
                notes+=("$dirname")
            fi
        fi
    done

    echo "${notes[@]}"
}

# 获取目录的显示名称（从 README.md 的 title 字段或目录名）
get_display_name() {
    local dir=$1
    local readme="$dir/README.md"

    if [ -f "$readme" ]; then
        # 尝试从 frontmatter 读取 title，处理可能的引号
        local title=$(grep -m 1 "^title:" "$readme" | sed 's/title: *//' | sed 's/^["'\'']\(.*\)["'\'']$/\1/' | tr -d '\r\n')
        if [ -n "$title" ]; then
            echo "$title"
            return
        fi
    fi

    # 使用目录名作为 fallback
    basename "$dir"
}

# 转换目录名为合法的变量名（移除连字符，转换为驼峰命名）
to_var_name() {
    local name=$1
    # 将连字符分隔的单词转换为驼峰命名: ui-components -> UiComponents
    echo "$name" | awk -F'-' '{for(i=1;i<=NF;i++){$i=toupper(substr($i,1,1)) substr($i,2)}}1' OFS=''
}

# 生成 navbar.ts
generate_navbar() {
    echo -e "${YELLOW}生成 navbar.ts...${NC}"

    local zh_notes=($(scan_notes "$NOTES_DIR"))
    local en_notes=($(scan_notes "$EN_NOTES_DIR"))

    cat > "$NAVBAR_FILE" <<'EOF'
import { defineNavbarConfig } from "vuepress-theme-plume";

export const zhNavbar = defineNavbarConfig([
  { text: "首页", link: "/" },
  { text: "博客", link: "/blog/" },
  { text: "标签", link: "/blog/tags/" },
  { text: "归档", link: "/blog/archives/" },
  {
    text: "笔记",
    items: [
EOF

    # 添加中文笔记导航
    for note in "${zh_notes[@]}"; do
        local display_name=$(get_display_name "$NOTES_DIR/$note")
        # 首字母大写处理
        local capitalized=$(echo "$display_name" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
        echo "      { text: \"$capitalized\", link: \"/notes/$note/README.md\" }," >> "$NAVBAR_FILE"
    done

    cat >> "$NAVBAR_FILE" <<'EOF'
    ],
  },
]);

export const enNavbar = defineNavbarConfig([
  { text: "Home", link: "/en/" },
  { text: "Blog", link: "/en/blog/" },
  { text: "Tags", link: "/en/blog/tags/" },
  { text: "Archives", link: "/en/blog/archives/" },
  {
    text: "Notes",
    items: [
EOF

    # 添加英文笔记导航
    if [ ${#en_notes[@]} -gt 0 ]; then
        for note in "${en_notes[@]}"; do
            local display_name=$(get_display_name "$EN_NOTES_DIR/$note")
            local capitalized=$(echo "$display_name" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
            echo "      { text: \"$capitalized\", link: \"/en/notes/$note/README.md\" }," >> "$NAVBAR_FILE"
        done
    else
        # 使用中文笔记作为英文导航的备用
        for note in "${zh_notes[@]}"; do
            local display_name=$(get_display_name "$NOTES_DIR/$note")
            local capitalized=$(echo "$display_name" | awk '{for(i=1;i<=NF;i++)sub(/./,toupper(substr($i,1,1)),$i)}1')
            echo "      { text: \"$capitalized\", link: \"/en/notes/$note/README.md\" }," >> "$NAVBAR_FILE"
        done
    fi

    cat >> "$NAVBAR_FILE" <<'EOF'
    ],
  },
]);
EOF

    echo -e "${GREEN}✓ navbar.ts 生成成功${NC}"
}

# 生成 notes.ts
generate_notes() {
    echo -e "${YELLOW}生成 notes.ts...${NC}"

    local zh_notes=($(scan_notes "$NOTES_DIR"))

    cat > "$NOTES_FILE" <<'EOF'
import { defineNoteConfig, defineNotesConfig } from "vuepress-theme-plume";

/* =================== locale: zh-CN ======================= */

EOF

    # 生成每个笔记的配置
    for note in "${zh_notes[@]}"; do
        local var_name="zh$(to_var_name "$note")Note"
        cat >> "$NOTES_FILE" <<EOF
const $var_name = defineNoteConfig({
  dir: "$note",
  link: "/$note",
  sidebar: "auto",
});

EOF
    done

    # 生成中文 notes 配置
    echo "export const zhNotes = defineNotesConfig({" >> "$NOTES_FILE"
    echo "  dir: \"notes\"," >> "$NOTES_FILE"
    echo "  link: \"/\"," >> "$NOTES_FILE"

    # 检查是否有笔记
    if [ ${#zh_notes[@]} -eq 0 ]; then
        echo "  notes: []," >> "$NOTES_FILE"
    else
        echo -n "  notes: [" >> "$NOTES_FILE"

        local first=true
        for note in "${zh_notes[@]}"; do
            local var_name="zh$(to_var_name "$note")Note"
            if [ "$first" = true ]; then
                echo -n "$var_name" >> "$NOTES_FILE"
                first=false
            else
                echo -n ", $var_name" >> "$NOTES_FILE"
            fi
        done

        echo "]," >> "$NOTES_FILE"
    fi
    echo "});" >> "$NOTES_FILE"
    echo "" >> "$NOTES_FILE"

    # 生成英文配置
    cat >> "$NOTES_FILE" <<'EOF'
/* =================== locale: en-US ======================= */

EOF

    for note in "${zh_notes[@]}"; do
        local var_name="en$(to_var_name "$note")Note"
        cat >> "$NOTES_FILE" <<EOF
const $var_name = defineNoteConfig({
  dir: "$note",
  link: "/$note",
  sidebar: "auto",
});

EOF
    done

    echo "export const enNotes = defineNotesConfig({" >> "$NOTES_FILE"
    echo "  dir: \"en/notes\"," >> "$NOTES_FILE"
    echo "  link: \"/en/\"," >> "$NOTES_FILE"

    # 检查是否有笔记
    if [ ${#zh_notes[@]} -eq 0 ]; then
        echo "  notes: []," >> "$NOTES_FILE"
    else
        echo -n "  notes: [" >> "$NOTES_FILE"

        first=true
        for note in "${zh_notes[@]}"; do
            local var_name="en$(to_var_name "$note")Note"
            if [ "$first" = true ]; then
                echo -n "$var_name" >> "$NOTES_FILE"
                first=false
            else
                echo -n ", $var_name" >> "$NOTES_FILE"
            fi
        done

        echo "]," >> "$NOTES_FILE"
    fi
    echo "});" >> "$NOTES_FILE"

    echo -e "${GREEN}✓ notes.ts 生成成功${NC}"
}

# 显示检测到的笔记
show_detected_notes() {
    local zh_notes=($(scan_notes "$NOTES_DIR"))

    echo -e "${BLUE}检测到的笔记分类:${NC}"
    for note in "${zh_notes[@]}"; do
        local display_name=$(get_display_name "$NOTES_DIR/$note")
        echo -e "  - ${GREEN}$note${NC} ($display_name)"
    done
    echo ""
}

# 主函数
main() {
    # 检查必要的目录
    if [ ! -d "$NOTES_DIR" ]; then
        echo -e "${YELLOW}警告: $NOTES_DIR 目录不存在${NC}"
        exit 1
    fi

    show_detected_notes
    generate_navbar
    generate_notes

    echo -e "\n${GREEN}=== 配置生成完成 ===${NC}"
    echo -e "生成的文件:"
    echo -e "  - $NAVBAR_FILE"
    echo -e "  - $NOTES_FILE"
    echo -e "\n${BLUE}提示: 运行 'pnpm run docs:dev' 查看效果${NC}"
}

main "$@"
