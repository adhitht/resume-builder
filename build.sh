#!/bin/bash
# build.sh - Build automation script

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
COMPANY_VARIANTS=("google" "amazon" "microsoft" "startup" "internship" "full" "minimal")
TEMPLATES_DIR="templates"
COMPANIES_DIR="$TEMPLATES_DIR/companies"
OUTPUT_DIR="output"
WATCH_MODE=false
CLEAN_BUILD=false
PARALLEL_BUILD=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --watch|-w)
      WATCH_MODE=true
      shift
      ;;
    --clean|-c)
      CLEAN_BUILD=true
      shift
      ;;
    --parallel|-p)
      PARALLEL_BUILD=true
      shift
      ;;
    --variant|-v)
      SINGLE_VARIANT="$2"
      shift 2
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --watch, -w         Watch for changes and rebuild"
      echo "  --clean, -c         Clean build directory first"
      echo "  --parallel, -p      Build variants in parallel"
      echo "  --variant, -v NAME  Build only specific variant"
      echo "  --help, -h          Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_build() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

# Function to check if typst is installed
check_dependencies() {
    if ! command -v typst &> /dev/null; then
        print_error "Typst is not installed. Please install it first:"
        echo "  curl -fsSL https://typst.community/typst-install/install.sh | sh"
        exit 1
    fi
    print_status "Typst found: $(typst --version)"
}

# Function to create output directory
setup_output_dir() {
    if [[ "$CLEAN_BUILD" == true && -d "$OUTPUT_DIR" ]]; then
        print_status "Cleaning output directory..."
        rm -rf "$OUTPUT_DIR"
    fi

    mkdir -p "$OUTPUT_DIR"
    print_status "Output directory ready: $OUTPUT_DIR"
}

# Function to build a single variant
build_variant() {
    local variant=$1
    local start_time=$(date +%s)

    print_build "Building $variant resume..."

    # Check if variant file exists
    if [[ ! -f "$COMPANIES_DIR/${variant}.typ" ]]; then
        print_error "Variant file not found: $COMPANIES_DIR/${variant}.typ"
        return 1
    fi

    if typst compile "$COMPANIES_DIR/${variant}.typ" "$OUTPUT_DIR/resume_${variant}.pdf" 2>/dev/null; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_status "✓ Built $variant resume (${duration}s)"
        return 0
    else
        print_error "✗ Failed to build $variant resume"
        # Show the actual error
        typst compile "$COMPANIES_DIR/${variant}.typ" "$OUTPUT_DIR/resume_${variant}.pdf"
        return 1
    fi
}

# Function to build all variants
build_all_variants() {
    local variants_to_build=("${COMPANY_VARIANTS[@]}")
    local failed_builds=()
    local successful_builds=()

    # If single variant specified, only build that one
    if [[ -n "$SINGLE_VARIANT" ]]; then
        variants_to_build=("$SINGLE_VARIANT")
    fi

    print_status "Building $(printf '%s ' "${variants_to_build[@]}")variants..."

    if [[ "$PARALLEL_BUILD" == true ]]; then
        print_status "Building in parallel mode..."
        local pids=()
        local pid_to_variant=()

        for variant in "${variants_to_build[@]}"; do
            build_variant "$variant" &
            pid=$!
            pids+=($pid)
            pid_to_variant[$pid]="$variant"
        done

        # Wait for all background jobs
        for pid in "${pids[@]}"; do
            variant="${pid_to_variant[$pid]}"
            if wait $pid; then
                successful_builds+=("$variant")
            else
                failed_builds+=("$variant")
            fi
        done
    else
        # Sequential build
        for variant in "${variants_to_build[@]}"; do
            if build_variant "$variant"; then
                successful_builds+=("$variant")
            else
                failed_builds+=("$variant")
            fi
        done
    fi

    # Print summary
    echo
    print_status "Build Summary:"
    echo
    if [[ ${#successful_builds[@]} -gt 0 ]]; then
        print_status "Successful builds: ${successful_builds[*]}"
    fi
    if [[ ${#failed_builds[@]} -gt 0 ]]; then
        print_error "Failed builds: ${failed_builds[*]}"
    fi
}
