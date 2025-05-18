# AKUMA NMAP SCANNER - 悪魔のポート解体ツール

_"In the static silence of the subnet... the demon counts your open ports."_

---

## 🚀 概要 (Overview)

**AKUMA NMAP SCANNER** — это шустрый демон разведки на базе `nmap`, заточенный под внутренние сети, периметры и корпоративную боль.

Работает по чёткой схеме: живой? — сканим. Порты есть? — долбим дальше.  
Все лишнее — в лог. Только то, что реально пригодится — в отчёт.

> 🔥 No clutter. No mercy. Just open ports and broken services.

---

## 💻 起動コマンド (Activation Sequence)

```bash
chmod +x nmap.sh
sudo ./nmap.sh -t 10.154.12.0/24 -A
````

---

## 🔪 特徴 (Features)

**地獄式ロジック:**

* 🎯 Ping Scan → живых отбирает, мертвых в лог
* 💣 Full Port Scan (65535 TCP) — быстро, грязно, эффективно
* 🧠 Optional Service Scan (`-A`) — анализ версий и баннеров только на нужных
* 🧾 Выход: всего 3 главных файла + 2 технических лога

**Demon Filters:**

* ❌ не тратит время на закрытые
* ❌ не лезет в мёртвые
* ✅ чистит всё ненужное
* ✅ выводит по делу, без шелухи

---

## 📦 出力ファイル (Output Files)

| Файл                | Содержимое                                      |
| ------------------- | ----------------------------------------------- |
| `live_hosts.txt`    | Только живые IP после ping-scan                 |
| `open_ports.txt`    | IP с открытыми портами, перечисление портов     |
| `services.txt`      | (если `-A`) баннеры и версии сервисов           |
| `closed_hosts.txt`  | Живые, но без портов (выведены, но неинтересны) |
| `skipped_hosts.log` | Пропущенные цели с причиной                     |

---

## ☠️ 地獄の依存関係 (Dependencies from Hell)

* `nmap`
* Linux-based OS (Kali, Parrot, Arch — всё подходит)

---

## 🗡️ 使用方法 (Usage)

```bash
# 1. Задать цель
sudo ./nmap.sh -t 10.154.12.0/24

# 2. Добавить глубокий скан сервисов
sudo ./nmap.sh -t 10.154.12.0/24 -A

# 3. Получить файлы
cat open_ports.txt
cat services.txt
```

---

## 🌌 出力例 (Sample Output)

```txt
[🩸 Вспышка демона началась...]
→ Живых хостов: 26
→ С открытыми портами: 14
→ С сервисами (баннерами): 8
→ Пропущено (пустые): 12

[✔] Отчёты сохранены. Ничто не скрылось.
```

---

## ⚠️ 免責事項 (Disclaimer)

Этот инструмент создан для **легального пентеста и Red Team операций**.
Любое несанкционированное использование — твоя ответственность.

> "Only the living bleed ports. The dead have nothing to scan."

---

```
        _  _                  _  _            
       / \/ \   _   _   _   / \/ \    _   _  
      / /\_/\ / \ / \ / \ / /\_/\ \ / \ / \ 
      \/      \_/ \_/ \_/ \/      \/ \_/ \_/ 
      悪魔は沈黙の中でも見ている...
```

GitHub: [https://github.com/sweetpotatohack/nmap-akuma](https://github.com/sweetpotatohack/nmap-akuma)
License: BSD 3-Clause "血の契約" (Кровавый контракт)

```
