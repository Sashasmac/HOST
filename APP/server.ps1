# Настройки
$port = 8000

# Определяем локальный IP
$ip = (Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -like "192.168.*" -and $_.InterfaceAlias -notlike "*Virtual*" } |
    Select-Object -First 1).IPAddress

if (-not $ip) {
    Write-Host "X Error: IP not found." -ForegroundColor Red
    exit
}

$url = "http://$ip`:$port"
Write-Host "`n[!] URL: $url`n"

# Генерация компактного QR (2 строки в 1)
$tempQr = "$env:TEMP\gen_qr_compact.py"
$pythonCode = @"
import qrcode
import sys

# Принудительно ставим UTF-8 для вывода в консоль
sys.stdout.reconfigure(encoding='utf-8')

qr = qrcode.QRCode()
qr.add_data(sys.argv[1])
qr.make(fit=True)

# Компактный вывод (используем символы верхнего/нижнего полублока)
# Это делает QR квадратным и читаемым
modules = qr.modules
for r in range(0, qr.modules_count, 2):
    for c in range(qr.modules_count):
        top = modules[r][c]
        bottom = modules[r+1][c] if (r+1) < qr.modules_count else False
        
        if top and bottom: sys.stdout.write(' ') # Оба черные (инверсия для белого фона консоли)
        elif top: sys.stdout.write('▄')        # Только верхний
        elif bottom: sys.stdout.write('▀')     # Только нижний
        else: sys.stdout.write('█')           # Оба белые
    sys.stdout.write('\n')
"@
Set-Content -Path $tempQr -Value $pythonCode -Encoding UTF8

# Вывод QR-кода
python $tempQr $url

# Удаляем временный файл
Remove-Item $tempQr

# Запуск сервера
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
Write-Host "`nStarting server..."
python -m http.server $port