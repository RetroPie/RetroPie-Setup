PR: lr-mupen64plus — Fix resampler init, zlib CRC types, and dynarec helper collision
==========================================================================

Summary
-------
- This branch provides three focused patches to make `lr-mupen64plus` build cleanly on modern toolchains:
  1. `0003-fix-resampler-init.patch` — update libretro-common resampler driver init signatures to accept `enum resampler_quality` (sinc, nearest) and mark `quality` used in `null` resampler.
  2. `0004-fix-zlib-crc.patch` — use `z_crc_t` for CRC table pointer types in zip/unzip/crypt sources to resolve incompatible-pointer warnings with newer zlib headers.
  3. `0005-fix-fsqrt-rename.patch` — rename dynarec helper `fsqrt` to `fsqrt_emu` and update callers to avoid symbol collision with system math functions and other cores (also provides a companion patch for `lr-parallel-n64`).

Rationale and scope
-------------------
- These are targeted, mechanical fixes that resolve compile/link errors observed on recent toolchains (type mismatches and duplicate global symbol). They do not change runtime behavior other than avoiding name collisions and respecting upstream API signatures.
- Patches are kept small and isolated so maintainers can review and apply each independently.

Files changed
-------------
- `scriptmodules/libretrocores/lr-mupen64plus/0003-fix-resampler-init.patch`
- `scriptmodules/libretrocores/lr-mupen64plus/0004-fix-zlib-crc.patch`
- `scriptmodules/libretrocores/lr-mupen64plus/0005-fix-fsqrt-rename.patch`
- `scriptmodules/libretrocores/lr-parallel-n64/0001-fix-fsqrt-rename.patch` (companion)
- `scriptmodules/libretrocores/lr-mupen64plus/CHANGELOG.md` (verification notes)

Verification performed
----------------------
- Local x86_64 build of `lr-mupen64plus` completed and produced `tmp/build/lr-mupen64plus/mupen64plus_libretro.so`.
- Local x86_64 rebuild of `lr-parallel-n64` (same tree) completed and produced `tmp/build/lr-parallel-n64/parallel_n64_libretro.so`.
- The fixes are mechanical (signature/type/rename); functional behavior was not modified beyond symbol and API compatibility.

Testing notes (recommended)
---------------------------
- CI: run existing build matrix for supported arches if available.
- Local: run `sudo ./retropie_setup.sh` and build the `lr-mupen64plus` package on each target architecture (x86_64, armhf, arm64) to verify cross-arch compilation.
- Run quick sanity tests in RetroArch on target hardware to ensure game execution and audio/resampler behavior are unchanged.

Patch rationale details
----------------------
- Resampler: libretro-common resampler API expects an `enum resampler_quality` parameter in the init function; adding this avoids mismatched-signature warnings and preserves API compatibility.
- zlib: `z_crc_t` is the zlib typedef for CRC table entries; using the typedef prevents incompatible-pointer warnings across zlib versions.
- `fsqrt` rename: `fsqrt` collides with system or other core symbols on some toolchains/ld configurations; renaming to `fsqrt_emu` avoids duplicate-definition link errors while keeping implementation local to the core.

Rollback / alternative
-----------------------
- If maintainers prefer a different symbol name or a static symbol scoping approach, the rename in `0005` can be adapted; the resampler and zlib changes are minimal and low-risk.

Credits
-------
- Patch author: Greg (branch and PR created by workspace). Verification performed locally on x86_64.

Sign-off
--------
I confirm these changes are intended to fix build issues only and do not alter runtime emulation logic. Please let me know if you want the patches split further or applied differently for backporting.
