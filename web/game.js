const CARD_IMAGES = "../assets/cards/";
const SAVE_KEY = "blood-cards-web-save";

const CARD_DATA = {
  squirrel: { id: "squirrel", name: "松鼠", cost: 0, attack: 0, hp: 1, sigils: [], family: "material" },
  stoat: { id: "stoat", name: "白鼬", cost: 1, attack: 1, hp: 2, sigils: [], family: "beast" },
  rat: { id: "rat", name: "老鼠", cost: 1, attack: 2, hp: 1, sigils: [], family: "beast" },
  bullfrog: { id: "bullfrog", name: "牛蛙", cost: 1, attack: 1, hp: 4, sigils: ["坚韧"], family: "reptile" },
  turtle: { id: "turtle", name: "龟", cost: 1, attack: 0, hp: 6, sigils: ["守护"], family: "reptile" },
  insight: { id: "insight", name: "洞察", cost: 1, attack: 0, hp: 1, sigils: ["抽牌"], family: "spell" },
  wolf: { id: "wolf", name: "狼", cost: 2, attack: 2, hp: 2, sigils: [], family: "beast" },
  raven: { id: "raven", name: "渡鸦", cost: 2, attack: 2, hp: 3, sigils: ["飞行"], family: "flying" },
  adder: { id: "adder", name: "蝰蛇", cost: 2, attack: 1, hp: 2, sigils: ["毒"], family: "reptile" },
  skunk: { id: "skunk", name: "臭鼬", cost: 2, attack: 1, hp: 3, sigils: ["恶臭"], family: "beast" },
  cat: { id: "cat", name: "猫", cost: 2, attack: 1, hp: 1, sigils: ["不死"], family: "beast" },
  grizzly: { id: "grizzly", name: "灰熊", cost: 3, attack: 4, hp: 6, sigils: [], family: "beast" },
  moose: { id: "moose", name: "驼鹿", cost: 3, attack: 2, hp: 4, sigils: ["冲锋"], family: "beast" },
  mantis: { id: "mantis", name: "螳螂", cost: 3, attack: 3, hp: 2, sigils: ["双击"], family: "insect" },
  bear: { id: "bear", name: "熊王", cost: 4, attack: 4, hp: 8, sigils: ["践踏"], family: "beast" },
  shark: { id: "shark", name: "鲨鱼", cost: 3, attack: 3, hp: 3, sigils: ["践踏"], family: "ocean" },
  dragon: { id: "dragon", name: "巨龙", cost: 5, attack: 5, hp: 7, sigils: ["飞行"], family: "mythic" },
  titan: { id: "titan", name: "泰坦", cost: 5, attack: 6, hp: 9, sigils: ["坚韧"], family: "mythic" },
};

const LEVELS = [
  { name: "教学林地", type: "battle", hp: 6, enemies: [{ id: "squirrel", slot: 1 }] },
  { name: "森林小径", type: "battle", hp: 12, enemies: [{ id: "stoat", slot: 1 }] },
  { name: "幽暗树林", type: "elite", hp: 16, enemies: [{ id: "rat", slot: 0 }, { id: "stoat", slot: 2 }] },
  { name: "熊王巢穴", type: "boss", hp: 24, enemies: [{ id: "bear", slot: 1 }] },
  { name: "潮湿矿洞", type: "battle", hp: 19, enemies: [{ id: "adder", slot: 0 }, { id: "skunk", slot: 3 }] },
  { name: "深海裂隙", type: "elite", hp: 24, enemies: [{ id: "shark", slot: 2 }] },
  { name: "天空祭坛", type: "battle", hp: 25, enemies: [{ id: "raven", slot: 1 }, { id: "mantis", slot: 3 }] },
  { name: "虚空之门", type: "boss", hp: 36, enemies: [{ id: "dragon", slot: 1 }, { id: "titan", slot: 2 }] },
];

const STARTER_DECK = [
  "squirrel", "squirrel", "squirrel",
  "stoat", "stoat", "rat", "rat", "bullfrog", "bullfrog",
  "wolf", "wolf", "raven", "raven", "turtle", "insight",
];

const REWARD_POOL = ["wolf", "raven", "adder", "skunk", "cat", "grizzly", "moose", "mantis", "shark"];

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

  const bonus = Math.floor(floor / 3);
  level.enemies.forEach(enemy => {
    run.enemyBoard[enemy.slot] = cloneBoardCard(enemy.id, bonus);
  });

  state.selectedHand = null;
  state.log = [`进入 ${level.name}。`];
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
  if (card.sigils.includes("坚韧")) {
    card.hp += 2;
    card.maxHp += 2;
  }
  run.playerBoard[slot] = card;
  if (card.sigils.includes("抽牌")) {
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
  run.phase = "battle";
  pushLog("战斗开始。");
  executeCombatRound();
  render();
}

