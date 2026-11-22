#!/usr/bin/env python3
"""Swift 全ファイルの構文点検（tree-sitter）。

Xcode のない環境でも、括弧・文の切れ・タイプミスによる構文の破綻を見つける。
意味の検査ではないので、コンパイルは GitHub Actions のビルドで確かめる。
"""

import sys
from pathlib import Path

from tree_sitter import Language, Parser
import tree_sitter_swift

ROOT = Path(__file__).resolve().parent.parent
SOURCES = ROOT / "Sources"


def walk(node):
    yield node
    for child in node.children:
        yield from walk(child)


def main() -> int:
    parser = Parser(Language(tree_sitter_swift.language()))
    files = sorted(SOURCES.rglob("*.swift"))
    if not files:
        print("Swift ファイルが見つかりません")
        return 1

    failures = 0
    total_lines = 0
    for path in files:
        text = path.read_text(encoding="utf-8")
        total_lines += text.count("\n") + 1
        tree = parser.parse(text.encode("utf-8"))
        problems = []
        for node in walk(tree.root_node):
            if node.type == "ERROR" or node.is_missing:
                line = text[: node.start_byte].count("\n") + 1
                snippet = text.splitlines()[line - 1].strip()[:70] if line - 1 < len(text.splitlines()) else ""
                problems.append(f"  {line}行目: {node.type} {snippet}")
        if problems:
            failures += 1
            print(f"FAIL  {path.relative_to(ROOT)}")
            for problem in problems[:6]:
                print(problem)
        else:
            print(f"ok    {path.relative_to(ROOT)}")

    print(f"\n{len(files) - failures} / {len(files)} ファイル（{total_lines} 行）")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
