# Contributing to Hermes

Thank you for your interest in contributing to Hermes! This document provides guidelines and instructions for contributing to this project.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)

---

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

### Our Standards
- ✅ Be polite and professional
- ✅ Be inclusive and welcoming
- ✅ Respect differing opinions and experiences
- ✅ Focus on what is best for the community
- ❌ Harassment and discrimination
- ❌ Personal attacks
- ❌ Spam and promotional content

---

## Getting Started

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Android SDK 26+
- Git
- A code editor (VS Code, Android Studio, etc.)

### Fork the Repository
1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/hermes-pro-transfer.git
   cd hermes-pro-transfer
   ```

### Set Up Remote
```bash
git remote add upstream https://github.com/mohmaedeslam00116/hermes-pro-transfer.git
```

---

## Development Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Run Tests
```bash
flutter test
```

### 4. Run Code Analysis
```bash
flutter analyze
```

### 5. Build APK
```bash
flutter build apk --release
```

---

## Making Changes

### 1. Create a Branch
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### Branch Naming Conventions
- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `test/` - Test additions
- `chore/` - Maintenance tasks

### 2. Make Your Changes
- Write clean, maintainable code
- Follow the coding standards below
- Add tests for new functionality
- Update documentation as needed

### 3. Commit Your Changes
```bash
git add .
git commit -m "Add: brief description of changes"
```

### Commit Message Format
```
<type>: <subject>

<body>

<footer>
```

#### Types
- `Add` - New feature
- `Fix` - Bug fix
- `Update` - Update existing feature
- `Refactor` - Code refactoring
- `Docs` - Documentation changes
- `Test` - Test additions/changes
- `Chore` - Maintenance
- `CI` - CI/CD changes

### 4. Push Your Changes
```bash
git push origin feature/your-feature-name
```

---

## Pull Request Process

### 1. Update Your Fork
```bash
git fetch upstream
git merge upstream/main
# Resolve any conflicts
```

### 2. Create Pull Request
1. Go to the original repository on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template

### Pull Request Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How Has This Been Tested?
Describe testing done

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have commented my code where necessary
- [ ] I have updated the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix/feature works
```

### 3. Review Process
- Maintainers will review your PR
- Address any feedback or requested changes
- Once approved, your PR will be merged

---

## Coding Standards

### Flutter/Dart Style Guide

#### Formatting
- 2 spaces for indentation
- 80 character line limit
- Use `dart format` before committing

```bash
dart format .
```

#### Naming Conventions
- **Classes**: PascalCase (`MyClass`)
- **Variables**: camelCase (`myVariable`)
- **Constants**: camelCase (`myConstant`)
- **Files**: snake_case (`my_file.dart`)
- **Folders**: snake_case (`my_folder`)

#### Widgets
- Use `const` constructors when possible
- Extract reusable widgets
- Keep widgets focused and small

#### State Management
- Use Provider for state management
- Follow reactive programming patterns
- Keep business logic in services

### Code Quality
- No `TODO` comments left behind
- No commented-out code
- Meaningful variable names
- Proper error handling

---

## Reporting Bugs

### Before Submitting
1. Check existing issues
2. Verify bug in latest version
3. Test with clean install

### Bug Report Template
```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Screenshots
If applicable

## Environment
- Device:
- OS:
- App Version:

## Additional Context
Any other information
```

---

## Suggesting Features

### Feature Request Template
```markdown
## Feature Description
Clear description of the feature

## Problem Solved
What problem does this solve?

## Use Cases
List of use cases

## Alternatives Considered
Other solutions considered

## Additional Context
Any mockups, diagrams, etc.
```

---

## 🏆 Recognition

Contributors will be recognized in:
- The project's README
- Release notes
- GitHub's contributor graph

---

## 📞 Contact

- **GitHub Issues**: [Open an Issue](https://github.com/mohmaedeslam00116/hermes-pro-transfer/issues)
- **Discussions**: [GitHub Discussions](https://github.com/mohmaedeslam00116/hermes-pro-transfer/discussions)

---

## 📜 License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0.

---

<div align="center">
  <p>Thank you for contributing to Hermes! 🙏</p>
  <p>Hermes © 2026</p>
</div>
