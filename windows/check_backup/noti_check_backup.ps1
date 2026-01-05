[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Đường dẫn sessions
$path = "C:\Program Files (x86)\Plesk\PMM\sessions"

# Lấy thư mục mới nhất
$latestFolder = Get-ChildItem -Path $path -Directory |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

# Xác định file migration.result
$file = Join-Path $latestFolder.FullName "migration.result"

# Từ khóa (ngắn, bền với biến thể)
$keywords = @(
  'Extension transport',
  's3-backup',
  'UploadPart',
  'smartcloud.vn',
  'There is not enough disk space'
  'Unable to create the remote backup'
)

function Send-Telegram {
  param([string]$Message)
  if ([string]::IsNullOrWhiteSpace($Message)) { return }
  $token  = "7906718103:AAF3iHA7ld0kG-GESmY4lo9zSvvyjxHINB0"
  $chatId = "-4528840367"
  $url = "https://api.telegram.org/bot$token/sendMessage"
  $body = @{ chat_id = $chatId; text = $Message } | ConvertTo-Json -Compress
  $utf8 = [Text.Encoding]::UTF8.GetBytes($body)
  try { Invoke-RestMethod -Uri $url -Method Post -Body $utf8 -ContentType "application/json; charset=utf-8" | Out-Null } catch { }
}

if (Test-Path $file) {
  # Đọc raw (để tránh mất ký tự/linebreak), rồi parse XML
  $raw = Get-Content -LiteralPath $file -Raw
  try {
    [xml]$xml = $raw
  } catch {
    # Nếu XML lỗi, fallback về quét text
    $xml = $null
  }

  $hits = @()

  if ($xml) {
    # Lấy toàn bộ nội dung <description> (warning/error)
    $nodes = $xml.SelectNodes('//message/description')
    foreach ($n in $nodes) {
      $text = $n.InnerText
      foreach ($kw in $keywords) {
        if ($text -like "*$kw*") {
          $hits += $text
          break
        }
      }
    }
  } else {
    # Fallback: quét toàn file bằng các keyword ngắn (không match nguyên văn dài)
    foreach ($kw in $keywords) {
      $m = Select-String -InputObject $raw -Pattern ([Regex]::Escape($kw))
      if ($m) { $hits += ($m | Select-Object -Expand Line) }
    }
  }

  if ($hits.Count -gt 0) {
    $serverIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.254.*" } | Select-Object -First 1 -ExpandProperty IPAddress)
    $timeNow  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$msg = "Server IP: $serverIP`nThời gian: $timeNow`n⚠️ Backup failed`nNội dung:`n- " +
       (($hits | Select-Object -Unique | ForEach-Object { $_.Trim() }) -join "`n- ")

    Send-Telegram $msg
    exit 1
  } else {
    Write-Output "✅ Không phát hiện lỗi trong $file"
  }
} else {
  $msg = "⚠️ Không tìm thấy file migration.result: $file"
  Send-Telegram $msg
  exit 1
}