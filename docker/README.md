# OPEN-PROM Docker Setup

Αυτός ο φάκελος περιέχει τα αρχεία για να τρέχει το OPEN-PROM μέσα από Docker:

- `Dockerfile`
- `docker-compose.yml`
- `config.container.json`
- `.env.example`
- `docker/install-r-packages.R`

Το container εκτελεί το μοντέλο με:

```sh
Rscript start.R
```

και από προεπιλογή τρέχει:

```sh
Rscript start.R task_id=2
```

## Προαπαιτούμενα

Χρειάζεσαι:

- Docker Desktop ή Docker Engine με Docker Compose.
- Μία Linux εγκατάσταση του GAMS.
- Έγκυρη GAMS license για αυτή την εγκατάσταση.
- Τα input folders `data/` και `targets/` στο root του repository.

Σημαντικό: η υπάρχουσα Windows εγκατάσταση `C:\GAMS\47` δεν μπορεί να εκτελεστεί μέσα στο Linux container. Το container χρειάζεται Linux GAMS binary.

## GAMS Path

Το `docker-compose.yml` κάνει mount το GAMS στο container path:

```text
/opt/gams
```

Άρα μέσα στο container το executable πρέπει να υπάρχει εδώ:

```text
/opt/gams/gams
```

Στο host μηχάνημα δηλώνεις το πραγματικό path μέσω `.env`.

Πρώτα φτιάξε `.env` από το template:

```sh
cp .env.example .env
```

Σε Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Μετά άνοιξε το `.env` και άλλαξε το placeholder:

```text
GAMS_HOME=/path/to/linux/gams
```

σε πραγματικό path. Παραδείγματα:

```text
GAMS_HOME=/home/user/gams/47
```

ή, αν τρέχεις Docker Desktop με WSL και το GAMS είναι μέσα στο WSL:

```text
GAMS_HOME=/home/plessias/GAMS/47
```

Το folder που θα δηλώσεις πρέπει να περιέχει το executable `gams`.

## GAMS License

Το Docker setup δεν εγκαθιστά ούτε αντιγράφει GAMS license. Υποθέτει ότι η Linux εγκατάσταση που κάνεις mount μέσω `GAMS_HOME` είναι ήδη λειτουργική.

Αν η license βρίσκεται σε ξεχωριστό path, πρόσθεσε επιπλέον volume στο `docker-compose.yml`, για παράδειγμα:

```yaml
      - /path/to/gams/license:/opt/gams/license:ro
```

Η ακριβής ρύθμιση εξαρτάται από το πώς είναι εγκατεστημένο το GAMS στο σύστημά σου.

## Container Config

Το container χρησιμοποιεί το:

```text
config.container.json
```

και όχι το local `config.json`.

Αυτό γίνεται μέσω:

```yaml
environment:
  OPENPROM_CONFIG: config.container.json
```

Τα σημαντικά paths μέσα στο `config.container.json` είναι:

```json
{
  "paths": {
    "model_runs_path": "/outputs",
    "magpie_path": "/magpie/",
    "gams_path": "/opt/gams/"
  }
}
```

Σημασία των paths:

- `/opt/gams/`: το GAMS mount μέσα στο container.
- `/outputs`: folder όπου αντιγράφονται archived outputs όταν `withSync=true`.
- `/magpie/`: placeholder για MAgPIE, χρήσιμο μόνο για task 7 / soft-linking.

Για απλό OPEN-PROM run με `task_id=2`, το `/magpie/` δεν χρειάζεται να υπάρχει.

## Mounted Folders

Το `docker-compose.yml` κάνει mount:

```yaml
      - ./config.container.json:/open-prom/config.container.json:ro
      - ./data:/open-prom/data:ro
      - ./targets:/open-prom/targets:ro
      - ./runs:/open-prom/runs
      - ./outputs:/outputs
      - ${GAMS_HOME:-/path/to/linux/gams}:/opt/gams:ro
```

Δηλαδή:

- `data/` και `targets/` διαβάζονται από το host και είναι read-only.
- `runs/` γράφεται από το container και μένει στο host.
- `outputs/` γράφεται από το container όταν ενεργοποιείται sync.
- `GAMS_HOME` γίνεται mount ως `/opt/gams`.

## R Packages

Το image εγκαθιστά R packages από CRAN και R-universe.

Default R-universe repos:

```text
https://pik-piam.r-universe.dev
https://e3modelling.r-universe.dev
```

Τα `mrprom` και `postprom` εγκαθίστανται από GitHub:

```text
https://github.com/e3modelling/mrprom.git
https://github.com/e3modelling/postprom.git
```

Αν θέλεις να αλλάξεις package sources, δώσε build args:

```sh
docker compose build \
  --build-arg R_UNIVERSE_REPOS="https://pik-piam.r-universe.dev,https://e3modelling.r-universe.dev" \
  --build-arg GITHUB_R_PACKAGES="https://github.com/e3modelling/mrprom.git,https://github.com/e3modelling/postprom.git"
```

