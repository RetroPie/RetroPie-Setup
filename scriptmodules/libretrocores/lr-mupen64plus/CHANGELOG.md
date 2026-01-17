Changelog
=========

2026-01-16 — Fixes for lr-mupen64plus build

- Update resampler driver init signatures to accept `enum resampler_quality` in `sinc` and `nearest`, and mark `quality` used in `null` resampler. (Patch: 0003)
- Use `z_crc_t` for CRC table pointer types to match zlib typedefs and avoid incompatible-pointer warnings. (Patch: 0004)
- Rename dynarec helper `fsqrt` -> `fsqrt_emu` and update callers to avoid collision with system math symbols. (Patch: 0005)

Verification:
- Local x86_64 build completed and produced `mupen64plus_libretro.so` in `tmp/build/lr-mupen64plus`.
- Local rebuild of `lr-parallel-n64` (same repository tree) also completed and produced `parallel_n64_libretro.so` in `tmp/build/lr-parallel-n64` (verified 2026-01-17).

Recommendation: build and test on target hardware (e.g., Raspberry Pi) to validate cross-arch behavior.
