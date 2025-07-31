# Resume Builder

A modern terminal interface for building multiple resume variants using [Typst](https://typst.app/). Clean, fast, and keyboard-driven.

**Why Typst?** A cleaner, more intuitive alternative to LaTeX with modern syntax and faster compilation.
**Includes Jake's Resume Template** - Professional, ATS-friendly design built right into the project.

![Go](https://img.shields.io/badge/go-%2300ADD8.svg?style=flat&logo=go&logoColor=white)
![License](https://img.shields.io/github/license/adhitht/resume-builder?style=flat)

[**View Sample Resume**](https://github.com/adhitht/resume-builder/blob/main/output/Google.pdf)

## Features

**Modern Interface**
Clean terminal UI with adaptive colors that work in any theme

**Multiple Variants**
Manage different resume versions for different roles or companies

**One-Click Building**
Generate PDFs instantly with automatic clipboard integration

**Smart Workflow**
Built-in PDF preview and file management

## Installation

### Prerequisites
- Go 1.19 or later
- Typst compiler

### Quick Start
```bash
# Clone repository
git clone https://github.com/yourusername/resume-builder.git
cd resume-builder

# Install dependencies
go mod tidy

# Build application
go build -o resume-builder

# Run
./resume-builder
```

### Install Typst
```bash
# macOS/Linux
curl -fsSL https://typst.app/install.sh | sh

# Or visit: https://typst.app/docs/guides/install/
```

## Usage

### Directory Structure
```
resume-builder/
├── variants/          # Your .typ resume files
│   ├── software.typ
│   ├── manager.typ
│   └── consulting.typ
└── output/           # Generated PDFs
    ├── Software.pdf
    ├── Manager.pdf
    └── Consulting.pdf
```

### Basic Workflow
1. Add `.typ` files to the `variants/` directory
2. Run `./resume-builder`
3. Select a variant and press Enter
4. PDF is built and path copied to clipboard
5. Press `o` to open PDF or `c` to copy path again

### Keyboard Controls
| Key | Action |
|-----|--------|
| `↑↓` `jk` | Navigate |
| `Enter` `Space` | Build resume |
| `o` | Open PDF |
| `c` | Copy path |
| `esc` | Back |
| `q` | Quit |

## Creating Resume Variants

Each `.typ` file in `variants/` becomes a selectable option. Check out sample variants in the folder.

## Configuration

The application compiles using:
```bash
typst compile input.typ output.pdf --root ..
```

Default directories:
- **Input**: `variants/`
- **Output**: `output/`

## Development

### Building from Source
```bash
git clone https://github.com/yourusername/resume-builder.git
cd resume-builder
go mod tidy
go build
```

## Troubleshooting

**typst command not found**
```bash
# Install Typst first
curl -fsSL https://typst.app/install.sh | sh
```

**No variants found**
```bash
# Ensure .typ files exist in variants/
ls variants/*.typ
```

**Build errors**
- Check `.typ` file syntax
- Verify referenced assets exist
- Ensure proper Typst formatting

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Built with Go and Typst**
