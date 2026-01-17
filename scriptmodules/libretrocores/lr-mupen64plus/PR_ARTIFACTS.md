Build artifacts and local verification
====================================

Artifacts produced locally (x86_64)
----------------------------------

- `tmp/build/lr-mupen64plus/mupen64plus_libretro.so` : (not present on this host at scan time) — built earlier during verification on 2026-01-16.
- `tmp/build/lr-parallel-n64/parallel_n64_libretro.so` :
  - Path: `tmp/build/lr-parallel-n64/parallel_n64_libretro.so`
  - Size: 2.6M
  - SHA256: 7a657213523b16ef911a0a1ce15bd0b63e386f8cb783fa33192d25340dd8b2b4

Build scan (warnings / errors)
------------------------------
- Recent build-tree scan produced no "error:" lines in `tmp/build` at scan time.
- Warnings exist in various subprojects (normal for large C/C++ builds); maintainers should review CI logs if strict warnings-as-errors policies are in place.

Notes
-----
- If you want full raw build logs (stdout/stderr) for the exact make runs I executed, I can re-run the builds and capture logs to files and attach them here — say so and I will re-run and upload `build-mupen64plus.log` and `build-parallel-n64.log` to the branch.
