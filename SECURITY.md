# Security Policy

This document outlines the security practices and responsible disclosure guidelines for Hermes.

---

## 🔐 Supported Versions

| Version | Supported | Notes |
|---------|-----------|-------|
| v1.0.0-desktop | ✅ Yes | Latest stable release |
| v1.0.0-beta.x | ✅ Yes | Beta releases |
| < v1.0.0-beta.1 | ❌ No | End of life |

---

## 🚨 Reporting a Vulnerability

**We take security seriously.** If you discover a security vulnerability, please report it responsibly.

### How to Report

1. **DO NOT** create a public GitHub issue for security vulnerabilities
2. Email the maintainer directly or use GitHub's private vulnerability reporting
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### Response Time

- **Initial Response**: Within 24-48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depending on severity (hours to weeks)

---

## 🔒 Security Features

### Data Transfer

- **HTTPS Encryption**: All file transfers use HTTPS with self-signed certificates
- **Local Network Only**: Data never leaves your LAN
- **No Cloud Storage**: All transfers are direct device-to-device

### Permissions

Hermes requests the following permissions:

| Permission | Purpose |
|------------|--------|
| `INTERNET` | Network communication |
| `ACCESS_WIFI_STATE` | Wi-Fi status detection |
| `ACCESS_NETWORK_STATE` | Network information |
| `READ_EXTERNAL_STORAGE` | File access |
| `WRITE_EXTERNAL_STORAGE` | Save received files |
| `CAMERA` | QR code scanning |
| `ACCESS_FINE_LOCATION` | Wi-Fi Direct requires location permission |
| `ACCESS_COARSE_LOCATION` | Wi-Fi Direct requires location permission |

---

## 🛡️ Best Practices

### For Users

1. **Only Transfer on Trusted Networks**
   - Use Hermes on your home network or trusted Wi-Fi
   - Avoid public Wi-Fi when possible

2. **Verify Connection**
   - Always scan the QR code from the sender's device directly
   - Don't transfer sensitive files over untrusted networks

3. **Keep the App Updated**
   - Always use the latest version from the Releases page
   - Enable automatic updates when available

### For Developers

1. **Dependency Scanning**
   - Run `flutter pub outdated` regularly
   - Update dependencies to latest stable versions

2. **Code Review**
   - All changes require review before merging
   - CI/CD runs security checks on every PR

3. **Secure Storage**
   - Never store sensitive data in plain text
   - Use secure storage for credentials

---

## ⚠️ Known Security Considerations

### Local Network Transfer

Since Hermes operates on your local network:

1. **Same Network Required**: Both devices must be on the same Wi-Fi network
2. **Firewall**: Some router firewalls may block transfers
3. **QR Code Exposure**: Anyone on your network can see the QR code

### Recommendations

- Use a secure, password-protected Wi-Fi network
- Disable network sharing on guest networks
- Only transfer files with trusted devices

---

## 📜 Security Updates

Security updates are released as part of regular version updates.

| Version | Type | Release Date |
|--------|------|-------------|
| v1.0.0-desktop | Security + Features | 2026-04-21 |

---

## 📧 Contact

For security-related inquiries:

1. Create a private report via GitHub
2. Email the repository owner

**Do NOT** use the public issue tracker for security vulnerabilities.

---

## 📝 License

This security policy is part of the Hermes project and is subject to the GPLv3 license.

<div align="center">
  <p>Hermes © 2026 | Security is our priority 🔐</p>
</div>