function attackTarget(attacker, target, lane, fromPlayer) {
  let damage = Math.max(0, attacker.attack);
  if (target && target.sigils.includes("恶臭")) damage = Math.max(0, damage - 1);

  if (target && !attacker.sigils.includes("飞行")) {
    target.hp -= damage;
    pushLog(`${attacker.name} 攻击 ${target.name}，造成 ${damage}。`);
  } else if (fromPlayer) {
    state.run.enemyHp -= damage;
    pushLog(`${attacker.name} 直击敌人，造成 ${damage}。`);
  } else {
    state.run.playerHp -= damage;
    pushLog(`${attacker.name} 直击你，造成 ${damage}。`);
  }

  if (attacker.sigils.includes("毒") && target) {
    target.poison = (target.poison ?? 0) + 1;
  }
}

function executeCombatRound() {
  const run = state.run;
  for (let lane = 0; lane < 4; lane += 1) {
    const card = run.playerBoard[lane];
    if (!card || card.hp <= 0) continue;
    const hits = card.sigils.includes("双击") ? 2 : 1;
    for (let i = 0; i < hits; i += 1) attackTarget(card, run.enemyBoard[lane], lane, true);
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
      attackTarget({ ...card, attack: intent.value }, run.playerBoard[lane], lane, false);
    }
    card.intent = rollIntent(card);
  }
  applyPoison();
  cleanupDead();
  if (checkCombatEnd()) return;

  run.turn += 1;
  run.blood = Math.min(3, run.turn);
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
      if (player.sigils.includes("不死") && !player.revived) {
        player.revived = true;
        player.hp = 1;
        pushLog(`${player.name} 复活。`);
      } else {
        pushLog(`${player.name} 死亡。`);
        run.playerBoard[lane] = null;
      }
    }

    const enemy = run.enemyBoard[lane];
    if (enemy && enemy.hp <= 0) {
      pushLog(`敌方 ${enemy.name} 死亡。`);
      run.enemyBoard[lane] = null;
    }
  }
}

function checkCombatEnd() {
  const run = state.run;
  if (run.enemyHp <= 0) {
    run.gold += 12 + run.floor * 4;
    state.stats.battles += 1;
    if (run.floor >= LEVELS.length - 1) {
      state.stats.wins += 1;
      state.screen = "victory";
    } else {
      makeRewardChoices();
      state.screen = "reward";
    }
    return true;
  }
  if (run.playerHp <= 0) {
    state.stats.losses += 1;
    state.screen = "death";
    return true;
  }
  return false;
}

function spawnEnemyReinforcement() {
  const run = state.run;
  const empty = run.enemyBoard.map((card, i) => (card ? null : i)).filter(i => i !== null);
  if (!empty.length || Math.random() > 0.55) return;
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
  state.screen = "map";
  render();
}

function resetSave() {
  localStorage.removeItem(SAVE_KEY);
  state = freshState();
  render();
}

function cardImage(id) {
  return `${CARD_IMAGES}${id}.png`;
}

function renderCard(card, options = {}) {
  if (!card) return `<div class="lane-label">空位</div>`;
  const compact = options.compact ? " compact" : "";
  const selected = options.selected ? " is-selected" : "";
  const dead = card.hp <= 0 ? " is-dead" : "";
  const intent = options.enemy && card.intent ? `<div class="intent">${intentLabel(card.intent)}</div>` : "";
  return `
    <article class="card${compact}${selected}${dead}" ${options.testId ? `data-testid="${options.testId}"` : ""}>
      <img class="portrait" src="${cardImage(card.id)}" alt="${card.name}" onerror="this.style.visibility='hidden'" />
      <div class="cost">${card.cost}</div>
      ${intent}
      <div class="card-name">${card.name}</div>
      <div class="stats"><span>ATK <b>${card.attack}</b></span><span>HP <b>${card.hp}/${card.maxHp}</b></span></div>
      <div class="sigils">${card.sigils.length ? card.sigils.join(" · ") : card.family}</div>
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
            <button data-action="draw-debug">抽 1 张</button>
          </div>
          <div class="log" data-testid="combat-log">
            ${state.log.map(line => `<div>${line}</div>`).join("")}
          </div>
        </div>
        <aside class="hand-panel">
          <h3>手牌 (${run.hand.length})</h3>
          <div class="hand-list">
            ${run.hand.map((card, i) => `
              <div data-action="select-hand" data-index="${i}">
                ${renderCard(card, { compact: true, selected: state.selectedHand === i, testId: `hand-card-${i}` })}
              </div>
            `).join("") || `<p class="kbd">没有手牌。</p>`}
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
  if (action === "continue" && state.run) state.screen = state.run.phase === "map" ? "map" : state.screen;
  if (action === "reset-save") resetSave();
  if (action === "menu") state.screen = "menu";
  if (action === "node") startCombat(Number(target.dataset.floor));
  if (action === "select-hand") state.selectedHand = Number(target.dataset.index);
  if (action === "place") placeCard(Number(target.dataset.slot));
  if (action === "sacrifice") sacrifice(Number(target.dataset.slot));
  if (action === "battle") startBattle();
  if (action === "draw-debug") {
    drawCards(1);
    pushLog("调试抽牌 +1。");
  }
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
