# gen-note-config Skill 使用示例

## 场景 1：添加新笔记分类

假设你想添加一个新的笔记分类 "Python 学习"：

```bash
# 1. 创建笔记目录
mkdir -p docs/notes/python

# 2. 创建 README.md 并添加 frontmatter
cat > docs/notes/python/README.md <<'EOF'
---
title: Python 学习笔记
---

# Python 学习笔记

这里是 Python 相关的学习笔记。
EOF

# 3. 运行配置生成 skill
bash .claude/skills/gen-note-config/gen-note-config.sh

# 4. 查看变更
git diff docs/.vuepress/navbar.ts docs/.vuepress/notes.ts
```

**预期结果：**

navbar.ts 会自动添加：
```typescript
{ text: "Python", link: "/notes/python/README.md" }
```

notes.ts 会自动添加：
```typescript
const zhPythonNote = defineNoteConfig({
  dir: "python",
  link: "/python",
  sidebar: "auto",
});
```

## 场景 2：自定义笔记显示名称

如果你不想使用默认的目录名，可以在 README.md 中指定 title：

```bash
# 创建 UI 组件库笔记
mkdir -p docs/notes/ui-components

# 自定义显示名称为 "UI 组件库" 而不是 "Ui-Components"
cat > docs/notes/ui-components/README.md <<'EOF'
---
title: UI 组件库
---

# UI 组件库

常用 UI 组件的使用说明。
EOF

# 生成配置
bash .claude/skills/gen-note-config/gen-note-config.sh
```

**结果：**
导航栏会显示 "UI 组件库" 而不是 "Ui-Components"

## 场景 3：重新整理笔记结构

当你重新整理笔记分类，删除或重命名目录后：

```bash
# 删除旧的 demo 笔记
rm -rf docs/notes/demo

# 重命名目录
mv docs/notes/ui docs/notes/ui-design

# 更新 README.md 的 title
sed -i 's/title: .*/title: UI 设计/' docs/notes/ui-design/README.md

# 一键重新生成所有配置
bash .claude/skills/gen-note-config/gen-note-config.sh
```

配置文件会自动更新，移除 demo，添加 ui-design。

## 场景 4：与 Git 工作流集成

### 在 pre-commit hook 中使用

创建 `.git/hooks/pre-commit`：

```bash
#!/bin/bash
# 检查 docs/notes 目录是否有变更
if git diff --cached --name-only | grep -q "^docs/notes/"; then
  echo "检测到笔记变更，重新生成配置..."
  bash .claude/skills/gen-note-config/gen-note-config.sh

  # 自动添加生成的配置文件到暂存区
  git add docs/.vuepress/navbar.ts docs/.vuepress/notes.ts
fi
```

### 在 GitHub Actions 中验证

在 `.github/workflows/check-notes.yml` 中添加：

```yaml
name: Check Notes Config

on:
  pull_request:
    paths:
      - 'docs/notes/**'

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate notes config
        run: bash .claude/skills/gen-note-config/gen-note-config.sh

      - name: Check if config is up to date
        run: |
          if ! git diff --quiet; then
            echo "❌ Notes config is out of date!"
            echo "Please run: bash .claude/skills/gen-note-config/gen-note-config.sh"
            git diff
            exit 1
          fi
          echo "✅ Notes config is up to date!"
```

## 场景 5：批量添加笔记分类

当你需要一次性添加多个笔记分类：

```bash
# 创建多个笔记目录
notes=(
  "javascript:JavaScript 基础"
  "typescript:TypeScript 进阶"
  "react:React 开发"
  "vue:Vue.js 实战"
)

for note in "${notes[@]}"; do
  IFS=: read -r dir title <<< "$note"

  mkdir -p "docs/notes/$dir"

  cat > "docs/notes/$dir/README.md" <<EOF
---
title: $title
---

# $title

学习笔记目录
EOF
done

# 一次性生成所有配置
bash .claude/skills/gen-note-config/gen-note-config.sh
```

## 场景 6：调试和验证

### 查看脚本检测到的笔记

```bash
# 运行脚本会输出检测到的笔记分类
bash .claude/skills/gen-note-config/gen-note-config.sh

# 输出示例：
# 检测到的笔记分类:
#   - android (Android Framework)
#   - flutter (Flutter 开发指南)
#   - ui (UI 设计)
```

