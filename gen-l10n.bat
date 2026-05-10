@echo off
setlocal

cd /d "%~dp0"

dart run tool\generate_l10n.dart
