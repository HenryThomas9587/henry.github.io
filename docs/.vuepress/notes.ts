import { defineNoteConfig, defineNotesConfig } from "vuepress-theme-plume";

/* =================== locale: zh-CN ======================= */

const zhDemoNote = defineNoteConfig({
  dir: "demo",
  link: "/demo",
  sidebar: ["", "foo", "bar"],
});

const zhAndroidNote = defineNoteConfig({
  dir: "android",
  link: "/android",
  sidebar: "auto",
});

const zhFlutterNote = defineNoteConfig({
  dir: "flutter",
  link: "/flutter",
  sidebar: "auto",
});

export const zhNotes = defineNotesConfig({
  dir: "notes",
  link: "/",
  notes: [zhDemoNote, zhAndroidNote, zhFlutterNote],
});

/* =================== locale: en-US ======================= */

const enDemoNote = defineNoteConfig({
  dir: "demo",
  link: "/demo",
  sidebar: ["", "foo", "bar"],
});

const enAndroidNote = defineNoteConfig({
  dir: "android",
  link: "/android",
  sidebar: ["", "test1", "test2"],
});

const enFlutterNote = defineNoteConfig({
  dir: "flutter",
  link: "/flutter",
  sidebar: ["", "test1", "test2"],
});

export const enNotes = defineNotesConfig({
  dir: "en/notes",
  link: "/en/",
  notes: [enDemoNote, enAndroidNote, enFlutterNote],
});
