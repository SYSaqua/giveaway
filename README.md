# Giveaway

A simple FiveM giveaway resource made for free for the Roleplay Server **Midnight**.  
Feel free to use it.

Built for **ESX**. Frontend and backend by **sysaqua**.

---

## Features

- Start giveaways for **items**, **money**, or **weapons**
- Players join by pressing **Enter**
- Live NUI overlay with prize, entry count, and countdown
- Random winner when the timer ends
- Permission-gated admin command
- Late joiners still see an active giveaway
- Entries clean up when a player disconnects

---

## Requirements

- [ESX](https://github.com/esx-framework/esx_core)
- Your notify event (`midnight_core:hud:notify` by default — change it in config if needed)

---

## Installation

1. Drop the resource into your `resources` folder
2. Add `ensure giveaway` to your `server.cfg`
3. Restart the server

---

## Usage

```
/giveaway start <type> <item> <label> <amount> <entries> <duration>
/giveaway stop
```

| Arg | Description |
|---|---|
| `type` | `item`, `money`, or `weapon` |
| `item` | Item / weapon name (ignored for money if unused) |
| `label` | Display name shown in the UI |
| `amount` | How much of the prize |
| `entries` | Max participants |
| `duration` | Duration in minutes |

**Example**

```
/giveaway start item bread Bread 5 20 5
```

Starts a giveaway for 5x Bread, max 20 players, lasting 5 minutes.

---

## Config

Everything important lives in `backend/config/config.lua`:

| Option | What it does |
|---|---|
| `GIVEAWAY.Key` | Key to join (default: Enter / `191`) |
| `GIVEAWAY.LoadDelay` | Delay before syncing active giveaway on join |
| `GIVEAWAY.Command` | Command name, description, and allowed groups |
| `Notify` | Swap in your own notification system |

Default permission groups: `pl`, `admin`, `dev`.

---

## Structure

```
giveaway/
├── backend/
│   ├── config/config.lua
│   ├── client/main.lua
│   └── server/main.lua
├── frontend/
│   ├── index.html
│   └── assets/
└── fxmanifest.lua
```

---

Made for **Midnight Roleplay**. Free to use.
