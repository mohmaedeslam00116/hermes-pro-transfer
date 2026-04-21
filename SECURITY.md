# Security Policy

## 🔐 Security at Hermes

Hermes is committed to ensuring the security and privacy of your data. This document outlines our security practices and how to report vulnerabilities.

---

## 📋 Table of Contents

- [Security Principles](#security-principles)
- [Supported Versions](#supported-versions)
- [Reporting a Vulnerability](#reporting-a-vulnerability)
- [Security Features](#security-features)
- [Best Practices](#best-practices)
- [Data Handling](#data-handling)

---

## Security Principles

### 1. Local Network Only
- All file transfers occur within your local network
- No data is sent to external servers
- No cloud storage integration

### 2. No Tracking
- No analytics or telemetry
- No usage data collection
- No advertising SDKs

### 3. Open Source
- All code is publicly available
- Community security audits
- Transparent implementation

### 4. Minimal Permissions
- Only required permissions are requested
- No unnecessary device access
- Clear explanation for each permission

---

## Supported Versions

| Version | Status | Security Support |
|---------|--------|------------------|
| v1.0.0-beta.1 | Current | ✅ Active |
| Older versions | Unsupported | ❌ Not monitored |

---

## Reporting a Vulnerability

### Responsible Disclosure

We follow responsible disclosure practices for security vulnerabilities.

### How to Report

1. **DO NOT** create a public GitHub issue for security vulnerabilities
2. Email the details privately to the maintainer
3. Include the following information:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial Assessment**: Within 7 days
- **Fix Timeline**: Based on severity
  - Critical: 7 days
  - High: 30 days
  - Medium: 90 days
  - Low: Next release

### Out of Scope
- Social engineering attacks
- Physical security
- Denial of service attacks on public infrastructure
- Issues in third-party dependencies (report upstream)

---

## Security Features

### Transfer Encryption
- HTTPS with self-signed certificates for local transfers
- Encrypted Wi-Fi Direct connections
- WebRTC DTLS encryption for P2P transfers

### Data Protection
- Files are never stored permanently on intermediary devices
- Temporary files are cleaned up after transfer
- No file metadata sent to external servers

### Network Isolation
- Transfers are confined to local network
- No port forwarding required
- Firewall-friendly design

---

## Best Practices

### For Users

#### ✅ Do
- Only transfer files on trusted networks
- Keep the app updated to the latest version
- Review file transfer requests before accepting
- Disconnect from file sharing when not in use

#### ❌ Don't
- Transfer sensitive files on public Wi-Fi
- Accept file transfers from unknown devices
- Share your local network with untrusted devices
- Use modified versions of the app

### For Developers

#### ✅ Do
- Follow secure coding practices
- Use parameterized queries
- Validate all user input
- Keep dependencies updated
- Run security audits regularly

#### ❌ Don't
- Log sensitive data
- Hardcode credentials
- Use deprecated cryptographic methods
- Skip security code reviews

---

## Data Handling

### Permissions Required

| Permission | Purpose | Data Accessed |
|------------|---------|---------------|
| `INTERNET` | Local network transfer | Network connectivity |
| `ACCESS_WIFI_STATE` | Wi-Fi detection | Wi-Fi connection status |
| `CHANGE_WIFI_STATE` | Wi-Fi Direct | Wi-Fi state changes |
| `ACCESS_FINE_LOCATION` | Wi-Fi Direct P2P | Device discovery |
| `READ_EXTERNAL_STORAGE` | File selection | Selected files only |
| `WRITE_EXTERNAL_STORAGE` | Save received files | Download folder |

### Data Collection

**Hermes does NOT collect:**
- ❌ Personal information
- ❌ Device identifiers
- ❌ Usage statistics
- ❌ File contents
- ❌ Network metadata
- ❌ Location data

**Hermes DOES store locally:**
- ✅ App settings (shared_preferences)
- ✅ Transfer history (optional)
- ✅ Network configuration

---

## Security Updates

### Update Policy
- Security patches are released as soon as possible
- Users are notified of critical updates
- Automatic update checks (user-configurable)

### Version Security

| Version | Security Support |
|---------|------------------|
| Current Release | Full support |
| Previous Major | 6 months |
| Older versions | Community support |

---

## Incident Response

### If a Security Incident Occurs

1. **Acknowledge** the issue immediately
2. **Assess** the impact and scope
3. **Contain** the vulnerability
4. **Notify** affected users
5. **Remediate** with a patch
6. **Review** and improve security measures

### Contact

For security-related issues:
- **GitHub Issues**: Not recommended for security issues
- **Direct Contact**: Through GitHub's private vulnerability reporting

---

## Compliance

### Standards Adherence
- Follows Android security best practices
- GDPR compliant (no EU user data)
- COPPA compliant (no children's data collection)

### Third-Party Libraries
- All dependencies are vetted for security
- Known vulnerabilities are patched promptly
- Minimal dependencies to reduce attack surface

---

## 🔒 Security Checklist

- [x] No external data transmission
- [x] HTTPS for HTTP transfers
- [x] No analytics or tracking
- [x] Minimal permissions
- [x] Open source code
- [x] Security policy in place
- [x] Responsible disclosure process
- [ ] Third-party security audit (planned)
- [ ] Bug bounty program (planned)

---

## 📞 Questions?

If you have security questions or concerns:
1. Review this document
2. Check existing issues
3. Contact the maintainer privately

---

<div align="center">
  <p>Security is a shared responsibility. Thank you for helping keep Hermes safe! 🔒</p>
  <p>Hermes © 2026</p>
</div>
