import { defineNoteConfig, defineNotesConfig } from "vuepress-theme-plume";

/* =================== locale: zh-CN ======================= */

const zhAndroidNote = defineNoteConfig({
  dir: "android",
  link: "/android",
  sidebar: "auto",
});

const zhDdiaNote = defineNoteConfig({
  dir: "ddia",
  link: "/ddia",
  sidebar: "auto",
});

const zhDemoNote = defineNoteConfig({
  dir: "demo",
  link: "/demo",
  sidebar: "auto",
});

const zhFlutterNote = defineNoteConfig({
  dir: "flutter",
  link: "/flutter",
  sidebar: "auto",
});

const zhUiNote = defineNoteConfig({
  dir: "ui",
  link: "/ui",
  sidebar: "auto",
});

export const zhNotes = defineNotesConfig({
  dir: "notes",
  link: "/",
  notes: [zhAndroidNote, zhDdiaNote, zhDemoNote, zhFlutterNote, zhUiNote],
});

/* =================== locale: en-US ======================= */

const enAndroidNote = defineNoteConfig({
  dir: "android",
  link: "/android",
  sidebar: "auto",
});

const enDdiaNote = defineNoteConfig({
  dir: "ddia",
  link: "/ddia",
  sidebar: "auto",
});

const enDemoNote = defineNoteConfig({
  dir: "demo",
  link: "/demo",
  sidebar: "auto",
});

const enFlutterNote = defineNoteConfig({
  dir: "flutter",
  link: "/flutter",
  sidebar: "auto",
});

const enUiNote = defineNoteConfig({
  dir: "ui",
  link: "/ui",
  sidebar: "auto",
});

export const enNotes = defineNotesConfig({
  dir: "en/notes",
  link: "/en/",
  notes: [enAndroidNote, enDdiaNote, enDemoNote, enFlutterNote, enUiNote],
});
