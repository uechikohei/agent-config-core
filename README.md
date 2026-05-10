# agent-config-core

Codex と Claude Code の global instruction を、1つの `rule.md` から生成して配信するための公開用 core repository です。

Repository: https://github.com/uechikohei/agent-config-core

基本の役割は、共通ルールを `~/.codex/AGENTS.md` と `~/.claude/CLAUDE.md` に反映することです。Persona Skills Core を使う場合は、任意の deploy option から `persona-skills-core` の CLI を呼び出して、Codex / Claude Code の skill 登録もまとめて確認できます。

## Quick Start

```bash
git clone https://github.com/uechikohei/agent-config-core.git
cd agent-config-core
python3 validate.py
./test.sh
./deploy.sh
```

`rule.md` を編集し、`python3 validate.py` と `./test.sh` を通してから `./deploy.sh` で反映します。

## Persona Skills Core

Persona Skills Core は、この repository の任意拡張として接続できます。

```bash
git clone https://github.com/uechikohei/persona-skills-core.git
PERSONA_SKILLS_ROOT=/path/to/persona-skills-core ./deploy.sh --install-persona-skills
PERSONA_SKILLS_ROOT=/path/to/persona-skills-core ./deploy.sh --persona-skills-status
```

`agent-config-core` を使わず、`persona-skills-core` 側の CLI を直接実行しても登録できます。global instruction に参照 block を足すだけなら agent が repository を辿れるようになりますが、Codex の `$` skill mention や Claude Code の `/` slash skill 候補として出すには、plugin / skill directory の登録が必要です。

<details>
<summary>確認手順</summary>

Codex は新規セッションで `$` を押し、`persona-skills:technical-writing` などが候補に出ることを確認します。

Claude Code は新規セッションで `/` を押し、`/technical-writing` などが候補に出ることを確認します。

最小確認プロンプト:

```text
technical-writing を使って、READMEレビューの進め方を提案してください。
参照した Persona Skills のローカルpathも2件以上書いてください。
```

</details>

<details>
<summary>主なコマンド</summary>

```bash
./deploy.sh
./deploy.sh --check
./deploy.sh --dry-run
PERSONA_SKILLS_ROOT=/path/to/persona-skills-core ./deploy.sh --install-persona-skills
PERSONA_SKILLS_ROOT=/path/to/persona-skills-core ./deploy.sh --persona-skills-status
```

- `python3 validate.py`: `rule.md` に secret や private path らしい文字列がないか確認する
- `./test.sh`: 一時 home で `deploy.sh` の動作を確認する
- `./deploy.sh`: `rule.md` を Codex / Claude Code の global instruction へ配信する

</details>

<details>
<summary>Repository layout</summary>

```text
agent-config-core/
├── rule.md
├── deploy.sh
├── test.sh
├── validate.py
├── LICENSE
└── README.md
```

</details>

## License

MIT License.

Copyright (c) 2026 Kohei Uechi.

See [LICENSE](LICENSE).
