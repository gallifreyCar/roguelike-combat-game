#!/usr/bin/env python3
"""
i18n 翻译覆盖率检查工具
检查所有语言的翻译完整性，生成报告
"""

import re
import sys

def parse_i18n_file(filepath):
    """解析 i18n.lua 文件，提取所有翻译键"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 提取语言块
    lang_pattern = r'(\w+)\s*=\s*\{([^}]+)\}'
    languages = {}

    # 更精确的匹配
    current_lang = None
    lang_content = {}
    brace_count = 0
    in_lang = False
    current_content = []

    lines = content.split('\n')
    for line in lines:
        # 检测语言开始
        if re.match(r'\s*(\w+)\s*=\s*\{', line) and 'translations' not in line:
            match = re.match(r'\s*(\w+)\s*=\s*\{', line)
            if match and match.group(1) in ['en', 'zh', 'ja', 'ko']:
                if current_lang:
                    lang_content[current_lang] = current_content
                current_lang = match.group(1)
                current_content = []
                in_lang = True
                brace_count = 1
                continue

        if in_lang:
            if '{' in line:
                brace_count += line.count('{')
            if '}' in line:
                brace_count -= line.count('}')

            if brace_count == 0:
                lang_content[current_lang] = current_content
                in_lang = False
                current_lang = None
            else:
                current_content.append(line)

    # 提取键
    result = {}
    for lang, lines in lang_content.items():
        keys = set()
        for line in lines:
            match = re.match(r'\s*(\w+)\s*=', line)
            if match:
                keys.add(match.group(1))
        result[lang] = keys

    return result

def check_coverage(languages):
    """检查翻译覆盖率"""
    if 'en' not in languages:
        print("错误：找不到英文翻译基准")
        return

    en_keys = languages['en']
    total = len(en_keys)

    print("\n" + "=" * 60)
    print("Blood Cards i18n 翻译覆盖率报告")
    print("=" * 60)
    print(f"\n英文基准键数: {total}")
    print("-" * 60)

    for lang in ['en', 'zh', 'ja', 'ko']:
        if lang not in languages:
            print(f"{lang.upper()}: 未找到")
            continue

        lang_keys = languages[lang]
        translated = len(lang_keys & en_keys)
        missing = en_keys - lang_keys
        extra = lang_keys - en_keys
        percent = (translated / total * 100) if total > 0 else 0

        print(f"\n{lang.upper()}: {translated}/{total} ({percent:.1f}%)")

        if missing:
            print(f"  缺失键 ({len(missing)}):")
            for key in sorted(missing)[:10]:
                print(f"    - {key}")
            if len(missing) > 10:
                print(f"    ... 还有 {len(missing) - 10} 个")

        if extra:
            print(f"  多余键 ({len(extra)}):")
            for key in sorted(extra)[:5]:
                print(f"    + {key}")

    print("\n" + "=" * 60)

def main():
    filepath = "/Users/gallifreycar/Documents/roguelike-game/core/i18n.lua"
    languages = parse_i18n_file(filepath)
    check_coverage(languages)

if __name__ == "__main__":
    main()