### 验证生成的配置

```bash
# 检查 TypeScript 语法
pnpm run docs:build

# 或者使用 TypeScript 编译器
npx tsc --noEmit docs/.vuepress/navbar.ts
npx tsc --noEmit docs/.vuepress/notes.ts
```

### 与原配置对比

```bash
# 备份原配置
cp docs/.vuepress/navbar.ts navbar.ts.old
cp docs/.vuepress/notes.ts notes.ts.old

# 生成新配置
bash .claude/skills/gen-note-config/gen-note-config.sh

# 使用 diff 查看差异
diff -u navbar.ts.old docs/.vuepress/navbar.ts
diff -u notes.ts.old docs/.vuepress/notes.ts
```

## 场景 7：恢复到备份

如果生成的配置有问题，需要恢复：

```bash
# 方法 1: 使用备份文件
cp docs/.vuepress/navbar.ts.backup docs/.vuepress/navbar.ts
cp docs/.vuepress/notes.ts.backup docs/.vuepress/notes.ts

# 方法 2: 使用 Git 恢复
git restore docs/.vuepress/navbar.ts docs/.vuepress/notes.ts

# 方法 3: 查看 Git 历史版本
git log --oneline -- docs/.vuepress/navbar.ts
git checkout <commit-hash> -- docs/.vuepress/navbar.ts
```

## 高级用法

### 自定义脚本参数

如果你需要自定义脚本行为，可以修改脚本中的变量：

```bash
# 编辑脚本
nano .claude/skills/gen-note-config/gen-note-config.sh

# 修改这些变量：
NOTES_DIR="docs/notes"              # 中文笔记目录
EN_NOTES_DIR="docs/en/notes"        # 英文笔记目录
NAVBAR_FILE="docs/.vuepress/navbar.ts"  # 导航栏配置文件
NOTES_FILE="docs/.vuepress/notes.ts"    # 笔记配置文件
```

### 扩展脚本功能

添加自定义逻辑，例如排除某些目录：

```bash
# 在 scan_notes 函数中添加过滤条件
if [[ ! "$dirname" =~ ^\\. ]] &&
   [ "$dirname" != "node_modules" ] &&
   [ "$dirname" != "drafts" ]; then  # 排除 drafts 目录
    notes+=("$dirname")
fi
```

## 常见问题

### Q: 为什么我的笔记没有被检测到？

**A:** 检查以下几点：
1. 目录是否在 `docs/notes/` 下的**第一层**
2. 目录名是否以 `.` 开头（隐藏目录会被排除）
3. 使用 `tree docs/notes -L 1` 查看目录结构

### Q: 如何改变笔记的显示顺序？

**A:** 脚本默认按字母顺序排序。如果需要自定义顺序，可以：
1. 手动编辑生成的 `navbar.ts` 和 `notes.ts`
2. 或修改脚本的排序逻辑

### Q: 生成的配置导致构建失败

**A:**
1. 检查 TypeScript 语法：`pnpm run docs:build`
2. 查看错误信息，通常是缺少 README.md 或路径问题
3. 确保每个笔记目录都有 `README.md` 文件

### Q: 如何为英文笔记设置不同的结构？

**A:** 创建 `docs/en/notes/` 目录并添加笔记。脚本会自动检测并生成英文配置。如果没有英文笔记，会使用中文笔记作为备用。

## 性能优化

对于大量笔记分类（>50个）：

```bash
# 使用 find 而不是 for 循环
find "$NOTES_DIR" -maxdepth 1 -type d ! -name ".*" ! -name "node_modules" -printf "%f\n" | sort
```

## 总结

这个 skill 帮助你：
- ✅ 自动化配置文件生成，避免手动编辑错误
- ✅ 快速添加新笔记分类，一键更新配置
- ✅ 保持配置文件与目录结构同步
- ✅ 提升团队协作效率

**建议的工作流程：**
1. 创建新笔记目录和 README.md
2. 运行 `bash .claude/skills/gen-note-config/gen-note-config.sh`
3. 用 `git diff` 查看变更
4. 提交配置文件到 Git
5. 运行 `pnpm run docs:dev` 预览效果
