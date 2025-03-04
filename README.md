# Project Rules

## Overview

The **Project Rules** is a powerful tool designed to streamline the generation of `.mdc` files based on specified keywords. Built with Swift, this project allows developers to easily create and manage project rules, enhancing productivity and ensuring consistency across projects.

## Features

- **Keyword-Based Generation**: Generate `.mdc` files by simply providing a comma-separated list of keywords
- **Flexible Repository Selection**: Fetch `.mdc` files from any GitHub repository that follows the expected structure
- **Multiple Output Options**: Write to files or preview content with dry-run mode
- **GitHub Token Support**: Automatically uses `GITHUB_TOKEN` environment variable if available
- **Error Handling**: Comprehensive error reporting for invalid keywords, network issues, and content problems

## Usage

```bash
$ projectrules -h

OVERVIEW: Generate .mdc files based on provided keywords.

USAGE: ProjectRules <keywords> [--repo <repo>] [--target-directory <target-directory>] [--dry-run]

ARGUMENTS:
  <keywords>              Comma-separated keywords (e.g., best-practices-for-writitng-nextjs)

OPTIONS:
  -r, --repo <repo>       Specify a GitHub repository in owner/reponame format. If provided, the {keyword}.mdc file from
                          that repository will be used.
  -t, --target-directory <target-directory>
                          Specify the output directory. Defaults to the current directory.
  --dry-run               If set, display the output content to standard output instead of writing to a file.
  -h, --help              Show help information.
```

Set `GITHUB_TOKEN` environment variable with your GitHub personal access token if you need to access private repositories.

### Examples

```bash
# Generate a single .mdc file in current directory
$ projectrules best-practices-for-writitng-nextjs

# Generate multiple .mdc files in specified directory
$ projectrules best-practices-for-writitng-nextjs -t .cursor/rules

# Preview content without writing to file
$ projectrules guidelines-for-writing-postgres-sql-by-supabase --dry-run

# Use custom repository
$ projectrules swift-best-practices --repo myorg/mdc-rules
```

Don't you want to know which keywords you can use? Just visit [project-rules.io](https://www.project-rules.io) to search through all available keywords. If you have an amazing `.mdc` file, please submit a pull request to [mdcvalult](https://github.com/fumito-ito/mdcvalult). Any rule merged into the main branch will then be accessible via the CLI.

## Installation

```bash
brew tap fumito-ito/projectrules
brew install projectrules
```

## Development

### Prerequisites

- Swift 6.0 or later
- Docker (for web service development)

### Project Structure

```
.
├── Sources/
│   ├── ProjectRulesGenerator/  # Core functionality
│   ├── ProjectRulesCLI/        # Command-line interface
│   └── ProjectRulesIO/         # Web service
├── Public/                     # Web service assets
└── scripts/                    # Build and deployment scripts
```

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/fumito-ito/ProjectRules.git
   cd ProjectRules
   ```

2. Install dependencies:
   ```bash
   swift package resolve
   ```

3. Build the project:
   ```bash
   swift build
   ```

### Running the Application

For CLI development:
```bash
swift run projectrules
```

For web service development:
```bash
make local-run  # Fetches MDC data & runs application in Docker
```

### Environment Variables

- Additional variables for web service deployment (see `.env.example`)

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
