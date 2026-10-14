# Decisions / candidate clarifications

- Owner supplied GAME_PLAN v0.1 is preserved byte-for-byte. Historical “repo not created” text remains provenance; PLAN.md records current execution state.
- DM-00 contains an empty status screen and test entry, not combat. Destructible geometry remains DM-02; spec §17's early terrain demonstration does not silently enlarge DM-01.
- `scripts/domain` will contain pure typed GDScript rules; Godot physics lives in `scripts/combat`; UI lives in `scripts/presentation`; RNG/save/logging in `scripts/infrastructure`. No interface framework is added before a concrete need.
- Governance domain/risk proposal requires Owner review. Framework source is unmodified. GDScript enum support is unresolved; gameplay implementation must not mislabel language to pass governance.
