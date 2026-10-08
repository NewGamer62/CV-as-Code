# 📄 CV-as-Code

[![Build & Publish CV](https://github.com/NewGamer62/CV-as-Code/actions/workflows/build-cv.yml/badge.svg)](https://github.com/NewGamer62/CV-as-Code/actions/workflows/build-cv.yml)
[![Download Latest CV](https://img.shields.io/badge/Download-Latest%20CV%20(PDF)-blue?logo=adobeacrobatreader)](https://github.com/NewGamer62/CV-as-Code/releases/latest/download/cv.pdf)

Projet de **CV-as-Code** automatisé, bicolonne, conçu pour être :
1. **100% lisible par les ATS et les IA** (texte vectoriel pur, données sémantiques).
2. **Élégant et professionnel pour les recruteurs** (mise en page millimétrée avec [Typst](https://typst.app/)).
3. **Synchronisé automatiquement avec GitHub** (récupération de tes projets publics et de tes dépôts privés de stage).

---

## 🏗️ Structure du Projet

```text
CV-as-Code/
├── data/
│   ├── cv_fr.yaml          # Données de la version française
│   └── cv_en.yaml          # Données de la version anglaise
├── templates/
│   └── cv.typ              # Modèle Typst universel et bilingue (RH)
├── scripts/
│   └── sync_and_build.py   # Script de synchronisation GitHub & double compilation
├── assets/
│   └── profile.jpg         # Ta photo de profil détourée
├── .github/workflows/
│   └── build-cv.yml        # CI/CD : génération automatique et publication des 2 versions
└── requirements.txt        # Dépendances Python (requests, pyyaml, typst)
```

---

## ⚙️ Configuration & Personnalisation

### 1. Modifier tes informations
Édite simplement le fichier `data/cv.yaml`. C'est l'unique endroit où tu gères :
- Tes coordonnées (email, téléphone, adresse, date de naissance).
- Ton résumé / profil.
- Tes formations et expériences.
- Tes compétences techniques et langues.

### 2. Ajouter ta photo (optionnel)
Place ton fichier photo dans `assets/profile.jpg`. Si aucun fichier n'est présent, un avatar élégant avec tes initiales est généré automatiquement.

### 3. Synchronisation des projets GitHub
Dans `data/cv.yaml`, la section `github_sync` permet de piloter la récupération :
```yaml
github_sync:
  username: "NewGamer62"
  topic_filter: "portfolio"     # Seuls les repos avec ce tag GitHub seront récupérés
  include_repos:                # Dépôts à inclure obligatoirement (ex: dépôt privé de stage)
    - "nom-de-ton-repo-de-stage"
  max_projects: 4
```

---

## 🔒 Accès aux dépôts privés (Stage)

Pour que GitHub Actions puisse lire ton dépôt privé de stage :
1. Génère un **Personal Access Token (classic)** sur GitHub ([Lien direct](https://github.com/settings/tokens)) avec la permission **`repo`**.
2. Dans ton dépôt `CV-as-Code`, va dans **Settings > Secrets and variables > Actions**.
3. Ajoute un secret nommé `PAT_GITHUB` avec la valeur de ton token.

---

## 💻 Utilisation Locale

### Installation des dépendances :
```bash
pip install -r requirements.txt
```

### Générer le CV en PDF :
```bash
python scripts/sync_and_build.py
```
Le fichier `cv.pdf` est généré directement à la racine du projet.

---

## 🤖 Automatisation (CI/CD)

Le workflow GitHub Actions s'exécute automatiquement :
- À chaque `push` sur la branche `main` modifiant le CV.
- Chaque **lundi à 06h00 UTC** pour synchroniser tes derniers commits et projets GitHub.
- Manuellement via l'onglet **Actions** > **Run workflow** sur GitHub.

Le PDF compilé est automatiquement publié dans la section **[Releases](https://github.com/NewGamer62/CV-as-Code/releases)** avec un lien de téléchargement permanent.