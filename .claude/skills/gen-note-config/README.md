# gen-note-config

VuePress 笔记配置自动生成 Skill

## 快速使用

```bash
bash .claude/skills/gen-note-config/gen-note-config.sh
```

## 功能

自动扫描 `docs/notes` 目录，生成：
- `docs/.vuepress/navbar.ts` - 导航栏配置
- `docs/.vuepress/notes.ts` - 笔记配置

## 文档

- [SKILL.md](SKILL.md) - 完整功能说明和使用文档
- [EXAMPLES.md](EXAMPLES.md) - 详细使用示例和最佳实践

## 适用场景

- ✅ 添加新笔记分类
- ✅ 重新整理笔记结构
- ✅ 快速发布新笔记
- ✅ 保持配置与目录同步

## 要求

- VuePress 2.x + vuepress-theme-plume
- 笔记目录：`docs/notes/`
- 每个笔记分类需要 `README.md` 文件
