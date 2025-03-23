# Contributing to ot-google-project-module

Thank you for your interest in contributing to our OpenTofu Google Project module! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Branching Strategy](#branching-strategy)
- [Commit Messages](#commit-messages)
- [Pull Request Process](#pull-request-process)
- [Module Structure](#module-structure)
- [Coding Conventions](#coding-conventions)
- [Testing](#testing)
- [Documentation](#documentation)
- [Release Process](#release-process)

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md). We expect all contributors to adhere to this to maintain a respectful and inclusive environment.

## Getting Started

1. **Fork the repository** on GitHub.
2. **Clone your fork** locally:
   ```
   git clone https://github.com/YOUR-USERNAME/ot-google-project-module.git
   cd ot-google-project-module
   ```
3. **Add the upstream remote**:
   ```
   git remote add upstream https://github.com/dadandlad-co/ot-google-project-module.git
   ```
4. **Create a new branch** for your work:
   ```
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

1. Make sure you have the latest changes from the upstream repository:
   ```
   git fetch upstream
   git rebase upstream/main
   ```
2. Install development dependencies:
   ```
   # If using pre-commit hooks
   pre-commit install
   ```
3. Make your changes, following our [coding conventions](#coding-conventions).
4. Test your changes locally.
5. Commit your changes with a [clear message](#commit-messages).
6. Push your changes to your fork.
7. Create a pull request to the main repository.

## Branching Strategy

- `main` - The primary branch containing the latest production-ready code
- `feature/` - For new features and enhancements
- `fix/` - For bug fixes
- `docs/` - For documentation changes
- `chore/` - For maintenance tasks

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages:

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

Types include:
- `feat:` - A new feature
- `fix:` - A bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, indentation)
- `refactor:` - Code changes that neither fix a bug nor add a feature
- `perf:` - Performance improvements
- `test:` - Adding or modifying tests
- `chore:` - Changes to the build process or auxiliary tools

Examples:
```
feat(project): add support for additional project labels
fix(apis): correct API enabling process
docs(readme): update usage example
```

## Pull Request Process

1. Ensure all tests pass and your code meets our coding standards.
2. Update documentation if necessary, including README.md and example files.
3. Fill out the pull request template completely.
4. Request review from maintainers.
5. Address any review feedback.
6. Once approved, a maintainer will merge your pull request.

## Module Structure

Our module follows a standard OpenTofu module structure:

```
.
├── main.tf           # Main module resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Version constraints
├── README.md         # Module documentation
├── examples/         # Example implementations
│   ├── simple/
│   ├── complete/
│   └── ...
└── tests/            # Test files
```

## Coding Conventions

We follow the [OpenTofu Style Guide](https://opentofu.org/docs/v1.8/language/syntax/style/).

Key points:
- Use 2 spaces for indentation
- Use snake_case for naming variables, resources, and outputs
- Variables should be in alphabetical order
- All variables should have descriptions and validation where appropriate
- All resources should be named consistently
- Use `this` as the name for the first resource of a certain type

## Testing

Before submitting a pull request, ensure:

1. All resources are properly configured
2. All examples run successfully
3. Documentation is updated
4. Code passes the automation checks

Our CI pipeline runs checks on:
- OpenTofu validation
- Format checking
- Security scanning with tfsec and checkov

## Documentation

Update documentation for any changes:

1. Update the main README.md with new features or changes
2. Update examples to demonstrate new functionality
3. Ensure variable descriptions are clear and helpful
4. Use terraform-docs to generate consistent documentation

To generate documentation:
```
terraform-docs markdown . > README.md
```

## Release Process

We follow semantic versioning (SEMVER) for our releases:

1. **Major version (X.0.0)**: Incompatible API changes
2. **Minor version (0.X.0)**: Add functionality in a backward-compatible manner
3. **Patch version (0.0.X)**: Backward-compatible bug fixes

The release process is:
1. Update CHANGELOG.md with changes
2. Tag the release with the version number: `git tag v1.0.0`
3. Push the tag: `git push origin v1.0.0`
4. The CI/CD pipeline will create the GitHub release

## License

By contributing to this project, you agree that your contributions will be licensed under the same license as the project (Apache 2.0).

Thank you for your contributions!
