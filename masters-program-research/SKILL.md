---
name: masters-program-research
description: Research a university's postgraduate taught master's programs relevant to a given undergraduate major (default: Computer Science) plus CS/major-adjacent programs popular with Chinese applicants, then generate a bilingual Google Sheet of application info. Use when the user gives a university's graduate-admissions URL and QS ranking and asks to "同理处理"/调研/汇总/做表格 for that school's master's programs, or asks to repeat the same workflow for a new school or a new target major (e.g. finance instead of CS).
---

# Masters Program Research → Google Sheet

Reproduces the multi-school UK postgraduate research workflow already run for Imperial, KCL, Oxford, Cambridge, Edinburgh, UCL, Manchester, and Bristol. Produces one Google Sheet per school with bilingual (EN/CN) course info, deadlines split by fee status where the school publishes that distinction, and inline 【】 flags on anything not directly verified from the official page.

## Required inputs (ask if missing)

1. **University name** (EN + CN, e.g. "University of Bristol" / "布里斯托大学")
2. **Graduate admissions / course-search URL** (e.g. `https://www.bristol.ac.uk/study/postgraduate/search/`)
3. **QS ranking number** — ask the user for this explicitly every time; do not guess or reuse a stale number from memory. Confirm whether it's the overall QS World University Ranking (the default basis used so far) or a subject ranking — if ambiguous, ask.
4. **Target undergraduate background / major** — defaults to Computer Science if the user doesn't specify a different one (e.g. "这次换成金融背景"). All prompts below use `{{MAJOR}}` (English) / `{{MAJOR_CN}}` (Chinese) as placeholders — substitute the requested field throughout when it's not CS.

If the user says "同理" without restating these, reuse the pattern from the most recent school in this conversation but still ask for the QS number and confirm the URL/major.

## Step 1 — Research (background Agent)

Launch one `general-purpose` Agent per school (parallel if multiple schools requested at once) with a prompt built from this template. Do not skip any bullet — the accuracy and deadline rules exist because past runs missed real data (a KCL "Overseas fee status" deadline that was on the page but not surfaced, and a UCL visa/non-visa deadline split that a first pass missed).

```
You are researching {{UNIVERSITY_EN}}'s postgraduate taught Master's programs, for a Chinese student
preparing applications for 2027 entry (2026-2027 application cycle).

Start at {{URL}} (use WebFetch) and find the actual course directory/catalogue if the given URL is a
marketing landing page. Find ALL master's programs that are:

1. {{MAJOR}}-adjacent — check the relevant department's full course list thoroughly (for CS: Computer
   Science / Informatics / AI / Data Science / Cyber Security / Robotics / Software Engineering /
   HCI, etc; for other majors, the analogous core department programs). Verify each program's real
   existence and CURRENT exact name via the actual course page — don't assume it matches naming used
   at other universities. Watch for "conversion" courses that explicitly EXCLUDE {{MAJOR}} graduates
   (this has happened at UCL and Bristol) — flag this loudly if found, don't just note it in passing.
2. OR popular among Chinese international applicants AND explicitly open to {{MAJOR}} undergraduate
   background applicants — check the Business School / relevant cross-disciplinary school for
   quantitative programs (finance, analytics, fintech-style courses). Quote or closely paraphrase the
   entry-requirements text; only include if {{MAJOR}} (or a clearly synonymous term) is explicitly
   named as an accepted background. If a program requires several years of prior work experience and
   isn't accessible to a fresh graduate, still report it but flag that clearly rather than silently
   excluding it (the user prefers to decide inclusion/exclusion themselves once informed).

For EACH program found, visit its official course page and extract, IN BOTH ENGLISH AND CHINESE for
the course-name and module-list fields:
1. 专业全称 — "English Name - 中文翻译" format
2. 学院/学部 (Department/Faculty)
3. 学制 (Duration)
4. 上课形式/地点 (Mode of study/location)
5. 学术背景要求 — quote/paraphrase the actual accepted-degree text; state explicitly whether
   {{MAJOR}} is or isn't named
6. 均分/成绩门槛 — UK classification, and a China-specific GPA/percentage/university-band if the
   school publishes one (many UK schools do — check country-specific admissions pages, don't
   fabricate if not found)
7. 雅思要求 (总分/小分) — exact band for THIS course, not just the university-wide default
8. 核心必修课程（英文） AND 核心必修课程（中文）
9. 特色选修课程（英文） AND 特色选修课程（中文）
10. 申请截止日期 (分轮次) — CRITICAL: actively look for deadlines split by "fee status" (Home vs
    Overseas/International) or by funding-related early deadlines, in the course page AND its
    "how to apply"/"fees and funding"/"key dates" tabs. Report BOTH labelled dates if they exist.
    Do not write "rolling admission" until you've actually checked for a specific date and found none.
11. 学费 (海外生) — per year in local currency
12. 官网专业直达链接
13. 申请费用 (or "none found")
14. 学科优势 — research groups/labs, industry ties, ranking notes, career stats if stated

ACCURACY RULES (non-negotiable):
- Never fabricate a number (fee, IELTS score, deadline, GPA conversion, ranking). If not found on the
  official page, write "官网未注明".
- If a figure had to come from a third-party aggregator because the official page 403'd, paywalled, or
  was JS-rendered, flag it INLINE next to the number itself as
  "【未直接核实于官网原文，来自第三方来源，需人工核对】" — not just in a footnote.
- Only include programs confirmed on a real page at the university's own domain. Give the exact URL.
- Prioritize stable, recurring programs over one-off/pilot ones, but don't silently drop a real result
  just because it looks unstable — flag it instead.

For "学校名称" use "{{UNIVERSITY_CN}} ({{UNIVERSITY_EN}})" every row. For "2027年QS排名" use the plain
number "{{QS_RANK}}" every row (no parenthetical explanation needed unless the user asked for one).
For "当前状态/备注" use "调研中" every row.

Report back in plain text, one block per program, fields labeled in Chinese exactly as above, ready to
transcribe into a spreadsheet with these columns:
2027年QS排名 | 学校名称 | 专业全称 | 学院/学部 | 学制 | 上课形式/地点 | 学术背景要求 | 均分/成绩门槛 |
雅思要求(总分/小分) | 核心必修课程（英文） | 核心必修课程（中文） | 特色选修课程（英文） |
特色选修课程（中文） | 申请截止日期(分轮次) | 学费(海外生) | 官网专业直达链接 | 备注 | 当前状态/备注 |
学科优势
```

