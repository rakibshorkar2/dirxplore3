# ⚡ DirXplore iOS

![License](https://img.shields.io/badge/Platform-iOS%2017%2B-blue?style=for-the-badge&logo=apple)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Swift](https://img.shields.io/badge/Swift-5.0-F05138?style=for-the-badge&logo=swift)

**DirXplore** is a premium, high-performance directory downloader and file browser for iOS. Designed specifically for power users and the **BDIX ecosystem**, it combines the beauty of **Liquid Glass** design with a robust, native background download engine.

---

## ✨ Key Features

### 🧭 Advanced Directory Browser
*   **Dual-Mode Crawler**: Optimized for traditional Apache/Nginx listings and modern Bangladeshi FTP portals (SAMONLINE, DhakaFlix, CircleFTP).
*   **Deep Scan**: Recursively crawl entire subfolder structures with a single tap.
*   **Web Sniffer**: An internal browser with a built-in "Media Sniffer" bubble to detect and capture download links from any website.

### 📥 Pro Download Manager
*   **Native Background Engine**: Powered by Swift `URLSession`. Downloads continue even if the app is closed or the screen is locked.
*   **Resumable Logic**: Interrupted or paused downloads (even 100GB+) can be resumed exactly where they left off.
*   **Real-time Metrics**: Track live speed, ETA, and exact progress with high-fidelity UI cards.
*   **Multi-Threaded Queue**: Manage concurrent downloads with automated queueing.

### 🛡️ Security & Proxy
*   **FaceID / TouchID**: Secure your downloads and private vault with native iOS biometrics.
*   **Internal SOCKS5 Tunnel**: Route all app traffic (Browser + Downloads) through multiple SOCKS5 proxy profiles.
*   **YAML Import**: Support for bulk-importing Clash-style proxy lists.

### 🎨 Next-Gen UI
*   **Liquid Glass Design**: A futuristic floating-pill navigation bar with advanced Gaussian blur effects.
*   **True Black OLED**: Optimized for iPhone 15 Pro displays with high-contrast dark mode.
*   **120Hz ProMotion**: Buttery smooth scrolling and animations.

---

## 🚀 Installation (Sideloading)

Since DirXplore is a professional utility, it is distributed via **IPA** for sideloading.

1.  Go to the [**Releases**](https://github.com/rakibshorkar2/dirxplore3/releases) page.
2.  Download the latest `DirXplore.ipa`.
3.  Open **AltStore** or **SideStore** on your iPhone.
4.  Tap the `+` icon and select the downloaded IPA.
5.  **Important**: After installation, go to *Settings > General > VPN & Device Management* and **Trust** the developer certificate.

---

## 🛠️ Technical Stack

- **Frontend**: Flutter (Riverpod, GoRouter, flutter_animate)
- **Native**: Swift (Background URLSession, Local Authentication)
- **Networking**: Dio (Native SOCKS5 Adapter)
- **CI/CD**: GitHub Actions (Unsigned IPA Workflow)

---

## 👨‍💻 Developer
Developed with ❤️ by **RAKIB**.

---

## 📄 License
This project is for personal use and sideloading. All rights reserved.
