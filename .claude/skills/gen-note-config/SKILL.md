---
name: gen-note-config
description: 自动扫描 docs/notes 目录，生成 VuePress 配置文件 navbar.ts 和 notes.ts。当需要发布新笔记、更新导航栏、重新生成笔记配置或初始化 VuePress 笔记结构时使用。适用于 vuepress-theme-plume 主题。
---

# VuePress 笔记配置生成器

自动扫描 `docs/notes` 目录结构，根据目录和 README.md 中的 frontmatter 自动生成 VuePress 的导航栏配置和笔记配置文件。

## 功能特性

- 🔍 自动扫描 `docs/notes` 和 `docs/en/notes` 目录
- 📝 从 README.md 的 frontmatter 中提取 `title` 字段作为显示名称
- 🌐 支持中英文双语配置生成
- 🎯 自动生成 `navbar.ts` 和 `notes.ts` 配置文件
- 📊 输出检测到的笔记分类清单

## 使用方法

### 快速使用

在项目根目录运行：

```bash
bash .claude/skills/gen-note-config/gen-note-config.sh
```

### 输出文件

- `docs/.vuepress/navbar.ts` - 导航栏配置（包含中英文）
- `docs/.vuepress/notes.ts` - 笔记配置（包含中英文）

## 前置条件

1. 项目使用 VuePress 2.x 和 vuepress-theme-plume 主题
2. 笔记目录结构：
   ```
   docs/
   ├── notes/
   │   ├── android/
   │   │   └── README.md
   │   ├── flutter/
   │   │   └── README.md
   │   └── demo/
   │       └── README.md
   └── en/
       └── notes/
           └── [对应的英文笔记目录]
   ```

3. 每个笔记目录的 README.md 应包含 frontmatter：
   ```markdown
   ---
   title: Android Framework
   ---

   笔记内容...
   ```

## 工作流程

1. **扫描笔记目录**
   - 扫描 `docs/notes/` 下的所有顶级目录
   - 排除隐藏目录（以 `.` 开头）和 `node_modules`

2. **提取显示名称**
   - 优先从 `README.md` 的 frontmatter 中读取 `title` 字段
   - 如果没有 title 字段，使用目录名作为备选

3. **生成配置文件**
   - 生成 `navbar.ts`：创建导航栏菜单项
   - 生成 `notes.ts`：创建笔记配置，启用自动侧边栏

## 示例输出

### 检测到的笔记分类

```
检测到的笔记分类:
  - android (Android Framework)
  - flutter (Flutter 开发指南)
  - demo (示例笔记)
```

### 生成的 navbar.ts 片段

```typescript
{
  text: "笔记",
  items: [
    { text: "Android", link: "/notes/android/README.md" },
    { text: "Flutter", link: "/notes/flutter/README.md" },
    { text: "Demo", link: "/notes/demo/README.md" },
  ],
}
```

### 生成的 notes.ts 片段

```typescript
const zhAndroidNote = defineNoteConfig({
  dir: "android",
  link: "/android",
  sidebar: "auto",
});

export const zhNotes = defineNotesConfig({
  dir: "notes",
  link: "/",
  notes: [zhAndroidNote, zhFlutterNote, zhDemoNote],
});
```

## 故障排除

### 脚本报错：目录不存在

确保 `docs/notes` 目录存在：
```bash
mkdir -p docs/notes
```

### 没有检测到笔记

检查目录结构：
```bash
tree docs/notes -L 2
```

### 生成的配置无效

1. 检查生成的文件语法：
   ```bash
   cat docs/.vuepress/navbar.ts
   cat docs/.vuepress/notes.ts
   ```

2. 验证 TypeScript 语法（如果安装了 TypeScript）：
   ```bash
   pnpm run docs:build
   ```

## 最佳实践

1. **在添加新笔记分类后运行**
   ```bash
   # 创建新笔记目录
   mkdir -p docs/notes/new-topic
   echo '---\ntitle: 新主题\n---\n# 新主题' > docs/notes/new-topic/README.md

   # 重新生成配置
   bash .claude/skills/gen-note-config/gen-note-config.sh
   ```

2. **与 Git 工作流集成**
   ```bash
   # 生成配置
   bash .claude/skills/gen-note-config/gen-note-config.sh

   # 查看变更
   git diff docs/.vuepress/navbar.ts docs/.vuepress/notes.ts

   # 提交更改
   git add docs/.vuepress/navbar.ts docs/.vuepress/notes.ts
   git commit -m "chore: 更新笔记配置"
   ```

3. **在 CI/CD 中使用**

   可以在 GitHub Actions 中添加自动检查：
   ```yaml
   - name: 检查笔记配置是否最新
     run: |
       bash .claude/skills/gen-note-config/gen-note-config.sh
       if ! git diff --quiet; then
         echo "警告：笔记配置需要更新"
         exit 1
       fi
   ```

## 技术细节

### 支持的目录命名

- ✅ 小写字母：`android`, `flutter`
- ✅ 连字符：`my-notes`, `ui-components`
- ✅ 驼峰命名：自动转换首字母大写用于显示
- ❌ 避免使用：以 `.` 开头的目录、`node_modules`

### 名称转换规则

脚本会将目录名自动转换为适合显示的格式：
- `android` → `Android`
- `flutter` → `Flutter`
- `ui-components` → `Ui-Components`

如果希望自定义显示名称，在 README.md 中添加 title frontmatter：
```markdown
---
title: UI 组件库
---
```

## 相关文档

- [VuePress 官方文档](https://vuepress.vuejs.org/)
- [vuepress-theme-plume 主题文档](https://theme-plume.vuejs.press/)
- [VuePress Notes 配置](https://theme-plume.vuejs.press/config/notes/)

## 注意事项

⚠️ **重要提示**

1. 此脚本会 **完全覆盖** 现有的 `navbar.ts` 和 `notes.ts` 文件
2. 如果你手动修改过这些文件，请先备份
3. 建议将此脚本纳入版本控制，方便团队协作

## 手动备份配置

```bash
# 备份现有配置
cp docs/.vuepress/navbar.ts docs/.vuepress/navbar.ts.backup
cp docs/.vuepress/notes.ts docs/.vuepress/notes.ts.backup

# 运行生成脚本
bash .claude/skills/gen-note-config/gen-note-config.sh

# 如需恢复
# cp docs/.vuepress/navbar.ts.backup docs/.vuepress/navbar.ts
# cp docs/.vuepress/notes.ts.backup docs/.vuepress/notes.ts
```
