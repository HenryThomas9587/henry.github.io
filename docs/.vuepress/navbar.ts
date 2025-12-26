import { defineNavbarConfig } from "vuepress-theme-plume";

export const zhNavbar = defineNavbarConfig([
  { text: "首页", link: "/" },
  { text: "博客", link: "/blog/" },
  { text: "标签", link: "/blog/tags/" },
  { text: "归档", link: "/blog/archives/" },
  {
    text: "笔记",
    items: [
      { text: "Android", link: "/notes/android/README.md" },
      { text: "DDIA 学习笔记", link: "/notes/ddia/README.md" },
      { text: "Demo", link: "/notes/demo/README.md" },
      { text: "Flutter", link: "/notes/flutter/README.md" },
      { text: "Ui", link: "/notes/ui/README.md" },
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
      { text: "Android", link: "/en/notes/android/README.md" },
      { text: "Demo", link: "/en/notes/demo/README.md" },
      { text: "Flutter", link: "/en/notes/flutter/README.md" },
    ],
  },
]);