Το installer βρίσκεται στο:

```text
docker/install-r-packages.R
```

## IAMC Common Definitions

Το image κάνει clone το:

```text
https://github.com/IAMconsortium/common-definitions.git
```

στο container path:

```text
/opt/iamc/common-definitions
```

και ορίζει:

```text
IAMC_COMMON_DEFINITIONS=/opt/iamc/common-definitions
```

Εγκαθίσταται επίσης το Python package:

```text
nomenclature-iamc
```

Αυτό είναι χρήσιμο για IAMC codelists, mappings, validation και exports. Δεν είναι το ίδιο πράγμα με το R package `iamc`.

## Build

Από το root του repository:

```sh
docker compose build
```

Σε PowerShell:

```powershell
docker compose build
```

Αν αλλάξεις R package sources, common-definitions branch ή Dockerfile dependencies, κάνε rebuild:

```sh
docker compose build --no-cache
```

## Single Scenario Run

Πρώτα έλεγξε/ρύθμισε το scenario στο:

```text
config.container.json
```

Μετά τρέξε:

```sh
docker compose run --rm open-prom
```

Αυτό χρησιμοποιεί το default command από `docker-compose.yml`:

```yaml
command: ["task_id=2"]
```

Άρα ισοδυναμεί με:

```sh
docker compose run --rm open-prom task_id=2
```

Για άλλο task:

```sh
docker compose run --rm open-prom task_id=0
```

ή:

```sh
docker compose run --rm open-prom task_id=5
```

## Batch Run

Για batch mode, δώσε CSV:

```sh
docker compose run --rm open-prom scenarios.template.csv
```

Για δικό σου CSV, πρώτα βεβαιώσου ότι το αρχείο δεν αγνοείται ή ότι υπάρχει στο working tree που γίνεται mount/copy στο image. Παράδειγμα:

```sh
docker compose run --rm open-prom scenarios.csv
```

Το `start.R` υποστηρίζει batch mode για tasks που είναι batch-compatible.

## Outputs

Με:

```json
"withRunFolder": true
```

τα runs γράφονται στο:

```text
runs/
```

Με:

```json
"withSync": true
```

το archive αντιγράφεται στο:

```text
outputs/
```

Στο τωρινό `config.container.json`:

```json
"withSync": true,
"uploadGDX": false
```

Άρα το sync archive δεν περιλαμβάνει `.gdx` outputs, ώστε να μένει μικρότερο.

Αν θέλεις να περιλαμβάνει και `.gdx`:

```json
"uploadGDX": true
```

## MAgPIE / Task 7

Το `config.container.json` έχει:

```json
"magpie_path": "/magpie/"
```

Αυτό είναι placeholder. Για task 7 χρειάζεται να κάνεις mount MAgPIE στο `/magpie`.

Παράδειγμα στο `docker-compose.yml`:

```yaml
      - /path/to/magpie:/magpie
```

Τότε το host path `/path/to/magpie` πρέπει να περιέχει το MAgPIE setup και το `e3m_start.R` που καλεί το `task7SoftLinkMagpie.R`.

Αν δεν τρέχεις task 7, μπορείς να αγνοήσεις το `/magpie/`.

## Useful Commands

Build:

```sh
docker compose build
```

Run default task 2:

```sh
docker compose run --rm open-prom
```

Run explicit task:

```sh
docker compose run --rm open-prom task_id=2
```

Run batch:

```sh
docker compose run --rm open-prom scenarios.template.csv
```

Open a shell inside the container:

```sh
docker compose run --rm --entrypoint bash open-prom
```

Check whether GAMS is visible inside the container:

```sh
docker compose run --rm --entrypoint bash open-prom -lc "which gams && gams"
```

Check R packages:

```sh
docker compose run --rm --entrypoint Rscript open-prom -e "library(mrprom); library(postprom); library(gdx); library(quitte)"
```

## Troubleshooting

If Docker says that `/path/to/linux/gams` does not exist, `.env` has not been configured. Set:

```text
GAMS_HOME=/real/linux/path/to/gams
```

If `gams` is not found inside the container, check that:

- `GAMS_HOME` points to the folder containing the Linux `gams` executable.
- The compose volume maps it to `/opt/gams`.
- `config.container.json` has `"gams_path": "/opt/gams/"`.

If GAMS starts but reports a license error, the GAMS installation or license mount is incomplete.

If an R package fails to install, check:

- Whether the package exists in the configured R-universe repos.
- Whether GitHub access is available during `docker compose build`.
- Whether `GITHUB_R_PACKAGES` contains the correct repo URLs.

If task 7 fails because MAgPIE is missing, add a `/magpie` volume and update `magpie_path` if needed.

If outputs are missing, check:

- `withRunFolder`
- `withSync`
- `model_runs_path`
- whether `./runs` and `./outputs` exist or can be created by Docker.
