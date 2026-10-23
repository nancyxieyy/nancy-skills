# nancy-skills

个人常用的 Codex / Claude Code skill 集合。每个 skill 是一个独立目录，包含一个 `SKILL.md`。

使用方法：Codex 用户把对应目录复制到 `~/.codex/skills/<skill名>/`；Claude Code 用户复制到 `~/.claude/skills/<skill名>/`。重新开启会话后即可识别和调用。

| Skill | 功能 | 使用场景 | 使用方法 |
|---|---|---|---|
| [masters-program-research](masters-program-research/SKILL.md) | 调研某所大学的硕士(授课型)项目，筛选出与指定本科专业（默认计算机科学）相关、以及对该专业背景友好且中国学生热门的交叉专业，整理成中英双语字段，生成一份独立的 Google Sheet；截止日期会专门查证是否按 Home/Overseas 分开公布，无法从官网原文核实的数字会用【】标记出来提醒人工核对。 | 准备海外硕士申请、需要横向调研多所学校的可选专业清单和申请信息时；也可以换成其他本科背景（如金融）重复同样的调研流程。 | 直接给出：①学校名称 ②该校研究生招生官网链接 ③QS排名数字（④可选：目标专业背景，默认CS）。可以说"同理处理一下xxx大学"来复用同一套格式。 |
| [clash-verge-static-ip-chain](clash-verge-static-ip-chain/SKILL.md) | 在 macOS 的 Clash Verge Rev 中，把用户自己的订阅节点作为第一跳、认证静态代理作为最终出口，并用 TUN 实现单开关全设备固定 IP；附带持久化增强模板、验收脚本和故障排查。 | 静态代理在公司可用、回家或手机热点不可用；或需要切换网络后仍保持同一公网出口 IP。 | 提供自己的订阅 URL、静态代理协议/地址/端口/账号密码及期望出口 IP；敏感数据只写入本机配置，不提交仓库。 |
