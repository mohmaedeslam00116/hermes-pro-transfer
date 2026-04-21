# Contributing to Hermes

Thank you for your interest in contributing to Hermes! This document provides guidelines and instructions for contributing.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Submitting Changes](#submitting-changes)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Reporting Issues](#reporting-issues)

---

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

---

## Getting Started

1. **Fork the Repository**
   Click the "Fork" button on the GitHub repository page.

2. **Clone Your Fork**
   ```bash
   git clone https://github.com/YOUR-USERNAME/hermes-pro-transfer.git
   cd hermes-pro-transfer
   ```

3. **Add Upstream Remote**
   ```bash
   git remote add upstream https://github.com/mohmaedeslam00116/hermes-pro-transfer.git
   ```

---

## Development Setup

### Prerequisites

- Flutter SDK 3.27.0 or higher
- Android SDK 26+
- Git

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
# Mobile
flutter run

# Desktop (Linux)
flutter config --enable-linux-desktop
flutter run -d linux

# Desktop (Windows)
flutter config --enable-windows-desktop
flutter run -d windows
```

---

## Making Changes

### 1. Create a Branch

```bash
# Update your local main branch
git checkout main
git pull upstream main

# Create a new feature branch
git checkout -b feature/your-feature-name
```

### 2. Branch Naming Convention

- `feature/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `test/` - Test additions/changes

### 3. Make Your Changes

Write clean, well-documented code following the coding standards below.

---

## Submitting Changes

### 1. Commit Your Changes

```bash
git add .
git commit -m "feat: Add new feature description"
```

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Refactoring
- `test:` Testing
- `ci:` CI/CD changes

### 2. Push Your Changes

```bash
git push origin feature/your-feature-name
```

### 3. Open a Pull Request

1. Go to the original repository
2. Click "New Pull Request"
3. Select your branch
4. Fill in the PR template
5. Submit!

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
Describe how you tested your changes

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-reviewed code
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
```

---

## Coding Standards

### Flutter/Dart Style

- Use `dart format` before committing
- Maximum line length: 80 characters
- Use meaningful variable names
- Add comments for complex logic

### File Structure

```
lib/
├── core/           # Constants, themes
├── models/         # Data models
├── providers/      # State management
├── services/       # Business logic
└── screens/       # UI screens
    ├── widgets/   # Reusable widgets
    └── ...
```

### Naming Conventions

- **Classes**: PascalCase (`TransferState`)
- **Variables/Functions**: camelCase (`transferProgress`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_FILE_SIZE`)
- **Files**: snake_case (`transfer_state.dart`)

---

## Testing

### Run Tests

```bash
# All tests
flutter test

# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# With coverage
flutter test --coverage
```

### Write Tests

- Write tests for all new features
- Update existing tests for changes
- Aim for 80%+ code coverage

### Test Files

```
test/
├── unit/
│   ├── models/
│   └── providers/
└── widget/
```

---

## Reporting Issues

### Before Creating an Issue

1. Check existing issues
2. Update to the latest version
3. Search for similar issues

### Creating an Issue

**Bug Report Template:**
```markdown
## Bug Description
Clear description of the bug

## Steps to Reproduce
1. Go to '...'
2. Click on '...'
3. See error

## Expected Behavior
What you expected to happen

## Screenshots
If applicable

## Environment
- Device: 
- OS: 
- App Version: 
```

---

## License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0 (GPLv3).

---

<div align="center">
  <p>Thank you for contributing to Hermes! 🚀</p>
</div>