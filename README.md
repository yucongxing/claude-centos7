# claude-centos7

Patched [Claude Code](https://claude.ai/code) builds that run on CentOS 7 (glibc 2.17, kernel 3.10+).

New releases are published automatically within 6 hours of each upstream Claude Code release.

## Install

**No root needed. Works from any directory.**

Download the latest release tarball from the [Releases page](../../releases/latest), then:

```bash
tar xzf claude-centos7-v*.tar.gz
./claude-centos7/claude --version
```

### Optional: install to `~/.local/bin`

```bash
cd claude-centos7
bash install.sh
```

Then add to PATH if needed:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
claude --version
```

### Uninstall

If installed via `install.sh`:

```bash
rm -rf ~/.local/share/claude-centos7
rm -f ~/.local/bin/claude
```

Or re-extract the tarball and run:

```bash
bash claude-centos7/uninstall.sh
```

## Verify it works

```bash
./claude-centos7/claude --version
# Expected output: Claude Code X.X.XXX

echo $?
# Expected: 0
```

## How it works

CentOS 7 ships glibc 2.17. Claude Code's standard Linux binary requires GLIBC_2.18, GLIBC_2.24, and GLIBC_2.25 — symbols that don't exist on CentOS 7.

Anthropic publishes an official **musl-linked** build (`@anthropic-ai/claude-code-linux-x64-musl`) that has no glibc version requirements. However, it expects musl libc at `/lib/ld-musl-x86_64.so.1`, which CentOS 7 doesn't have.

This project:
1. Downloads the official musl build from Anthropic's npm registry
2. Bundles musl libc (~400KB) alongside it
3. Wraps it in a 5-line shell script that invokes the musl dynamic linker directly

The wrapper (`claude`) looks like this:

```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec env LD_LIBRARY_PATH="$SCRIPT_DIR/libs${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
     "$SCRIPT_DIR/libs/ld-musl-x86_64.so.1" \
     "$SCRIPT_DIR/claude-bin" "$@"
```

No patchelf. No root. No system modifications.

## Release contents

Each release tarball contains:

```
claude-centos7/
├── claude          # wrapper script (run this)
├── claude-bin      # official Anthropic musl binary, unmodified
├── libs/
│   ├── ld-musl-x86_64.so.1    # musl libc/dynamic linker (~400KB)
│   └── libc.musl-x86_64.so.1  # symlink → ld-musl-x86_64.so.1
├── install.sh
└── uninstall.sh
```

## Automation

A GitHub Actions workflow checks the npm registry every 6 hours. When a new Claude Code version is detected, it:
1. Downloads `@anthropic-ai/claude-code-linux-x64-musl` from npm
2. Bundles musl libc from Ubuntu's apt
3. Generates the wrapper script
4. Publishes a GitHub Release with the tarball

The workflow is idempotent — re-runs never create duplicate releases.

## Requirements

- CentOS 7 x86_64 (or any Linux with glibc ≥ 2.17 and kernel ≥ 3.10)
- `bash`, `curl`, `tar` (pre-installed on CentOS 7)

## License

MIT. Claude Code itself is licensed by Anthropic — see their [terms of service](https://www.anthropic.com/legal/consumer-terms).
