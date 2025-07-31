package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/atotto/clipboard"
	"github.com/charmbracelet/bubbles/key"
	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Keymap defines keyboard shortcuts
type keyMap struct {
	Up    key.Binding
	Down  key.Binding
	Enter key.Binding
	Back  key.Binding
	Quit  key.Binding
	Help  key.Binding
	Open  key.Binding
	Copy  key.Binding
}

func (k keyMap) ShortHelp() []key.Binding {
	return []key.Binding{k.Help, k.Quit}
}

func (k keyMap) FullHelp() [][]key.Binding {
	return [][]key.Binding{
		{k.Up, k.Down, k.Enter},
		{k.Open, k.Copy, k.Back, k.Quit},
	}
}

var keys = keyMap{
	Up: key.NewBinding(
		key.WithKeys("up", "k"),
		key.WithHelp("↑/k", "move up"),
	),
	Down: key.NewBinding(
		key.WithKeys("down", "j"),
		key.WithHelp("↓/j", "move down"),
	),
	Enter: key.NewBinding(
		key.WithKeys("enter", " "),
		key.WithHelp("enter", "build resume"),
	),
	Back: key.NewBinding(
		key.WithKeys("esc", "b"),
		key.WithHelp("esc", "back to list"),
	),
	Quit: key.NewBinding(
		key.WithKeys("ctrl+c", "q"),
		key.WithHelp("q", "quit"),
	),
	Help: key.NewBinding(
		key.WithKeys("?"),
		key.WithHelp("?", "toggle help"),
	),
	Open: key.NewBinding(
		key.WithKeys("o"),
		key.WithHelp("o", "open PDF"),
	),
	Copy: key.NewBinding(
		key.WithKeys("c"),
		key.WithHelp("c", "copy path"),
	),
}

type variantItem struct {
	name        string
	description string
	size        string
}

func (v variantItem) Title() string       { return v.name }
func (v variantItem) Description() string { return v.description }
func (v variantItem) FilterValue() string { return v.name }

var (
	outputDir   = "output"
	variantsDir = "variants"

	// Color palette - modern, accessible colors
	primaryColor    = lipgloss.AdaptiveColor{Light: "#3B82F6", Dark: "#60A5FA"}
	successColor    = lipgloss.AdaptiveColor{Light: "#059669", Dark: "#10B981"}
	errorColor      = lipgloss.AdaptiveColor{Light: "#DC2626", Dark: "#EF4444"}
	mutedColor      = lipgloss.AdaptiveColor{Light: "#6B7280", Dark: "#9CA3AF"}
	backgroundColor = lipgloss.AdaptiveColor{Light: "#F9FAFB", Dark: "#111827"}

	// Styles
	baseStyle = lipgloss.NewStyle().
			Padding(1, 2)

	headerStyle = lipgloss.NewStyle().
			Foreground(primaryColor).
			Bold(true).
			MarginBottom(1).
			Padding(0, 1)

	titleStyle = lipgloss.NewStyle().
			Foreground(primaryColor).
			Bold(true)

	successStyle = lipgloss.NewStyle().
			Foreground(successColor).
			Bold(true)

	errorStyle = lipgloss.NewStyle().
			Foreground(errorColor).
			Bold(true)

	mutedStyle = lipgloss.NewStyle().
			Foreground(mutedColor)

	helpStyle = lipgloss.NewStyle().
			Foreground(mutedColor).
			MarginTop(1)

	logBoxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(mutedColor).
			Padding(1, 2).
			MarginTop(1).
			MarginBottom(1)

	actionBoxStyle = lipgloss.NewStyle().
			Border(lipgloss.RoundedBorder()).
			BorderForeground(primaryColor).
			Padding(1, 2).
			MarginTop(1)
)

type state int

const (
	stateList state = iota
	stateBuilding
	stateComplete
)

type model struct {
	state     state
	list      list.Model
	selected  string
	building  bool
	log       string
	quitting  bool
	spinner   spinner.Model
	keys      keyMap
	builtPath string
	width     int
	height    int
}

