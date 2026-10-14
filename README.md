# 骰子傭兵團 / Dice Mercenaries

Independent Windows-first Godot 4.7.2 + typed GDScript project.
Design contract: [docs/GAME_PLAN.md](docs/GAME_PLAN.md). Current work: governance onboarding and DM-00; no gameplay yet.

## Setup
```sh
git clone --recurse-submodules https://github.com/Gavin0099/DiceMercenaries.git
cd DiceMercenaries
PYTHONPATH=.ai-governance-framework python -m governance_tools.hook_installer --repo . --framework-root .ai-governance-framework
```
Governance source is pinned as a submodule. Hooks are local; every new checkout must install them.
Owner/reviewer acceptance is required. No automatic merge or release.
