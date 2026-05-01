import { GAME_DATA } from "./game-data.js";

const CARD_IMAGES = "../assets/cards/";
const SAVE_KEY = "blood-cards-web-save-v2";

const CARD_DATA = GAME_DATA.cards;
const LEVELS = GAME_DATA.levels;
const STARTER_DECK = GAME_DATA.starterDeck;
const REWARD_POOL = GAME_DATA.rewardPool;
const SIGIL_LABELS = GAME_DATA.sigilLabels;

const app = document.querySelector("#app");

let state = loadState() ?? freshState();

function freshState() {
  return {
    screen: "menu",
    run: null,
    selectedHand: null,
    rewardChoices: [],
    log: [],
    stats: { wins: 0, losses: 0, battles: 0 },
  };
}

function newRun() {
  const run = {
    floor: 0,
    gold: 50,
    playerHp: 20,
    playerMaxHp: 20,
    deck: STARTER_DECK.map(makeCard),
    drawPile: [],
    discardPile: [],
    hand: [],
    playerBoard: [null, null, null, null],
    enemyBoard: [null, null, null, null],
    enemyHp: 0,
    enemyMaxHp: 0,
    turn: 1,
    blood: 1,
    phase: "map",
  };
  state.run = run;
  state.selectedHand = null;
  state.log = ["新的旅途开始了。"];
  state.screen = "map";
}

function makeCard(id) {
  const base = CARD_DATA[id];
  return {
    ...base,
    instance: `${id}-${crypto.randomUUID?.() ?? Math.random().toString(36).slice(2)}`,
    hp: base.hp,
    maxHp: base.hp,
  };
}

function cloneBoardCard(id, levelBonus = 0) {
  const card = makeCard(id);
  card.attack += levelBonus;
  card.hp += levelBonus;
  card.maxHp += levelBonus;
  card.intent = rollIntent(card);
  return card;
}

function saveState() {
  localStorage.setItem(SAVE_KEY, JSON.stringify(state));
}

function loadState() {
  try {
    return JSON.parse(localStorage.getItem(SAVE_KEY));
  } catch {
    return null;
  }
}

