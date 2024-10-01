{

	Write-FormattedLog -tag 'debug' -log "Server stopping"
	Write-PodeJsonResponse -Value @{ message = 'Server stopping' }
	Close-PodeServer

}
