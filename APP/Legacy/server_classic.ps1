# Настройки
$port = 8000

# Определяем локальный IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -like "192.168.*" -and $_.InterfaceAlias -notlike "*Virtual*" } |
    Select-Object -First 1).IPAddress

if (-not $ip) {
    Write-Host "❌ Не удалось определить IP-адрес." -ForegroundColor Red
    exit
}

$url = "http://$ip`:$port"
Write-Host "`n🌐 Подключись к серверу по адресу: $url`n"

# Генерация QR через Python + Pillow
$tempQr = "$env:TEMP\gen_qr_img.py"
Set-Content $tempQr @"
import qrcode
import sys
img = qrcode.make(sys.argv[1])
img.save('qr.png')
"@

# Создание PNG
python $tempQr $url

# Удаляем временный Python-файл
Remove-Item $tempQr

# Открываем QR в стандартной программе
Start-Process "qr.png"

# Запуск сервера
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
Write-Host "`n🚀 Запуск сервера..."
python -m http.server $port
