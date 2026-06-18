# Настройки порта
$port = 8000

# Умное определение локального IPv4 с фильтрацией мусора и авто-адресов Windows (APIPA)
$ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { 
    $_.InterfaceAlias -notlike "*Virtual*" -and 
    $_.InterfaceAlias -notlike "*Loopback*" -and 
    $_.IPAddress -ne "127.0.0.1" -and
    $_.IPAddress -notlike "169.254.*"
} | Select-Object -First 1).IPAddress

# Если нормальный IP не найден, пишем ошибку и выходим
if (-not $ip) {
    Write-Host "`n[X] Ошибка: Реальный IP-адрес не найден!" -ForegroundColor Red
    Write-Host "Проверьте, подключен ли компьютер к роутеру или Wi-Fi.`n" -ForegroundColor Yellow
    pause
    exit
}

# Формируем URL
$url = "http://$ip`:$port"
Write-Host "`n[!] URL: $url`n"

# Python-код для генерации QR (выполняется строго в оперативной памяти)
$pythonCode = @"
import qrcode, sys
sys.stdout.reconfigure(encoding='utf-8')
qr = qrcode.QRCode()
qr.add_data(sys.argv[1])
qr.make(fit=True)
modules = qr.modules
for r in range(0, qr.modules_count, 2):
    for c in range(qr.modules_count):
        top = modules[r][c]
        bottom = modules[r+1][c] if (r+1) < qr.modules_count else False
        if top and bottom: sys.stdout.write(' ')
        elif top: sys.stdout.write('▄')
        elif bottom: sys.stdout.write('▀')
        else: sys.stdout.write('█')
    sys.stdout.write('\n')
"@

# Запуск генерации QR без создания временных файлов на диске
python -c $pythonCode $url

# Переходим в рабочую папку и поднимаем веб-сервер
Set-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Path)
Write-Host "`nStarting server..."
python -m http.server $port