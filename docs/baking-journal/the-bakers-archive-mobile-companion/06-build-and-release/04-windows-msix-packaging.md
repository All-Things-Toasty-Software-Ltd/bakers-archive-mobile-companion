---
title: "Windows MSIX Packaging"
seo_title: "Windows MSIX Packaging | Baking Journal"
meta_description: "The Windows runner, Flutter build, msix_config and signing used for the Microsoft Store build."
slug: "the-bakers-archive-mobile-companion/build-and-release/windows-msix-packaging"
type: "page"
order: 4
---

# Windows MSIX Packaging

## Runner layout

`windows/` is a Flutter Windows runner:

```text
windows/
  CMakeLists.txt          # project + install rules
  flutter/CMakeLists.txt  # managed Flutter tool rules (do not edit)
  runner/
    main.cpp              # window title + message loop
    Runner.rc             # VERSIONINFO, company, copyright
    app_icon.ico          # re-used from the desktop icon
```

It links `dwmapi.lib` and sets `NOMINMAX` — keep those unless you know why they are there.

## Store identity

`pubspec.yaml` carries the `msix_config:` block:

- `identity_name: ToastySoftware.TheBakersArchive`
- `publisher: CN=85C6607D-F08D-4FDB-ACC4-DAD6918EECFC`
- `publisher_display_name: Toasty Software`
- `msix_version: 1.0.0.0`
- `logo_path: web/icons/Icon-512.png`
- `capabilities: internetClient`
- `install_certificate: false` — the store re-signs on submission, so installing the cert on the builder is unnecessary.

## Build on the deployer

1. Clone the repository.
2. `flutter build windows --release`.
3. `dart run msix:create --build-windows false -c <pfx> -p <password>`.

The runner executable produced by Flutter (`bakers_archive.exe`) is embedded by the package; no separate Electron-style bundle exists.

## Versioning

`msix_version` must be four components and greater than or equal to the store's last published version. The pipeline sets it from `version: 1.0.0+6`.

## Testing locally

```powershell
flutter run -d windows
Get-Content build\windows\msix\bakers_archive.msix | Out-Null
```

Installing the MSIX locally requires the PFX subject to match, or `SignTool` must accept it as trusted on the builder.
