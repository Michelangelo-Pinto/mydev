from jinja2 import Template
import yaml
import os
from pathlib import Path
from dotenv import dotenv_values
from typing import Dict
import pprint

# === Settings ===
PROJECT_ROOT = Path.cwd()
MANIFEST_TEMPLATE = PROJECT_ROOT / "manifest.yaml.j2"
VALUES_FILE = PROJECT_ROOT / "values.yaml"
GENERATED_MANIFEST = PROJECT_ROOT / "manifest.generated.yaml"

# === Load variable values from values.yaml and .env (override if both exist) ===
def load_context_variables() -> Dict[str, str]:
    values = {}
    if VALUES_FILE.exists():
        with open(VALUES_FILE) as f:
            values = yaml.safe_load(f) or {}
    env_vars = dotenv_values(PROJECT_ROOT / ".env")  # Optional override
    return {**values, **env_vars}

# === Render Jinja2 template ===
def render_manifest_template(context: Dict[str, str]) -> str:
    with open(MANIFEST_TEMPLATE) as f:
        raw_template = f.read()
    template = Template(raw_template)
    return template.render(**context)

# === Parse YAML from rendered template ===
def parse_manifest(rendered_yaml: str) -> Dict:
    return yaml.safe_load(rendered_yaml)

# === Save rendered YAML for debugging ===
def save_rendered_manifest(rendered_yaml: str):
    with open(GENERATED_MANIFEST, "w") as f:
        f.write(rendered_yaml)

# === MAIN ===
def main():
    print("🔧 Loading context variables...")
    context = load_context_variables()
    
    print("📄 Rendering manifest template...")
    rendered_yaml = render_manifest_template(context)
    
    print("💾 Saving generated manifest to:", GENERATED_MANIFEST)
    save_rendered_manifest(rendered_yaml)
    
    print("📦 Parsing rendered manifest...")
    manifest = parse_manifest(rendered_yaml)
    
    print("✅ Manifest content:")
    pprint.pprint(manifest)

if __name__ == "__main__":
    main()
