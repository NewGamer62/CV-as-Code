import os
import json
import shutil
import yaml
import requests
import typst
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "data"
TEMPLATES_DIR = BASE_DIR / "templates"
TYPST_TEMPLATE = TEMPLATES_DIR / "cv.typ"

LANGUAGES = ["fr", "en"]


def fetch_github_projects(config):
    """
    Récupère les projets depuis l'API GitHub selon la configuration.
    Gère les repos privés, les filtres, et les enrichissements via repo_overrides.
    """
    gh_cfg = config.get("github_sync", {})
    username = gh_cfg.get("username", "NewGamer62")
    topic_filter = gh_cfg.get("topic_filter", "")
    include_repos = gh_cfg.get("include_repos", [])
    exclude_repos = set(gh_cfg.get("exclude_repos", []))
    max_projects = gh_cfg.get("max_projects", 4)
    overrides = config.get("repo_overrides", {})

    token = os.getenv("PAT_GITHUB") or os.getenv("GITHUB_TOKEN")
    headers = {"Accept": "application/vnd.github.v3+json"}
    if token:
        headers["Authorization"] = f"Bearer {token}"

    projects = []
    seen_names = set()

    # 1. Récupération des dépôts explicitement listés (notamment les dépôts privés ou externes)
    for repo_entry in include_repos:
        if repo_entry in exclude_repos or repo_entry in seen_names:
            continue

        if "/" in repo_entry:
            url = f"https://api.github.com/repos/{repo_entry}"
            repo_name = repo_entry.split("/")[-1]
        else:
            url = f"https://api.github.com/repos/{username}/{repo_entry}"
            repo_name = repo_entry

        proj_data = None

        try:
            resp = requests.get(url, headers=headers, timeout=10)
            if resp.status_code == 200:
                proj_data = format_project(resp.json())
            else:
                print(f"[INFO] Dépôt '{repo_name}' non accessible publiquement (Code: {resp.status_code}).")
        except Exception as e:
            print(f"[WARN] Erreur lors de la requête pour '{repo_name}': {e}")

        # Recherche d'une éventuelle surcharge (clé owner/repo ou repo_name)
        ov = overrides.get(repo_entry) or overrides.get(repo_name)

        # Si le repo n'est pas accessible sans token, ou si on a un override
        if not proj_data and ov:
            proj_data = {
                "name": ov.get("name", repo_name),
                "raw_name": repo_name,
                "description": ov.get("description", "Projet de développement logiciel."),
                "language": ov.get("language", "Code"),
                "url": f"https://github.com/{repo_entry if '/' in repo_entry else f'{username}/{repo_name}'}",
                "stars": 0,
                "is_private": ov.get("is_private", False),
                "topics": [],
            }

        if proj_data:
            # Application des surcharges si renseignées
            if ov:
                if ov.get("name"):
                    proj_data["name"] = ov["name"]
                if ov.get("description"):
                    proj_data["description"] = ov["description"]
                if ov.get("language"):
                    proj_data["language"] = ov["language"]
                if "is_private" in ov:
                    proj_data["is_private"] = ov["is_private"]

            projects.append(proj_data)
            seen_names.add(repo_entry)

    # 2. Récupération des dépôts complémentaires par topic / récence
    if len(projects) < max_projects:
        url = f"https://api.github.com/users/{username}/repos?sort=pushed&per_page=30"
        try:
            resp = requests.get(url, headers=headers, timeout=10)
            if resp.status_code == 200:
                all_repos = resp.json()
                for repo in all_repos:
                    if len(projects) >= max_projects:
                        break
                    r_name = repo.get("name")
                    if r_name in seen_names or r_name in exclude_repos:
                        continue
                    topics = repo.get("topics", [])
                    if not topic_filter or topic_filter in topics:
                        p_data = format_project(repo)
                        if r_name in overrides:
                            ov = overrides[r_name]
                            if ov.get("name"):
                                p_data["name"] = ov["name"]
                            if ov.get("description"):
                                p_data["description"] = ov["description"]
                            if ov.get("language"):
                                p_data["language"] = ov["language"]
                        projects.append(p_data)
                        seen_names.add(r_name)
        except Exception as e:
            print(f"[WARN] Erreur lors du listing des dépôts GitHub: {e}")

    return projects[:max_projects]


def format_project(repo_data):
    """Normalise les données d'un dépôt GitHub"""
    return {
        "name": repo_data.get("name", "").replace("-", " ").title(),
        "raw_name": repo_data.get("name", ""),
        "description": repo_data.get("description") or "Projet de développement logiciel.",
        "language": repo_data.get("language") or "Code",
        "url": repo_data.get("html_url", ""),
        "stars": repo_data.get("stargazers_count", 0),
        "is_private": repo_data.get("private", False),
        "topics": repo_data.get("topics", []),
    }


def build_version(lang: str):
    yaml_file = DATA_DIR / f"cv_{lang}.yaml"
    if not yaml_file.exists():
        print(f"[WARN] Fichier de données manquant pour '{lang}': {yaml_file}")
        return

    with open(yaml_file, "r", encoding="utf-8") as f:
        cv_data = yaml.safe_load(f)

    # Récupération des projets avec les surcharges propres à la langue
    github_projects = fetch_github_projects(cv_data)
    cv_data["github_projects"] = github_projects

    # Vérification de l'existence de la photo
    photo_rel = cv_data.get("profile", {}).get("photo", "")
    cv_data["profile"]["has_photo"] = bool(photo_rel and (BASE_DIR / photo_rel).exists())

    # Export du JSON calculé
    computed_json_file = DATA_DIR / f"cv_computed_{lang}.json"
    with open(computed_json_file, "w", encoding="utf-8") as f:
        json.dump(cv_data, f, ensure_ascii=False, indent=2)

    # Compilation PDF avec Typst
    output_pdf = BASE_DIR / f"cv_{lang}.pdf"
    root_json_path = f"/data/cv_computed_{lang}.json"

    typst.compile(
        str(TYPST_TEMPLATE),
        output=str(output_pdf),
        root=str(BASE_DIR),
        sys_inputs={"data_file": root_json_path}
    )
    print(f"-> Succès : {output_pdf.name} généré ({len(github_projects)} projets).")

    # Si c'est la version FR, on crée aussi cv.pdf par défaut
    if lang == "fr":
        shutil.copy(output_pdf, BASE_DIR / "cv.pdf")
        print("-> Copie par défaut : cv.pdf mis à jour.")


def main():
    print("=== Démarrage de la génération bilingue du CV ===")
    for lang in LANGUAGES:
        print(f"-> Traitement de la version [{lang.upper()}]...")
        build_version(lang)
    print("=== Génération terminée avec succès ! ===")


if __name__ == "__main__":
    main()