## Step 2 — Build the CSV

Write a small Python script (via Write + Bash) that builds the row list and writes with `csv.QUOTE_MINIMAL`, matching the 19-column header above exactly (18 data columns after 学校名称... actually count: 2027年QS排名, 学校名称, 专业全称, 学院/学部, 学制, 上课形式/地点, 学术背景要求, 均分/成绩门槛, 雅思要求, 核心必修课程英文, 核心必修课程中文, 特色选修课程英文, 特色选修课程中文, 申请截止日期, 学费, 官网链接, 备注, 当前状态, 学科优势). Don't hand-write the CSV inline in a tool call — Python + `csv.writer` avoids quoting bugs when fields contain commas/quotes/semicolons, which they will.

Carry every 【...】 flag from the research output straight into the corresponding cell — don't smooth them over or drop them for readability.

## Step 3 — Create the Google Sheet

Read the generated CSV back, then call `mcp__claude_ai_Google_Drive__create_file` with:
- `title`: "{{UNIVERSITY_EN}} 计算机相关硕士项目申请信息汇总" (swap "计算机相关" for the actual major in Chinese if not CS)
- `textContent`: full CSV content
- `contentMimeType`: `text/csv`

This auto-converts to a native Google Sheet. If it errors with an auth/token message, tell the user Drive access needs reconnecting in claude.ai Settings → Connectors, and wait — don't retry blindly.

There is no update/overwrite tool for an existing Sheet's content — a second `create_file` call always makes a NEW file with a new URL. If redoing a school, say so plainly and give the new link; don't claim the old one was updated.

## Step 4 — Report to the user

Keep it tight:
- Link(s) to the new Sheet(s)
- Program count and a one-line breakdown by department/category
- Any program that's a same-name "conversion" course excluding the target major (loud callout, this trips people up)
- Any program lacking an explicit accepted-background match for {{MAJOR}} (included anyway per the accuracy rule, but say so)
- The single most important 【】-flagged item if one stands out (e.g. conflicting deadline sources, conflicting fee numbers)
- Reminder that deadline/fee data reflects the currently published cycle (often still 2026-entry) since most UK schools haven't opened 2027-entry pages yet

## Notes for switching to a non-CS major

Only the `{{MAJOR}}` / `{{MAJOR_CN}}` substitution and the department-search targets change (e.g. for Finance: target the Business/Economics school's core taught masters instead of Computer Science's department, and look for CS-styled "friendly to other backgrounds" cross-checks in reverse — e.g. does the Finance MSc accept Engineering/Physics backgrounds). Everything else — bilingual columns, deadline fee-status digging, inline 【】 flagging, QS-number-as-plain-number, one-Sheet-per-school — stays identical.
