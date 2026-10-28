# API Tools - Zphisher Native Edition

Ez a projekt a népszerű adathalász oktatóeszköz, a **Zphisher** egy erősen módosított, natív Kali Linuxra optimalizált és letisztított változata. A szkriptből minden felesleges Docker-függőség el lett távolítva, és az automatikus frissítési kényszer is ki lett iktatva a stabil, offline vagy módosított futtatás érdekében.

## 🚀 Főbb jellemzők

* **Natív futtatás:** Nincs szükség Dockerre, közvetlenül a gazdagépen (Kali Linux) fut.
* **Tisztított menü:** A választható szolgáltatások sorszámai szigorú numerikus sorrendben követik egymást (1-től 19-ig folyamatosan).
* **Bővített sablonok:** Hozzáadva a **MediaFire (18)** és a **GitHub (19)** opciók.
* **Letiltott frissítések:** Nem írja felül a módosításaidat indításkor, a GitHub-alapú frissítés teljesen ki van iktatva (`check_update` hatástalanítva).
* **Automatikus portkezelés:** Indításkor automatikusan ellenőrzi és lelövi a beragadt PHP vagy tunnel folyamatokat.

## 🛠️ Előfeltételek és Telepítés

A szkript első indításakor **automatikusan ellenőrzi és telepíti** a szükséges csomagokat (`php`, `curl`, `unzip`), ha azok hiányoznának.

1. Másold be az `apitools.sh` fájlt a kívánt mappába (például: `/home/kali/api_tools/`).
2. Adj futtatási jogot a szkriptnek:
   ```bash
   chmod +x apitools.sh
   ```
3. (Opcionális) Ha Windows környezetből másoltad át a kódot, futtasd le a soremelés tisztítót a hiba elkerülése érdekében:
   ```bash
   sed -i 's\(/\r\)\$//' apitools.sh
   ```

## 💻 Használat

A teljes menürendszer és a szerver elindításához egyszerűen futtasd a szkriptet:
```bash
bash apitools.sh
```

### Elérhető menüpontok:
* **1 - 19:** Különböző közösségi média, felhő alapú tárhely és játékos platformok sablonjai (Facebook, Google, Discord, MediaFire, GitHub, stb.).
* **99:** Információ az eszközről (About).
* **00:** Kilépés a programból.

A szolgáltatás kiválasztása után a szkript felajánlja a **Helyi szerver (Localhost)** vagy a **Cloudflared** alapú nyilvános alagút indítását, amely automatikusan legenerálja a maszkolt eléréseket.

## 🗂️ Mentett adatok elérése

A megszerzett hitelesítési adatok és áldozati IP címek automatikusan a szkript melletti `auth/` mappába mentődnek:
* **IP címek:** `auth/ip.txt`
* **Felhasználónevek és jelszavak:** `auth/usernames.dat`

## ⚠️ Jogi nyilatkozat

Ez az eszköz **kizárólag oktatási és etikus tesztelési (Pentest) célokra készült**. A szoftver jogosulatlan vagy rosszindulatú használata törvénybe ütközik. A fejlesztő nem vállal felelősséget a szkript nem megfelelő használatából eredő károkért!
