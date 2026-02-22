# Alyaa Florist — Build & Installer Flow

## 1) Nama app + icon (sudah diset)
- Display name: **Alyaa Florist**
- Windows EXE name: `AlyaaFlorist.exe`
- Windows icon source dipakai: `assets/logo_main.png`
- Windows app icon output: `windows/runner/resources/app_icon.ico`

## 2) Build release

### Windows x64
Jalankan di mesin/VM Windows:
```bash
flutter clean
flutter pub get
flutter build windows --release
```
Output:
`build\\windows\\x64\\runner\\Release\\`

### Linux
Jalankan di Linux:
```bash
flutter clean
flutter pub get
flutter build linux --release
```
Output bundle:
`build/linux/x64/release/bundle/`

Untuk shortcut desktop Linux + icon, jalankan:
```bash
bash installer/linux/install_desktop_shortcut.sh
```

## 3) Save PDF default path
Saat klik **Save PDF** default folder diarahkan ke:
- Windows: `%USERPROFILE%\\Documents\\AlyaaFlorist\\PDF`
- Linux: `~/Documents/AlyaaFlorist/PDF`

Folder dibuat otomatis jika belum ada.

## 4) Installer Windows (.exe setup)
File script Inno Setup sudah disiapkan:
`installer/windows/AlyaaFlorist.iss`

### Cara cepat (otomatis versi dari pubspec)
1. Install **Inno Setup 6** di Windows.
2. Jalankan:
```powershell
powershell -ExecutionPolicy Bypass -File installer/windows/build_installer.ps1
```

Script akan:
- baca versi dari `pubspec.yaml`
- build `flutter build windows --release`
- build installer `.exe`

Hasil installer:
`dist/windows-installer/AlyaaFlorist-Setup-x64.exe`

### Cara manual
1. Build Flutter release dulu (`flutter build windows --release`).
2. Buka `AlyaaFlorist.iss` di Inno Setup.
3. Klik **Build**.

Fitur installer:
- Install ke Program Files
- Shortcut Start Menu
- Opsi shortcut desktop
- Uninstaller otomatis

## 5) GitHub Release (opsional)
Upload 2 artefak:
- `AlyaaFlorist-Setup-x64.exe` (utama, user-friendly)
- `Release.zip` (opsional untuk power user)
