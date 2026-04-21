# Contributing to Hermes

Thank you for your interest in contributing to Hermes! 

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/mohmaedeslam00116/hermes-pro-transfer.git
   cd hermes-pro-transfer
   ```

2. **Navigate to project directory**
   ```bash
   cd hermes_pro
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build debug APK**
   ```bash
   flutter build apk --debug
   ```

## Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart)
- Use `flutter analyze` before committing
- Keep code clean and well-documented

## Branch Structure

- `main` - Stable releases
- `develop` - Development (future)
- `feature/*` - New features
- `fix/*` - Bug fixes

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and analysis (`flutter analyze`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code style
- `refactor`: Code refactoring
- `test`: Testing
- `chore`: Maintenance

## Reporting Bugs

Please report bugs using [GitHub Issues](https://github.com/mohmaedeslam00116/hermes-pro-transfer/issues).

Include:
- Flutter version
- Android version
- Steps to reproduce
- Expected vs actual behavior
- Error logs if applicable

## Feature Requests

We welcome feature requests! Please open an issue with:
- Clear description of the feature
- Use case explanation
- Any mockups or examples if available

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
