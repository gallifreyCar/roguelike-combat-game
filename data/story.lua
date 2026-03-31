-- data/story.lua - 故事/剧情系统
-- 世界观、NPC对话、剧情文本

local Story = {}

-- 世界观设定
Story.world = {
    title = "Blood Cards",
    subtitle = "A Tale of Cards and Sacrifice",

    lore = [[
In a realm where souls are bound to cards, the Blood Lord reigns supreme.
Only those who master the art of sacrifice can challenge his throne.

Each card holds a creature's essence. Each drop of blood awakens their power.
Fuse them, sacrifice them, become stronger.

The path to freedom lies through 8 layers of trials.
Will you break the chains, or become another card in the Blood Lord's collection?
    ]],

    characters = {
        blood_lord = {
            name = "The Blood Lord",
            title = "Master of the Card Realm",
            desc = "The mysterious ruler who binds souls to cards.",
        },
        mysterious_merchant = {
            name = "The Merchant",
            title = "Wandering Trader",
            desc = "A hooded figure who trades in cards and secrets.",
        },
        fusion_master = {
            name = "The Alchemist",
            title = "Keeper of Fusion",
            desc = "An ancient being who knows the secrets of card merging.",
        },
    },
}

-- 开场剧情
Story.intro = {
    {
        speaker = "narrator",
        text = "The blood moon rises over the Card Realm...",
    },
    {
        speaker = "narrator",
        text = "You awaken in a dark chamber, cards floating around you.",
    },
    {
        speaker = "mysterious_merchant",
        text = "Ah, another soul bound to cards. Seeking freedom, are we?",
    },
    {
        speaker = "mysterious_merchant",
        text = "The Blood Lord's tower awaits. Eight floors of trials.",
    },
    {
        speaker = "mysterious_merchant",
        text = "Sacrifice cards to gain blood. Fuse them to grow stronger.",
    },
    {
        speaker = "narrator",
        text = "Your journey begins. May your cards serve you well.",
    },
}

-- Boss 战前剧情
Story.boss_encounters = {
    [3] = {
        {
            speaker = "narrator",
            text = "The air grows heavy with blood magic...",
        },
        {
            speaker = "blood_lord",
            text = "You've made it past the first trials. Impressive.",
        },
        {
            speaker = "blood_lord",
            text = "But the true test begins now. Face my champions!",
        },
    },
    [5] = {
        {
            speaker = "narrator",
            text = "The walls pulse with crimson energy...",
        },
        {
            speaker = "blood_lord",
            text = "Halfway to my throne. You are... persistent.",
        },
        {
            speaker = "blood_lord",
            text = "Let us see how you handle REAL power.",
        },
    },
    [8] = {
        {
            speaker = "narrator",
            text = "The final chamber. A throne of cards and bone.",
        },
        {
            speaker = "blood_lord",
            text = "So. You've come to challenge ME.",
        },
        {
            speaker = "blood_lord",
            text = "I created this world. I bound the first souls to cards.",
        },
        {
            speaker = "blood_lord",
            text = "Every card you played, every sacrifice you made...",
        },
        {
            speaker = "blood_lord",
            text = "...only brought you closer to becoming MY card.",
        },
        {
            speaker = "blood_lord",
            text = "Prove your worth, or join my collection FOREVER!",
        },
    },
}

-- 结局
Story.endings = {
    victory = {
        {
            speaker = "narrator",
            text = "The Blood Lord falls. His cards scatter to the wind.",
        },
        {
            speaker = "narrator",
            text = "You feel the bindings on your soul loosen...",
        },
        {
            speaker = "narrator",
            text = "Freedom. At last.",
        },
        {
            speaker = "mysterious_merchant",
            text = "Well done, card-binder. You've broken the cycle.",
        },
        {
            speaker = "mysterious_merchant",
            text = "But remember... power has a price.",
        },
        {
            speaker = "narrator",
            text = "THE END - FREEDOM ACHIEVED",
        },
    },
    death = {
        {
            speaker = "narrator",
            text = "Your vision fades. The cards slip from your grasp.",
        },
        {
            speaker = "blood_lord",
            text = "Another soul for my collection...",
        },
        {
            speaker = "narrator",
            text = "You feel yourself being drawn into a card...",
        },
        {
            speaker = "narrator",
            text = "...destined to serve the Blood Lord for eternity.",
        },
    },
}

-- NPC 对话（商店、融合、事件）
Shop.dialogues = {
    welcome = {
        "Welcome, card-binder. Care to browse my wares?",
        "Gold speaks louder than blood here.",
        "Each card has a story. Some darker than others.",
    },
    purchase = {
        "A fine choice. Use it wisely.",
        "May it serve you better than its previous owner.",
        "Sold! No returns in the Card Realm.",
    },
    no_gold = {
        "Empty pockets? The Blood Lord wasn't kidding about sacrifice.",
        "Come back when you've... accumulated more.",
        "Gold makes the cards flow. Remember that.",
    },
}

FusionMaster.dialogues = {
    welcome = {
        "Ah, seeking the art of fusion? Wise.",
        "Two become one. The ancients understood this power.",
        "Bring me cards. I'll show you transformation.",
    },
    fuse_success = {
        "Magnificent! The essence has merged perfectly!",
        "A new being emerges from the sacrifice.",
        "The cards whisper their gratitude... or their screams.",
    },
    fuse_fail = {
        "The fusion rejects. Too unstable.",
        "Not all cards are meant to merge.",
        "Sometimes... the sacrifice is the only result.",
    },
}

-- 事件节点文本
Story.events = {
    fountain = {
        name = "Blood Fountain",
        desc = "A fountain of crimson liquid. Drink?",
        choices = {
            { text = "Drink (+1 Blood permanently)", effect = "blood_up" },
            { text = "Leave", effect = "none" },
        },
    },
    shrine = {
        name = "Card Shrine",
        desc = "An ancient shrine with card offerings. Pray?",
        choices = {
            { text = "Pray (Heal 5 HP)", effect = "heal" },
            { text = "Desecrate (Gain 20 Gold, lose 2 HP)", effect = "gold_sacrifice" },
            { text = "Leave", effect = "none" },
        },
    },
    mysterious_card = {
        name = "Mysterious Card",
        desc = "A card lies on the ground, glowing faintly.",
        choices = {
            { text = "Take it (Random card)", effect = "random_card" },
            { text = "Destroy it (Gain 10 Gold)", effect = "gold" },
        },
    },
}

return Story