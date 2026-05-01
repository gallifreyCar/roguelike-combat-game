#!/usr/bin/env python3
"""Export Love2D Lua data into a browser-friendly JS module.

Lua remains the gameplay data source of truth. Run this after changing
data/cards.lua or data/levels.lua:

    python3 tools/export_web_data.py
"""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CARDS_LUA = ROOT / "data" / "cards.lua"
LEVELS_LUA = ROOT / "data" / "levels.lua"
OUT_JS = ROOT / "web" / "game-data.js"


STARTER_DECK = [
    "squirrel", "squirrel", "squirrel",
    "stoat", "stoat", "rat", "rat", "bullfrog", "bullfrog",
    "wolf", "wolf", "raven", "raven", "turtle", "insight",
]

REWARD_POOL = [
    "wolf", "raven", "adder", "skunk", "cat", "grizzly", "moose", "mantis",
    "shark", "fox", "bee", "snake", "spider", "crow", "rabbit", "boar",
]

SIGIL_LABELS = {
    "air_strike": "飞行",
    "tough": "坚韧",
    "undead": "不死",
    "poison": "毒",
    "stinky": "恶臭",
    "guardian": "守护",
    "charge": "冲锋",
    "double_strike": "双击",
    "trample": "践踏",
    "sharp_quills": "尖刺",
    "bone_snake": "骨蛇",
    "hydra": "分裂",
    "bifurcated": "分叉",
    "draw": "抽牌",
    "combo": "连击",
    "death_draw": "亡语抽牌",
    "kill_bonus": "猎手",
    "turn_blood": "血源",
}


def strip_comments(text: str) -> str:
    return re.sub(r"--.*", "", text)


def find_named_table(text: str, name: str) -> str:
    match = re.search(rf"local\s+{re.escape(name)}\s*=\s*{{", text)
    if not match:
        raise ValueError(f"Could not find table {name}")
    start = match.end() - 1
    depth = 0
    for i in range(start, len(text)):
        if text[i] == "{":
            depth += 1
        elif text[i] == "}":
            depth -= 1
            if depth == 0:
                return text[start + 1:i]
    raise ValueError(f"Unclosed table {name}")


def iter_entries(table_body: str):
    i = 0
    while i < len(table_body):
        match = re.search(r"([A-Za-z_][A-Za-z0-9_]*)\s*=\s*{", table_body[i:])
        if not match:
            break
        key = match.group(1)
        start = i + match.end() - 1
        depth = 0
        for j in range(start, len(table_body)):
            if table_body[j] == "{":
                depth += 1
            elif table_body[j] == "}":
                depth -= 1
                if depth == 0:
                    yield key, table_body[start + 1:j]
                    i = j + 1
                    break
        else:
            raise ValueError(f"Unclosed entry {key}")


def iter_array_tables(table_body: str):
    i = 0
    while i < len(table_body):
        while i < len(table_body) and table_body[i] not in "{":
            i += 1
        if i >= len(table_body):
            break
        start = i
        depth = 0
        for j in range(start, len(table_body)):
            if table_body[j] == "{":
                depth += 1
            elif table_body[j] == "}":
                depth -= 1
                if depth == 0:
                    yield table_body[start + 1:j]
                    i = j + 1
                    break
        else:
            raise ValueError("Unclosed array entry")


def lua_string(block: str, key: str, default=None):
    match = re.search(rf"{key}\s*=\s*\"([^\"]*)\"", block)
    return match.group(1) if match else default


def lua_number(block: str, key: str, default=0):
    match = re.search(rf"{key}\s*=\s*(-?\d+(?:\.\d+)?)", block)
    if not match:
        return default
    value = float(match.group(1))
    return int(value) if value.is_integer() else value


def lua_bool(block: str, key: str, default=False):
    match = re.search(rf"{key}\s*=\s*(true|false)", block)
    if not match:
        return default
    return match.group(1) == "true"


def lua_string_array(block: str, key: str):
    match = re.search(rf"{key}\s*=\s*{{([^}}]*)}}", block, re.S)
    if not match:
        return []
    return re.findall(r'"([^"]+)"', match.group(1))


def export_cards():
    body = find_named_table(strip_comments(CARDS_LUA.read_text()), "Cards")
    cards = {}
    for key, block in iter_entries(body):
        card_id = lua_string(block, "id", key)
        cards[card_id] = {
            "id": card_id,
            "name": lua_string(block, "name", card_id),
            "cost": lua_number(block, "cost", 0),
            "attack": lua_number(block, "attack", 0),
            "hp": lua_number(block, "hp", 1),
            "sigils": lua_string_array(block, "sigils"),
            "rarity": lua_string(block, "rarity", "common"),
            "family": lua_string(block, "family", None),
        }
    return cards


def export_levels():
    body = find_named_table(strip_comments(LEVELS_LUA.read_text()), "Levels")
    levels = []
    for index, block in enumerate(iter_array_tables(body)):
        enemies = []
        enemies_match = re.search(r"enemies\s*=\s*{(.*?)}\s*,\s*boss\s*=", block, re.S)
        if enemies_match:
            for card_id, slot in re.findall(r'card\s*=\s*"([^"]+)".*?slot\s*=\s*(\d+)', enemies_match.group(1), re.S):
                enemies.append({"id": card_id, "slot": max(0, int(slot) - 1)})

        boss = lua_bool(block, "boss", False)
        hp = (20 + (index + 1) * 3) if boss else (8 + (index + 1) * 2)
        if lua_bool(block, "is_tutorial", False):
            hp = 6

        levels.append({
            "name": lua_string(block, "name", f"Level {index + 1}"),
            "type": "boss" if boss else ("elite" if lua_number(block, "difficulty", 1) >= 3 and len(enemies) <= 1 else "battle"),
            "hp": hp,
            "goldReward": lua_number(block, "gold_reward", 10),
            "difficulty": lua_number(block, "difficulty", 1),
            "boss": boss,
            "enemies": enemies,
        })
    return levels


def main():
    cards = export_cards()
    levels = export_levels()
    referenced = set(STARTER_DECK) | set(REWARD_POOL)
    for level in levels:
        referenced.update(enemy["id"] for enemy in level["enemies"])
    missing = sorted(card_id for card_id in referenced if card_id not in cards)
    if missing:
        raise SystemExit(f"Missing card definitions: {', '.join(missing)}")

    data = {
        "cards": cards,
        "levels": levels,
        "starterDeck": STARTER_DECK,
        "rewardPool": REWARD_POOL,
        "sigilLabels": SIGIL_LABELS,
    }
    OUT_JS.write_text(
        "// Generated from data/cards.lua and data/levels.lua. Do not edit by hand.\n"
        "// Run: python3 tools/export_web_data.py\n\n"
        f"export const GAME_DATA = {json.dumps(data, ensure_ascii=False, indent=2)};\n",
        encoding="utf-8",
    )
    print(f"Wrote {OUT_JS.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
