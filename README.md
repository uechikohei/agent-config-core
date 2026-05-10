# agent-config-core

Codex と Claude Code のローカル共通ルールを `rule.md` で管理し、各端末の global instruction に配信するためのリポジトリです。

Codex 用と Claude Code 用の設定ファイルを別々に編集する代わりに、`rule.md` を編集して Git で差分を確認し、`./deploy.sh` で両方へ反映します。

## 使い方

```bash
vim rule.md
git diff -- rule.md
python3 validate.py
./test.sh
./deploy.sh
```

- `python3 validate.py`: `rule.md` に secret や private path らしい文字列がないか確認する
- `./test.sh`: 一時 home で `deploy.sh` の動作を確認する
- `./deploy.sh`: `rule.md` を Codex / Claude Code の global instruction へ配信する
- `./deploy.sh --check`: 配信済みファイルが現在の `rule.md` と一致するか確認する
- `./deploy.sh --dry-run`: 書き込み先だけ表示する
- `PERSONA_SKILLS_ROOT=/path/to/persona-skills-core ./deploy.sh --install-persona-skills`: Persona Skills Core を Codex / Claude Code に登録する
- `PERSONA_SKILLS_ROOT=/path/to/persona-skills-core ./deploy.sh --persona-skills-status`: Persona Skills Core の登録状態を確認する

## Persona Skills Core 連携

`agent-config-core` は Persona Skills の本文を持ちません。Persona Skills Core を使う場合は、別途 clone した `persona-skills-core` の CLI を optional command から呼び出します。

```bash
git clone https://github.com/uechikohei/persona-skills-core.git
PERSONA_SKILLS_ROOT=/path/to/persona-skills-core ./deploy.sh --install-persona-skills
PERSONA_SKILLS_ROOT=/path/to/persona-skills-core ./deploy.sh --persona-skills-status
```

期待値:

- Codex: `manifest: present`、`plugin symlink: linked`、`config plugin: enabled`
- Claude Code: `technical-writing: linked` と、他の Persona Skills も `linked`

登録後は Codex / Claude Code を新規セッションで起動して確認します。既存セッションは起動時点の plugin / skill metadata を保持している場合があります。

Codex では `$` で skill mention 候補を開き、`persona-skills:technical-writing` などの Persona Skills が表示されることを確認します。`/` は Codex の slash command 一覧であり、Persona Skills の一覧確認には使いません。

```text
$
```

Claude Code では `/` で slash skill 候補を開き、`/technical-writing` などの Persona Skills が表示されることを確認します。

```text
/
```

最小確認プロンプト:

```text
technical-writing を使って、READMEレビューの進め方を提案してください。
参照した Persona Skills のローカルpathも2件以上書いてください。
```

## 配信先

| Agent | Path |
| --- | --- |
| Codex | `~/.codex/AGENTS.md` |
| Claude Code | `~/.claude/CLAUDE.md` |

## 扱うもの

- どの端末でも共有してよい基本方針
- どの project でも共有してよい安全方針
- Codex / Claude Code に共通で渡したい応答姿勢

## 扱わないもの

- project 固有ルール
- secret、private path、private URL、raw log
- project repository の `AGENTS.md` / `CLAUDE.md` 同期
- Persona Skills / plugin / skill library の本文管理
- tag / release version の運用

## ファイル構成

```text
agent-config-core/
├── rule.md       # 共通ルール
├── deploy.sh     # ローカル端末への配信
├── test.sh       # deploy.sh の動作確認
├── validate.py   # rule.md の静的チェック
├── LICENSE
└── README.md
```

## CI

GitHub Actions では `python3 validate.py` と `./test.sh` を実行します。CI は実際の `~/.codex` や `~/.claude` には書き込みません。

## License

MIT License. See `LICENSE`.
