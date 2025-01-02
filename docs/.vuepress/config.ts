import { viteBundler } from "@vuepress/bundler-vite";
import { defaultTheme } from "@vuepress/theme-default";
import { defineUserConfig } from "vuepress";
import { join } from "path";

export default defineUserConfig({
  title: "My Documentation Site",
  base: "/henry.github.io/", // 修改这里
  description: "VuePress Starter Project",

  bundler: viteBundler({
    viteOptions: {
      resolve: {
        alias: {
          "@": join(process.cwd(), "./docs/.vuepress/"), // 使用绝对路径
        },
      },
    },
  }),
  theme: defaultTheme({
    navbar: [
      { text: "Home", link: "/" },
      { text: "Guide", link: "/guide/" },
      { text: "API", link: "/api/" },
      {
        text: "External",
        link: "https://www.example.com",
      },
    ],
    sidebar: [
      {
        text: "Getting Started",
        children: ["/", "/guide/"],
      },
      {
        text: "Advanced Topics",
        children: ["/advanced/"],
      },
      {
        text: "API Reference",
        children: ["/api/"],
      },
    ],
  }),
});
