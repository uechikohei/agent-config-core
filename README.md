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
