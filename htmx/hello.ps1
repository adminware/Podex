{
	Write-FormattedLog -tag 'htmx' -log "$($WebEvent.Method.ToUpper()) $($WebEvent.Path) Q: $($WebEvent.Query | ConvertTo-Json -Compress)"

	Write-PodeHtmlResponse -Value "Hello, World!"
}
