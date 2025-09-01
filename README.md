# 🚀 CiwAI Drive

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Netlify Status](https://api.netlify.com/api/v1/badges/YOUR_NETLIFY_BADGE/deploy-status)](https://ciwaidrive.netlify.app)

**CiwAI Drive** is a **Flutter Web** application for uploading and sharing files in a simple and secure way.  
Originally built for internal needs (e.g., SKh Jannatul Aulad), but flexible enough for any project.

---

## ✨ Features
- 🔐 **Google Sign-In** → only authorized admins can upload files.
- 📂 **Google Drive integration** → files are stored neatly inside the `raw_uploads/` folder.
- ✅ **Email whitelist** → access is restricted to emails defined in `.env`.
- 🌐 **Web-first** → just open the Netlify link, no app installation needed.

---

## 🛠️ Tech Stack
- [Flutter Web](https://flutter.dev/web)
- [Google Sign-In](https://pub.dev/packages/google_sign_in)
- [Google Drive API](https://developers.google.com/drive)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)

---

## ⚙️ Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/Ciwai-lab/ciwai-drive.git
   cd ciwai-drive
