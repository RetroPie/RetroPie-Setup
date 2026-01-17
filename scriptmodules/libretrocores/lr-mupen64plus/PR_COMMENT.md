This pull request contains focused build fixes for `lr-mupen64plus` and a companion fix
for `lr-parallel-n64` to resolve recent compile/link failures on modern toolchains.

Summary
-------
- Add three small, mechanical patches that address API and symbol issues:
  1. `0003-fix-resampler-init.patch` — update libretro-common resampler driver init
     signatures to accept `enum resampler_quality` (sinc, nearest) and mark the
     parameter used in the `null` resampler.
  2. `0004-fix-zlib-crc.patch` — use `z_crc_t` for CRC table pointer types in zip
     related sources to match zlib typedefs and avoid incompatible-pointer warnings.
  3. `0005-fix-fsqrt-rename.patch` — rename dynarec helper `fsqrt` -> `fsqrt_emu`
     and update callers to avoid symbol collisions; companion patch added for
     `lr-parallel-n64` to prevent cross-core link errors.

Files added in this PR
----------------------
- scriptmodules/libretrocores/lr-mupen64plus/0003-fix-resampler-init.patch
- scriptmodules/libretrocores/lr-mupen64plus/0004-fix-zlib-crc.patch
- scriptmodules/libretrocores/lr-mupen64plus/0005-fix-fsqrt-rename.patch
- scriptmodules/libretrocores/lr-parallel-n64/0001-fix-fsqrt-rename.patch
- scriptmodules/libretrocores/lr-mupen64plus/CHANGELOG.md
- scriptmodules/libretrocores/lr-mupen64plus/PR_ARTIFACTS.md
- scriptmodules/libretrocores/lr-mupen64plus/PR_DESCRIPTION.md

Verification
------------
- Local x86_64 builds completed:
  - `tmp/build/lr-mupen64plus/mupen64plus_libretro.so` (built during verification)
  - `tmp/build/lr-parallel-n64/parallel_n64_libretro.so` (produced and checksumed)
- The original link failure was caused by a duplicate `fsqrt` symbol in another
  mupen variant; the companion `lr-parallel-n64` patch resolves that.

Testing / Recommendation
-----------------------
- Run package builds on target architectures (armhf/arm64) via the usual CI or
  `sudo ./retropie_setup.sh` on target hardware to validate cross-arch compilation.
- After installing the built cores, perform a quick RetroArch smoke test to confirm
  emulation and audio/resampler behavior are unchanged.

This pull request contains focused build fixes for `lr-mupen64plus` and a companion fix
for `lr-parallel-n64` to resolve recent compile/link failures on modern toolchains.

Summary
-------
- Add three small, mechanical patches that address API and symbol issues:
  1. `0003-fix-resampler-init.patch` — update libretro-common resampler driver init
     signatures to accept `enum resampler_quality` (sinc, nearest) and mark the
     parameter used in the `null` resampler.
  2. `0004-fix-zlib-crc.patch` — use `z_crc_t` for CRC table pointer types in zip
     related sources to match zlib typedefs and avoid incompatible-pointer warnings.
  3. `0005-fix-fsqrt-rename.patch` — rename dynarec helper `fsqrt` -> `fsqrt_emu`
     and update callers to avoid symbol collisions; companion patch added for
     `lr-parallel-n64` to prevent cross-core link errors.

Files added in this PR
----------------------
- scriptmodules/libretrocores/lr-mupen64plus/0003-fix-resampler-init.patch
- scriptmodules/libretrocores/lr-mupen64plus/0004-fix-zlib-crc.patch
- scriptmodules/libretrocores/lr-mupen64plus/0005-fsqrt-rename.patch
- scriptmodules/libretrocores/lr-parallel-n64/0001-fix-fsqrt-rename.patch
- scriptmodules/libretrocores/lr-mupen64plus/CHANGELOG.md
- scriptmodules/libretrocores/lr-mupen64plus/PR_ARTIFACTS.md
- scriptmodules/libretrocores/lr-mupen64plus/PR_DESCRIPTION.md

Verification
------------
- Local x86_64 builds completed:
  - `tmp/build/lr-mupen64plus/mupen64plus_libretro.so` (built during verification)
  - `tmp/build/lr-parallel-n64/parallel_n64_libretro.so` (produced and checksumed)
- The original link failure was caused by a duplicate `fsqrt` symbol in another
  mupen variant; the companion `lr-parallel-n64` patch resolves that.

Testing / Recommendation
-----------------------
- Run package builds on target architectures (armhf/arm64) via the usual CI or
  `sudo ./retropie_setup.sh` on target hardware to validate cross-arch compilation.
- After installing the built cores, perform a quick RetroArch smoke test to confirm
  emulation and audio/resampler behavior are unchanged.

Notes for reviewers
-------------------
- Changes are intentionally small and mechanical; they only address type/signature
  mismatches and a symbol rename to avoid link collisions. No runtime emulation
  logic was altered.

If you want me to post this exact text as the PR comment, say so and I'll post it to PR #4140.