func getVariantItems() ([]list.Item, error) {
	items := []list.Item{}

	err := filepath.Walk(variantsDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(info.Name(), ".typ") {
			name := strings.TrimSuffix(info.Name(), ".typ")

			// Get file size for display
			size := "Unknown size"
			if stat, err := os.Stat(path); err == nil {
				size = fmt.Sprintf("%.1f KB", float64(stat.Size())/1024)
			}

			item := variantItem{
				name:        name,
				description: fmt.Sprintf("Typst resume variant • %s", size),
				size:        size,
			}
			items = append(items, item)
		}
		return nil
	})

	return items, err
}

func initialModel() model {
	items, err := getVariantItems()
	if err != nil {
		fmt.Printf("Error loading variant files: %v\n", err)
		os.Exit(1)
	}

	if len(items) == 0 {
		fmt.Printf("No .typ files found in %s directory\n", variantsDir)
		os.Exit(1)
	}

	// Create list with custom delegate for better styling
	delegate := list.NewDefaultDelegate()
	delegate.Styles.SelectedTitle = delegate.Styles.SelectedTitle.
		Foreground(primaryColor).
		BorderLeft(true).
		BorderStyle(lipgloss.ThickBorder()).
		BorderForeground(primaryColor).
		Padding(0, 0, 0, 1)

	delegate.Styles.SelectedDesc = delegate.Styles.SelectedDesc.
		Foreground(mutedColor).
		Padding(0, 0, 0, 2)

	l := list.New(items, delegate, 0, 0)
	l.Title = ""
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(true)
	l.Styles.Title = titleStyle
	l.Styles.HelpStyle = helpStyle

	// Custom spinner
	sp := spinner.New()
	sp.Spinner = spinner.Points
	sp.Style = lipgloss.NewStyle().Foreground(primaryColor)

	return model{
		state:   stateList,
		list:    l,
		spinner: sp,
		keys:    keys,
	}
}

func (m model) Init() tea.Cmd {
	return m.spinner.Tick
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch {
		case key.Matches(msg, m.keys.Quit):
			m.quitting = true
			return m, tea.Quit

		case key.Matches(msg, m.keys.Back):
			if m.state == stateComplete {
				m.state = stateList
				m.log = ""
				m.builtPath = ""
				return m, nil
			}

		case key.Matches(msg, m.keys.Enter):
			if m.state == stateList && m.list.SelectedItem() != nil {
				m.selected = m.list.SelectedItem().FilterValue()
				m.state = stateBuilding
				m.building = true
				return m, tea.Batch(m.spinner.Tick, buildSelected(m.selected))
			}

		case key.Matches(msg, m.keys.Open):
			if m.state == stateComplete && m.builtPath != "" {
				return m, openPDF(m.builtPath)
			}

		case key.Matches(msg, m.keys.Copy):
			if m.state == stateComplete && m.builtPath != "" {
				return m, copyToClipboard(m.builtPath)
			}
		}

	case buildFinishedMsg:
		m.building = false
		m.state = stateComplete
		m.log = msg.log
		m.builtPath = msg.path
		// Auto-copy to clipboard on successful build
		if msg.success {
			return m, copyToClipboard(msg.path)
		}
		return m, nil

	case clipboardMsg:
		// Handle clipboard feedback silently
		return m, nil

	case tea.WindowSizeMsg:
		m.width = msg.Width
		m.height = msg.Height
		m.list.SetSize(msg.Width-4, msg.Height-8)

	case spinner.TickMsg:
		if m.building {
			var cmd tea.Cmd
			m.spinner, cmd = m.spinner.Update(msg)
			return m, cmd
		}
	}

	var cmd tea.Cmd
	m.list, cmd = m.list.Update(msg)
	return m, cmd
}

