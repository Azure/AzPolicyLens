<#
================================================================================================================
AUTHOR: Tao Yang
DATE: 11/09/2025
NAME: AzPolicyLens.Wiki.Encryption.Helper.psm1
VERSION: 2.0.0
COMMENT: this nested module contains the encryption and security utility functions for AzPolicyLens.Wiki module
================================================================================================================
#>
using module ./AzPolicyLens.Wiki.Utility.Helper.psm1
#function to decrypt file using AES
function decryptStuff {
  [CmdletBinding()]
  [OutputType([string])]
  param (
    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyFile')]
    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyDirect')]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$InputFilePath,

    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyFile')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyDirect')]
    [ValidateNotNullOrEmpty()]
    [string]$InputText,

    [Parameter(Mandatory = $false)]
    [string]$OutputFilePath,

    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyFile')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyFile')]
    [ValidateScript({ Test-Path $_ -PathType Leaf })]
    [string]$KeyFilePath,

    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyDirect')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyDirect')]
    [string]$AESKey,

    [Parameter(Mandatory = $true, ParameterSetName = 'FileInKeyDirect')]
    [Parameter(Mandatory = $true, ParameterSetName = 'TextInKeyDirect')]
    [string]$AESIV
  )

  try {
    Write-Verbose "[$(getCurrentUTCString)]: Starting AES decryption" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $startTime = [datetime]::UtcNow

    # Load key and IV
    if ($PSCmdlet.ParameterSetName -eq 'FileInKeyFile' -or $PSCmdlet.ParameterSetName -eq 'TextInKeyFile') {
      $KeyFullPath = (Resolve-Path -Path $KeyFilePath).path
      Write-Verbose "[$(getCurrentUTCString)]: Loading key from file: $KeyFullPath" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $keyJson = [System.IO.File]::ReadAllText($KeyFullPath)
      $keyObject = $keyJson | ConvertFrom-Json
      $keyBytes = [Convert]::FromBase64String($keyObject.Key)
      $ivBytes = [Convert]::FromBase64String($keyObject.IV)
    } else {
      $keyBytes = [Convert]::FromBase64String($AESKey)
      $ivBytes = [Convert]::FromBase64String($AESIV)
    }
    if ($InputFilePath) {
      # Read encrypted file
      Write-Verbose "[$(getCurrentUTCString)]: Reading encrypted file: $InputFilePath" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $InputText = [System.IO.File]::ReadAllText($InputFilePath)
    }
    $encryptedObject = $InputText | ConvertFrom-Json

    # Extract encrypted data
    $encryptedBytes = [Convert]::FromBase64String($encryptedObject.EncryptedData)
    Write-Verbose "[$(getCurrentUTCString)]: Encrypted size: $($encryptedBytes.Length) bytes" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    Write-Verbose "[$(getCurrentUTCString)]: Algorithm: $($encryptedObject.Algorithm)" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    Write-Verbose "[$(getCurrentUTCString)]: Compressed: $($encryptedObject.Compressed)" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

    # Create AES instance
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $keyBytes
    $aes.IV = $ivBytes
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7

    # Create decryptor
    $decryptor = $aes.CreateDecryptor()

    # Decrypt data
    Write-Verbose "[$(getCurrentUTCString)]: Decrypting data" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)

    # Decompress if needed
    if ($encryptedObject.Compressed) {
      Write-Verbose "[$(getCurrentUTCString)]: Decompressing data" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $memoryStream = [System.IO.MemoryStream]::new($decryptedBytes)
      $gzipStream = New-Object System.IO.Compression.GZipStream($memoryStream, [System.IO.Compression.CompressionMode]::Decompress)
      $outputStream = New-Object System.IO.MemoryStream
      $gzipStream.CopyTo($outputStream)
      $decryptedBytes = $outputStream.ToArray()

      # Cleanup compression streams
      $gzipStream.Dispose()
      $memoryStream.Dispose()
      $outputStream.Dispose()
    }

    Write-Verbose "[$(getCurrentUTCString)]: Decrypted size: $($decryptedBytes.Length) bytes" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

    # Output result
    if ($OutputFilePath) {
      [System.IO.File]::WriteAllBytes($OutputFilePath, $decryptedBytes)
      Write-Verbose "[$(getCurrentUTCString)]: Decrypted file saved to: $OutputFilePath" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
      $result = $OutputFilePath

    } else {
      $result = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
    }

    # Cleanup
    $decryptor.Dispose()
    $aes.Dispose()

    $endTime = [datetime]::UtcNow
    $timeTaken = New-TimeSpan -Start $startTime -End $endTime
    Write-Verbose "[$(getCurrentUTCString)]: AES decryption completed in $($timeTaken.TotalSeconds) seconds" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

    return $result
  } catch {
    Write-Error "[$(getCurrentUTCString)]: AES decryption failed: $_" -Verbose:($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)
    throw
  } finally {
    if ($aes) { $aes.Dispose() }
    if ($decryptor) { $decryptor.Dispose() }
  }
}