function shuffle(cards) {
  const copy = [...cards];
  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

function startCombat(floor) {
  const run = state.run;
  const level = LEVELS[floor];
  run.floor = floor;
  run.turn = 1;
  run.blood = 1;
  run.phase = "play";
  run.enemyHp = level.hp;
  run.enemyMaxHp = level.hp;
  run.playerBoard = [null, null, null, null];
  run.enemyBoard = [null, null, null, null];
  run.discardPile = [];
  run.drawPile = shuffle(run.deck.map(card => ({ ...card, hp: card.maxHp })));
  run.hand = [];
  drawCards(3);
  const openingHelp = ensurePlayableOpeningHand();

  const bonus = Math.floor(floor / 3);
  level.enemies.forEach(enemy => {
    run.enemyBoard[enemy.slot] = cloneBoardCard(enemy.id, bonus);
  });

  state.selectedHand = null;
  state.log = [`进入 ${level.name}。`];
  if (openingHelp) pushLog(openingHelp);
  state.screen = "combat";
}

function drawCards(count) {
  const run = state.run;
  for (let i = 0; i < count && run.hand.length < 8; i += 1) {
    if (run.drawPile.length === 0) {
      if (run.discardPile.length === 0) return;
      run.drawPile = shuffle(run.discardPile);
      run.discardPile = [];
    }
    run.hand.push(run.drawPile.pop());
  }
}

function ensurePlayableOpeningHand() {
  const run = state.run;
  const hasPlayableAttacker = run.hand.some(card => card.attack > 0 && card.cost <= run.blood);
  if (hasPlayableAttacker) return null;

  const sourceIndex = run.drawPile.findIndex(card => card.attack > 0 && card.cost <= run.blood);
  if (sourceIndex < 0) return null;

  const replaceIndex = run.hand.findIndex(card => card.attack === 0 || card.cost > run.blood);
  if (replaceIndex < 0) return null;

  const [playable] = run.drawPile.splice(sourceIndex, 1);
  run.drawPile.push(run.hand[replaceIndex]);
  run.hand[replaceIndex] = playable;
  return "开局手牌调整：保证至少有一张可出的攻击牌。";
}

function rollIntent(card) {
  const roll = Math.random();
  if (roll < 0.62) return { type: "attack", value: Math.max(1, card.attack) };
  if (roll < 0.84) return { type: "defend", value: 2 };
  return { type: "buff", value: 1 };
}

function pushLog(text) {
  state.log.unshift(text);
  state.log = state.log.slice(0, 7);
}

function placeCard(slot) {
  const run = state.run;
  const index = state.selectedHand;
  if (index === null || run.phase !== "play") return;
  if (run.playerBoard[slot]) {
    pushLog("这个位置已经有牌。");
    render();
    return;
  }
  const card = run.hand[index];
  if (!card) return;
  if (card.cost > run.blood) {
    pushLog(`鲜血不足，需要 ${card.cost}。`);
    render();
    return;
  }
  run.blood -= card.cost;
  run.hand.splice(index, 1);
  if (card.sigils.includes("tough")) {
    card.hp += 2;
    card.maxHp += 2;
  }
  run.playerBoard[slot] = card;
  if (card.sigils.includes("draw")) {
    drawCards(2);
    pushLog(`${card.name} 触发抽牌。`);
  }
  state.selectedHand = null;
  pushLog(`${card.name} 入场。`);
  render();
}

function sacrifice(slot) {
  const run = state.run;
  const card = run.playerBoard[slot];
  if (!card || run.phase !== "play") return;
  run.playerBoard[slot] = null;
  run.blood += 1;
  pushLog(`献祭 ${card.name}，鲜血 +1。`);
  render();
}

function startBattle() {
  const run = state.run;
  if (run.phase !== "play") return;
  const hasAttacker = run.playerBoard.some(card => card && card.attack > 0);
  if (!hasAttacker && run.hand.some(card => card.attack > 0 && card.cost <= run.blood)) {
    pushLog("先放一张攻击牌再 Battle，会更有效。");
    render();
    return;
  }
  run.phase = "battle";
  pushLog("战斗开始。");
  executeCombatRound();
  render();
}

function getAttackLanes(attacker, lane) {
  if (attacker.sigils.includes("charge")) {
    return [lane - 1, lane, lane + 1].filter(targetLane => targetLane >= 0 && targetLane < 4);
  }
  if (attacker.sigils.includes("bifurcated")) {
    return [lane - 1, lane + 1].filter(targetLane => targetLane >= 0 && targetLane < 4);
  }
  return [lane];
}

function directDamage(amount, fromPlayer) {
  if (fromPlayer) {
    state.run.enemyHp -= amount;
  } else {
    state.run.playerHp -= amount;
  }
}

function attackTarget(attacker, target, lane, fromPlayer) {
  let damage = Math.max(0, attacker.attack);
  if (target && target.sigils.includes("stinky")) damage = Math.max(0, damage - 1);

  if (target && !attacker.sigils.includes("air_strike")) {
    const beforeHp = target.hp;
    target.hp -= damage;
    pushLog(`${attacker.name} 攻击 ${target.name}，造成 ${damage}。`);
    if (target.sigils.includes("sharp_quills") && damage > 0) {
      const thorns = Math.floor(damage / 2);
      attacker.hp -= thorns;
      if (thorns > 0) pushLog(`${target.name} 尖刺反伤 ${thorns}。`);
    }
    if (target.hp <= 0 && attacker.sigils.includes("trample")) {
      const overflow = Math.max(0, damage - beforeHp);
      if (overflow > 0) {
        directDamage(overflow, fromPlayer);
        pushLog(`${attacker.name} 践踏溢出 ${overflow}。`);
      }
    }
    if (target.hp <= 0 && attacker.sigils.includes("kill_bonus")) {
      attacker.attack += 1;
      pushLog(`${attacker.name} 猎杀成功，攻击 +1。`);
    }
  } else if (fromPlayer) {
    directDamage(damage, true);
    pushLog(`${attacker.name} 直击敌人，造成 ${damage}。`);
  } else {
    directDamage(damage, false);
    pushLog(`${attacker.name} 直击你，造成 ${damage}。`);
  }

  if (attacker.sigils.includes("poison") && target) {
    target.poison = (target.poison ?? 0) + 1;
  }
}

function executeCombatRound() {
  const run = state.run;
  for (let lane = 0; lane < 4; lane += 1) {
    const card = run.playerBoard[lane];
    if (!card || card.hp <= 0) continue;
    const hits = card.sigils.includes("double_strike") ? 2 : 1;
    for (let i = 0; i < hits; i += 1) {
      getAttackLanes(card, lane).forEach(targetLane => {
        attackTarget(card, run.enemyBoard[targetLane], targetLane, true);
      });
    }
  }
  cleanupDead();
  if (checkCombatEnd()) return;

  for (let lane = 0; lane < 4; lane += 1) {
    const card = run.enemyBoard[lane];
    if (!card || card.hp <= 0) continue;
    const intent = card.intent ?? rollIntent(card);
    if (intent.type === "defend") {
      card.hp = Math.min(card.maxHp, card.hp + intent.value);
      pushLog(`${card.name} 防御，恢复 ${intent.value}。`);
    } else if (intent.type === "buff") {
      card.attack += intent.value;
      pushLog(`${card.name} 强化，攻击 +${intent.value}。`);
    } else {
      getAttackLanes(card, lane).forEach(targetLane => {
        attackTarget({ ...card, attack: intent.value }, run.playerBoard[targetLane], targetLane, false);
      });
    }
    card.intent = rollIntent(card);
  }
  applyPoison();
  cleanupDead();
  if (checkCombatEnd()) return;

  run.turn += 1;
  run.blood = Math.min(3, run.turn);
  run.playerBoard.forEach(card => {
    if (card?.sigils.includes("turn_blood")) {
      run.blood = Math.min(3, run.blood + 1);
      pushLog(`${card.name} 触发血源，鲜血 +1。`);
    }
  });
  drawCards(2);
  spawnEnemyReinforcement();
  run.phase = "play";
  pushLog(`第 ${run.turn} 回合，鲜血 ${run.blood}/3。`);
}

function applyPoison() {
  [...state.run.playerBoard, ...state.run.enemyBoard].forEach(card => {
    if (card?.poison) {
      card.hp -= card.poison;
      card.poison -= 1;
    }
  });
}

function cleanupDead() {
  const run = state.run;
  for (let lane = 0; lane < 4; lane += 1) {
    const player = run.playerBoard[lane];
    if (player && player.hp <= 0) {
      if (player.sigils.includes("undead") && !player.revived) {
        player.revived = true;
        player.hp = 1;
        pushLog(`${player.name} 复活。`);
      } else {
        if (player.sigils.includes("death_draw")) {
          drawCards(2);
          pushLog(`${player.name} 亡语抽牌。`);
        }
        pushLog(`${player.name} 死亡。`);
        run.playerBoard[lane] = null;
      }
    }

    const enemy = run.enemyBoard[lane];
    if (enemy && enemy.hp <= 0) {
      if (enemy.sigils.includes("undead") && !enemy.revived) {
        enemy.revived = true;
        enemy.hp = 1;
        pushLog(`敌方 ${enemy.name} 复活。`);
      } else if (enemy.sigils.includes("hydra")) {
        pushLog(`敌方 ${enemy.name} 分裂。`);
        run.enemyBoard[lane] = makeMinion("hydra_head", "Hydra Head", 2, 2);
        const emptyLane = run.enemyBoard.findIndex((card, i) => i !== lane && !card);
        if (emptyLane >= 0) run.enemyBoard[emptyLane] = makeMinion("hydra_head", "Hydra Head", 2, 2);
      } else {
        pushLog(`敌方 ${enemy.name} 死亡。`);
        run.enemyBoard[lane] = null;
      }
    }
  }
}

function makeMinion(id, name, attack, hp) {
  return {
    id,
    name,
    cost: 0,
    attack,
    hp,
    maxHp: hp,
    sigils: [],
    rarity: "token",
    family: "token",
    instance: `${id}-${crypto.randomUUID?.() ?? Math.random().toString(36).slice(2)}`,
    intent: rollIntent({ attack }),
  };
}

function checkCombatEnd() {
  const run = state.run;
  if (run.enemyHp <= 0) {
    run.gold += LEVELS[run.floor].goldReward;
    state.stats.battles += 1;
    if (run.floor >= LEVELS.length - 1) {
      run.phase = "victory";
      state.stats.wins += 1;
      state.screen = "victory";
    } else {
      run.phase = "reward";
      makeRewardChoices();
      state.screen = "reward";
    }
    return true;
  }
  if (run.playerHp <= 0) {
    run.phase = "death";
    state.stats.losses += 1;
    state.screen = "death";
    return true;
  }
  return false;
}

function spawnEnemyReinforcement() {
  const run = state.run;
  const empty = run.enemyBoard.map((card, i) => (card ? null : i)).filter(i => i !== null);
  if (!empty.length || run.turn <= 2 || Math.random() > 0.32) return;
  const pool = run.turn < 4 ? ["stoat", "rat", "bullfrog"] : ["wolf", "adder", "skunk", "mantis"];
  const lane = empty[Math.floor(Math.random() * empty.length)];
  run.enemyBoard[lane] = cloneBoardCard(pool[Math.floor(Math.random() * pool.length)], Math.floor(run.floor / 3));
}

function makeRewardChoices() {
  const cards = shuffle(REWARD_POOL).slice(0, 3).map(id => ({ type: "card", card: makeCard(id) }));
  cards[Math.floor(Math.random() * cards.length)] = { type: "gold", amount: 28 + state.run.floor * 5 };
  state.rewardChoices = cards;
}

function takeReward(index) {
  const reward = state.rewardChoices[index];
  if (!reward) return;
  if (reward.type === "card") {
    state.run.deck.push(reward.card);
    pushLog(`${reward.card.name} 加入牌组。`);
  } else {
    state.run.gold += reward.amount;
    pushLog(`获得 ${reward.amount} 金币。`);
  }
  state.run.floor = Math.min(state.run.floor + 1, LEVELS.length - 1);
  state.run.phase = "map";
  state.screen = "map";
  render();
}

function resetSave() {
  localStorage.removeItem(SAVE_KEY);
  state = freshState();
  render();
}

function screenForRunPhase(phase) {
  if (phase === "map") return "map";
  if (phase === "reward") return "reward";
  if (phase === "victory") return "victory";
  if (phase === "death") return "death";
  return "combat";
}

function cardImage(id) {
  return `${CARD_IMAGES}${id}.png`;
}

function sigilText(card) {
  if (card.sigils.length) {
    return card.sigils.map(sigil => SIGIL_LABELS[sigil] ?? sigil).join(" · ");
  }
  return card.family ?? "neutral";
}

function renderCard(card, options = {}) {
  if (!card) return `<div class="lane-label">空位</div>`;
  const compact = options.compact ? " compact" : "";
  const selected = options.selected ? " is-selected" : "";
  const unaffordable = options.affordable === false ? " is-unaffordable" : "";
  const dead = card.hp <= 0 ? " is-dead" : "";
  const intent = options.enemy && card.intent ? `<div class="intent">${intentLabel(card.intent)}</div>` : "";
  return `
    <article class="card${compact}${selected}${unaffordable}${dead}" ${options.testId ? `data-testid="${options.testId}"` : ""}>
      <img class="portrait" src="${cardImage(card.id)}" alt="${card.name}" onerror="this.style.visibility='hidden'" />
      <div class="cost">${card.cost}</div>
      ${intent}
      <div class="card-name">${card.name}</div>
      <div class="stats"><span>ATK <b>${card.attack}</b></span><span>HP <b>${card.hp}/${card.maxHp}</b></span></div>
      <div class="sigils">${sigilText(card)}</div>
    </article>
  `;
}

function intentLabel(intent) {
  if (intent.type === "attack") return `攻 ${intent.value}`;
  if (intent.type === "defend") return `防 ${intent.value}`;
  return `强 ${intent.value}`;
}

function render() {
  saveState();
  if (state.screen === "menu") renderMenu();
  if (state.screen === "map") renderMap();
  if (state.screen === "combat") renderCombat();
  if (state.screen === "reward") renderReward();
  if (state.screen === "death") renderEnd("战败", "这次探索结束了。", false);
  if (state.screen === "victory") renderEnd("胜利", "你打穿了全部节点。", true);
}

function renderMenu() {
  app.innerHTML = `
    <main class="screen menu-screen">
      <section class="brand">
        <h1>Blood Cards Web</h1>
        <p>浏览器可测版：地图、放置、献祭、自动战斗、奖励和重开都在这里。</p>
      </section>
      <section class="menu-panel">
        <div class="tips">
          <strong>玩法</strong>
          <span>选择地图节点进入战斗。点击右侧手牌，再点己方空位放置。右键场上卡牌献祭换鲜血。按 Battle 自动结算一轮。</span>
          <span>敌人牌右上角会显示下一步意图：攻击、防御或强化。</span>
          <span class="kbd">快捷键：Space 开始 / Battle，R 重开，Esc 回菜单。</span>
        </div>
        <div class="menu-actions">
          <button class="primary" data-action="new-run" data-testid="new-run">开始新局</button>
          <button data-action="continue" ${state.run ? "" : "disabled"}>继续</button>
          <button class="danger" data-action="reset-save">清除浏览器存档</button>
        </div>
      </section>
    </main>
  `;
}

function renderMap() {
  const run = state.run;
  const next = run.floor;
  app.innerHTML = `
    <main class="screen layout">
      <header class="topbar">
        <h2>地图</h2>
        <div class="metrics">
          <span class="metric">HP <strong>${run.playerHp}/${run.playerMaxHp}</strong></span>
          <span class="metric">金币 <strong>${run.gold}</strong></span>
          <span class="metric">牌组 <strong>${run.deck.length}</strong></span>
        </div>
        <div class="actions">
          <button data-action="menu">菜单</button>
          <button data-action="new-run">重开</button>
        </div>
      </header>
      <section class="map-grid">
        ${LEVELS.map((level, i) => `
          <div class="map-row">
            <button class="node ${i < next ? "done" : ""} ${i === next ? "available" : ""}"
              data-action="node" data-floor="${i}" ${i === next ? "" : "disabled"}
              data-testid="map-node-${i}">
              ${i + 1}. ${level.name}<br />${level.type.toUpperCase()}
            </button>
          </div>
        `).join("")}
      </section>
      <footer class="statusbar"><span>${state.log[0] ?? "选择下一个节点。"}</span></footer>
    </main>
  `;
}

function renderCombat() {
  const run = state.run;
  const level = LEVELS[run.floor];
  const canAttack = run.playerBoard.some(card => card && card.attack > 0);
  app.innerHTML = `
    <main class="screen layout">
      <header class="topbar">
        <h2>${level.name}</h2>
        <div class="metrics">
          <span class="metric">HP <strong>${run.playerHp}/${run.playerMaxHp}</strong></span>
          <span class="metric">鲜血 <strong>${run.blood}/3</strong></span>
          <span class="metric">回合 <strong>${run.turn}</strong></span>
          <span class="metric">抽牌 <strong>${run.drawPile.length}</strong></span>
        </div>
        <div class="actions">
          <button data-action="menu">菜单</button>
          <button data-action="new-run">重开</button>
        </div>
      </header>
      <section class="combat-grid">
        <div class="arena">
          <div class="enemy-health">
            <div class="bar"><span style="width:${Math.max(0, run.enemyHp / run.enemyMaxHp * 100)}%"></span><b>敌方 ${run.enemyHp}/${run.enemyMaxHp}</b></div>
          </div>
          <div class="board-row" data-testid="enemy-board">
            ${run.enemyBoard.map((card, i) => `<div class="slot">${renderCard(card, { enemy: true, testId: `enemy-card-${i}` })}</div>`).join("")}
          </div>
          <div class="board-row" data-testid="player-board">
            ${run.playerBoard.map((card, i) => `
              <div class="slot ${state.selectedHand !== null && !card ? "is-target" : ""}"
                data-action="place" data-slot="${i}" data-testid="player-slot-${i}">
                ${renderCard(card, { testId: `player-card-${i}` })}
                ${card ? `<button data-action="sacrifice" data-slot="${i}">献祭</button>` : ""}
              </div>
            `).join("")}
          </div>
          <div class="actions">
            <button class="primary" data-action="battle" data-testid="battle-button" ${run.phase === "play" ? "" : "disabled"}>Battle</button>
            <span class="battle-note">${canAttack ? "己方有可攻击单位" : "当前没有攻击力，考虑放置攻击牌或献祭换鲜血"}</span>
          </div>
          <div class="log" data-testid="combat-log">
            ${state.log.map(line => `<div>${line}</div>`).join("")}
          </div>
        </div>
        <aside class="hand-panel">
          <h3>手牌 (${run.hand.length})</h3>
          <p class="hand-hint">亮色可直接支付，暗色需要更多鲜血。</p>
          <div class="hand-list">
            ${run.hand.map((card, i) => {
              const affordable = card.cost <= run.blood;
              return `
              <div class="hand-card ${affordable ? "can-play" : "needs-blood"}" data-action="select-hand" data-index="${i}"
                title="${affordable ? "可支付" : `需要 ${card.cost} 鲜血`}">
                ${renderCard(card, { compact: true, selected: state.selectedHand === i, affordable, testId: `hand-card-${i}` })}
              </div>
            `; }).join("") || `<p class="kbd">没有手牌。</p>`}
          </div>
        </aside>
      </section>
      <footer class="statusbar"><span>点击手牌，再点己方空位。右键场上牌也可献祭。</span></footer>
    </main>
  `;
}

function renderReward() {
  app.innerHTML = `
    <main class="screen reward-layout">
      <section class="center">
        <h1>选择奖励</h1>
        <p class="kbd">选完会回到地图继续下一层。</p>
      </section>
      <section class="reward-cards">
        ${state.rewardChoices.map((reward, i) => `
          <button class="reward-option" data-action="reward" data-index="${i}" data-testid="reward-${i}">
            ${reward.type === "card"
              ? renderCard(reward.card)
              : `<div class="card"><div class="card-name">金币</div><div class="stats"><b>+${reward.amount}</b></div><div class="sigils">用于后续扩展商店</div></div>`}
          </button>
        `).join("")}
      </section>
    </main>
  `;
}

function renderEnd(title, subtitle, won) {
  app.innerHTML = `
    <main class="screen menu-screen">
      <section class="overlay-panel center">
        <h1>${title}</h1>
        <p>${subtitle}</p>
        <div class="metrics" style="justify-content:center">
          <span class="metric">胜利 <strong>${state.stats.wins}</strong></span>
          <span class="metric">失败 <strong>${state.stats.losses}</strong></span>
          <span class="metric">战斗 <strong>${state.stats.battles}</strong></span>
          <span class="metric">金币 <strong>${state.run?.gold ?? 0}</strong></span>
        </div>
        <div class="actions" style="justify-content:center;margin-top:16px">
          <button class="primary" data-action="new-run" data-testid="restart">重新开始</button>
          <button data-action="menu">返回菜单</button>
          ${won ? `<button data-action="reset-save">清档</button>` : ""}
        </div>
      </section>
    </main>
  `;
}

app.addEventListener("click", event => {
  const target = event.target.closest("[data-action]");
  if (!target) return;
  const action = target.dataset.action;
  if (action === "new-run") newRun();
  if (action === "continue" && state.run) state.screen = screenForRunPhase(state.run.phase);
  if (action === "reset-save") resetSave();
  if (action === "menu") state.screen = "menu";
  if (action === "node") startCombat(Number(target.dataset.floor));
  if (action === "select-hand") {
    const index = Number(target.dataset.index);
    const card = state.run?.hand[index];
    if (card && card.cost > state.run.blood) {
      pushLog(`${card.name} 需要 ${card.cost} 鲜血。先献祭或等下一回合。`);
    }
    state.selectedHand = index;
  }
  if (action === "place") placeCard(Number(target.dataset.slot));
  if (action === "sacrifice") sacrifice(Number(target.dataset.slot));
  if (action === "battle") startBattle();
  if (action === "reward") takeReward(Number(target.dataset.index));
  render();
});

app.addEventListener("contextmenu", event => {
  const slot = event.target.closest("[data-action='place']");
  if (!slot) return;
  event.preventDefault();
  sacrifice(Number(slot.dataset.slot));
});

window.addEventListener("keydown", event => {
  if (event.key === " " && state.screen === "menu") {
    event.preventDefault();
    newRun();
    render();
  } else if (event.key === " " && state.screen === "combat") {
    event.preventDefault();
    startBattle();
  } else if (event.key.toLowerCase() === "r") {
    newRun();
    render();
  } else if (event.key === "Escape") {
    state.screen = "menu";
    render();
  }
});

render();
