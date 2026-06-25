

# Project: DirXplore iOS – Advanced HTTP Directory Downloader

Build a production-quality iOS-only application called **DirXplore** using Flutter as the primary framework.

## Objective

Create a high-performance iPhone application that can:

* Browse HTTP directory listings.
* Download files and folders from HTTP servers.
* Support SOCKS5 proxies.
* Continue downloads in the background using native iOS APIs.
* Resume interrupted downloads automatically.
* Store downloaded files inside the application's Documents directory.
* Provide a premium iOS-native user experience inspired by modern Liquid Glass design.

Target platform:

* iOS 17+
* iPhone only
* Personal sideloading supported
* Optimized for iPhone 15 Pro and newer devices

---

## Technology Stack

### Flutter

Use Flutter for:

* UI
* Navigation
* State management
* Download management interface
* File browser interface

Recommended:

* Riverpod
* GoRouter
* Dio
* flutter_animate
* freezed
* json_serializable

### Swift

Create native iOS modules for:

* Background URLSession downloads
* Download persistence
* Resume data generation
* Notification handling
* File management
* App lifecycle integration

### C++

Use only if beneficial for:

* Directory crawling engine
* High-performance parsing
* Large queue management
* Hash verification

Expose via:

* Flutter FFI

---

# Core Features

## Browser Tab

HTTP Directory Browser

Capabilities:

* Open HTTP URLs
* Open HTTPS URLs
* Open local network servers
* Example:put this as default in browser tab-

  * [http://172.16.50.4](http://172.16.50.4)

Automatically detect:

* Files
* Folders
* Sizes
* Last modified dates

Features:

* Breadcrumb navigation
* Folder navigation
* Search
* Sort
* Refresh
* Pull to refresh

Support:

* Apache directory listings
* Nginx directory listings
* Generic HTML directory indexes

---

## Download Tab

Professional download manager.

Display:

* Active downloads
* Paused downloads
* Completed downloads
* Failed downloads

Each download should show:

* Filename
* Speed
* ETA
* Progress
* Downloaded size
* Remaining size

Actions:

* Pause
* Resume
* Retry
* Cancel
* Share
* Open

---

## Background Downloads

Use native iOS Background URLSession.

Requirements:

* Downloads continue while app is backgrounded.
* Downloads continue when screen locks.
* Downloads survive temporary network interruptions.
* Completed downloads notify user.
* App restores download state after relaunch.

Do not use fake background execution.

Use native iOS implementation.

---

## Resume Support

Critical requirement.

If download fails:

* Save partial file.
* Save resume metadata.
* Resume from exact byte position.

Use:

* HTTP Range Requests

Support:

* Automatic retries
* Resume after network loss
* Resume after app restart

Never restart large downloads from zero when server supports range requests.

---

## Download Reliability

Implement:

* Retry system
* Exponential backoff
* Download checkpointing
* Integrity validation

User configurable:

* Retry count
* Timeout
* Parallel downloads

---

## Proxy Tab

SOCKS5 Manager

Features:

* Add proxy
* Edit proxy
* Delete proxy
* Enable/Disable proxy

Fields:

* Host
* Port
* Username
* Password

Capabilities:

* Route browser traffic through SOCKS5
* Route downloads through SOCKS5
* Test proxy connection

Show:

* Current IP
* Connection latency
* Proxy status

Persist proxy configuration securely.

Use iOS Keychain for credentials.

---(put this as defauld in proxy tab-
type: socks5
    server: 103.166.253.92
    port: 1088
    username: test
    password: test

## Files Tab

Built-in file explorer.

Store files inside app Documents directory.

Capabilities:

* Browse folders
* Create folders
* Rename
* Delete
* Move
* Copy
* Sort

Preview:

* Images
* Videos
* Audio
* Text files
* PDFs

Support:

* Share sheet
* Open in external apps

---

## Settings Tab

Options:

* Concurrent downloads
* Retry count
* Download location
* Theme
* Notification settings
* Proxy defaults
* Auto-resume behavior
* Background download behavior

---

# User Interface

Design language:

* Native iOS feel
* Smooth animations
* Liquid Glass inspired appearance
* Blur effects
* Depth effects
* Responsive layouts

Use:

* Cupertino widgets
* Native transitions
* Haptic feedback
* Spring animations

Requirements:

* 120Hz smooth scrolling
* Dark mode
* Light mode

---

# Download Engine

Requirements:

* Queue management
* Priority downloads
* Parallel downloads
* Pause
* Resume
* Retry
* Automatic recovery

Support:

* Files larger than 100 GB
* Thousands of queued files

Memory efficient implementation required.

---

# Security

Store:

* Proxy credentials in Keychain
* Download metadata securely

Validate:

* URLs
* Filenames
* Paths

Prevent:

* Path traversal attacks
* Invalid file writes

---

# Performance

Optimize for:

* Low memory usage
* Low battery usage
* Large downloads
* Large directories

Avoid blocking UI thread.

Use isolates where appropriate.

---

# Deliverables

Generate:

1. Complete Flutter project.
2. Native Swift background download module.
3. Flutter FFI bridge if C++ is used.
4. Clean architecture.
5. Production-ready code.
6. Build instructions.
7. GitHub Actions workflow for iOS builds.
8. IPA generation workflow.
9. Unit tests.
10. Integration tests.

The final application must behave like a professional iOS download manager and file browser, with robust background downloading, SOCKS5 support, resume capabilities, and a polished iOS-native experience.

---

One important limitation: on iPhone, **"download should never fail" is impossible to guarantee**. The best you can do is automatic retries, resume support, background URLSession, and recovery after network interruptions. iOS can still stop a download because of server issues, storage exhaustion, proxy failures, or the server not supporting HTTP range requests. Designing for graceful recovery is the correct goal.