func (m model) View() string {
	if m.quitting {
		return baseStyle.Render(
			titleStyle.Render("👋 Goodbye!") + "\n" +
				mutedStyle.Render("Thanks for using Resume Builder!"),
		)
	}

	var content strings.Builder

	// Header
	content.WriteString(headerStyle.Render("📝 Resume Builder"))
	content.WriteString("\n")

	switch m.state {
	case stateList:
		content.WriteString(m.list.View())
		content.WriteString("\n")
		content.WriteString(helpStyle.Render("Press ? for help • ↑↓ to navigate • Enter to build • q to quit"))

	case stateBuilding:
		content.WriteString(fmt.Sprintf("%s Building %s...\n",
			m.spinner.View(),
			successStyle.Render(m.selected)))

		if m.log != "" {
			content.WriteString(logBoxStyle.Render(m.log))
		}

		content.WriteString(helpStyle.Render("Please wait while your resume is being built..."))

	case stateComplete:
		if strings.Contains(m.log, "✅") {
			content.WriteString(successStyle.Render("🎉 Build Complete!"))
			content.WriteString("\n\n")
			content.WriteString(fmt.Sprintf("📄 %s\n", successStyle.Render(filepath.Base(m.builtPath))))
			content.WriteString(mutedStyle.Render("📋 Path copied to clipboard"))
			content.WriteString("\n")

			// Action buttons
			keyStyle := lipgloss.NewStyle().Foreground(primaryColor)
			actions := keyStyle.Render("[o]") + " Open • " +
				keyStyle.Render("[c]") + " Copy • " +
				keyStyle.Render("[esc]") + " Back • " +
				keyStyle.Render("[q]") + " Quit"
			content.WriteString(actionBoxStyle.Render(actions))

		} else {
			content.WriteString(errorStyle.Render("❌ Build Failed"))
			content.WriteString("\n")
			content.WriteString(logBoxStyle.Render(m.log))
			content.WriteString(helpStyle.Render("Press esc to go back"))
		}
	}

	return baseStyle.Render(content.String())
}

type buildFinishedMsg struct {
	log     string
	success bool
	path    string
}

type clipboardMsg struct{}

func buildSelected(variant string) tea.Cmd {
	return func() tea.Msg {
		// Capitalize first letter for PDF name
		capitalizedName := strings.ToUpper(string(variant[0])) + variant[1:]
		outputPath := fmt.Sprintf("%s/%s.pdf", outputDir, capitalizedName)
		inputPath := fmt.Sprintf("%s/%s.typ", variantsDir, variant)

		cmd := exec.Command("typst", "compile", inputPath, outputPath, "--root", "..")
		out, err := cmd.CombinedOutput()

		if err != nil {
			log := fmt.Sprintf("❌ Build failed: %s", err.Error())
			if len(out) > 0 {
				log += "\n" + string(out)
			}
			return buildFinishedMsg{
				log:     log,
				success: false,
				path:    "",
			}
		}

		return buildFinishedMsg{
			log:     "✅ Build successful",
			success: true,
			path:    outputPath,
		}
	}
}

func copyToClipboard(path string) tea.Cmd {
	return func() tea.Msg {
		absPath, err := filepath.Abs(path)
		if err != nil {
			absPath = path
		}
		clipboard.WriteAll(absPath)
		return clipboardMsg{}
	}
}

func openPDF(path string) tea.Cmd {
	return func() tea.Msg {
		var cmd *exec.Cmd

		switch runtime.GOOS {
		case "darwin":
			cmd = exec.Command("open", path)
		case "linux":
			cmd = exec.Command("xdg-open", path)
		case "windows":
			cmd = exec.Command("rundll32", "url.dll,FileProtocolHandler", path)
		default:
			return clipboardMsg{} // Unsupported OS
		}

		go cmd.Run() // Run in background
		return clipboardMsg{}
	}
}

func main() {
	// Ensure output directory exists
	if err := os.MkdirAll(outputDir, 0755); err != nil {
		fmt.Printf("Error creating output directory: %v\n", err)
		os.Exit(1)
	}

	// Check if typst is available
	if _, err := exec.LookPath("typst"); err != nil {
		fmt.Println("Error: typst command not found. Please install Typst first.")
		fmt.Println("Visit: https://typst.app/docs/guides/install/")
		os.Exit(1)
	}

	// Check if variants directory exists
	if _, err := os.Stat(variantsDir); os.IsNotExist(err) {
		fmt.Printf("Error: %s directory not found. Please create it and add your .typ files.\n", variantsDir)
		os.Exit(1)
	}

	p := tea.NewProgram(
		initialModel(),
		tea.WithAltScreen(),
		tea.WithMouseCellMotion(),
	)

	if _, err := p.Run(); err != nil {
		fmt.Printf("Error running program: %v\n", err)
		os.Exit(1)
	}
}
