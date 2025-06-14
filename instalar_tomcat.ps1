# CONFIGURACIÓN
$tomcatVersion = "8.5.99"
$installDir = "c:\Apps\Tomcat$tomcatVersion"
$serviceName = "Tomcat$tomcatVersion"
$tomcatZipUrl = "https://archive.apache.org/dist/tomcat/tomcat-8/v$tomcatVersion/bin/apache-tomcat-$tomcatVersion-windows-x64.zip"
$zipPath = "$env:TEMP\tomcat-$tomcatVersion.zip"

Write-Host "📥 Descargando Tomcat $tomcatVersion..."
Invoke-WebRequest -Uri $tomcatZipUrl -OutFile $zipPath

Write-Host "📦 Extrayendo en $installDir..."
Expand-Archive -Path $zipPath -DestinationPath "c:\Apps" -Force

# Renombrar carpeta
Rename-Item -Path "c:\Apps\apache-tomcat-$tomcatVersion" -NewName "Tomcat$tomcatVersion"

# Establecer variables de entorno
Write-Host "⚙️ Configurando variables de entorno..."

[System.Environment]::SetEnvironmentVariable("CATALINA_HOME", $installDir, [System.EnvironmentVariableTarget]::Machine)

# (Opcional) JAVA_HOME
if (-not $env:JAVA_HOME) {
    $javaPath = (Get-Command java.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source) -replace '\\bin\\java.exe',''
    if ($javaPath -and (Test-Path $javaPath)) {
        Write-Host "⚙️ Estableciendo JAVA_HOME en: $javaPath"
        [System.Environment]::SetEnvironmentVariable("JAVA_HOME", $javaPath, [System.EnvironmentVariableTarget]::Machine)
    } else {
        Write-Warning "❌ No se detectó JAVA_HOME. Configúralo manualmente si Tomcat no arranca."
    }
}

# Instalar como servicio
$serviceBat = Join-Path $installDir "bin\service.bat"
if (Test-Path $serviceBat) {
    Write-Host "🛠 Instalando Tomcat como servicio de Windows ($serviceName)..."
    & "$serviceBat" install $serviceName
    Start-Sleep -Seconds 2
    sc.exe start $serviceName
    Write-Host "✅ Servicio $serviceName registrado e iniciado."
} else {
    Write-Warning "❌ No se encontró service.bat en $installDir\bin. ¿Estás seguro de que es una versión Windows con scripts?"
}

# Limpieza
Remove-Item $zipPath

Write-Host "`n✅ Tomcat $tomcatVersion instalado correctamente en: $installDir"
Write-Host "ℹ️ Reinicia tu consola o equipo para que las variables surtan efecto."
