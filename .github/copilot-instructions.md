# libpldm: notes for GitHub Copilot

libpldm is the OpenBMC library that encodes and decodes PLDM messages: the
messages a BMC exchanges with other devices in a server. The library is C17.
The unit tests are C++ and use GoogleTest.

## Build and test

- The build directory is `build/`. If it doesn't exist yet, run `meson setup build`.
- Rebuild: `meson compile -C build`
- Run one test suite, for example the platform tests: `meson test -C build dsp/platform`
- Run every test: `meson test -C build`
- Tests for `src/dsp/<name>.c` live in `tests/unit/dsp/<name>.cpp`. Follow the
  style of the existing tests in that file.

## Rules

- PLDM messages come from other devices, so treat every field in a message as
  untrusted input.
- Check every length or count field against the real size of the destination
  buffer before copying data.
- Keep the existing code style: tabs for indentation, as in the surrounding code.
