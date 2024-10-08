{

	$isHTMX = $($WebEvent.Request.Headers.'HX-Request')
	$db = (Get-PodeConfig).Podex.DBFile

	Write-FormattedLog -tag 'api' -log "CRUD API: $($WebEvent.Method.ToUpper()) $($WebEvent.Path) `$isHTMX:$($isHTMX) Q: $($WebEvent.Query | ConvertTo-Json -Compress)"

	try {
		$data = $WebEvent.Data

		if (-not $data) {
			Write-FormattedLog -tag 'error' -log "No data received in POST request"
			Write-PodeJsonResponse -StatusCode 400 -Value @{ message = "No data received in request" }
			return
		}

		Write-FormattedLog -tag 'debug' -log "Parsed POST data: $($data | ConvertTo-Json -Compress)"

		if (-not $data.application) {
			Write-FormattedLog -tag 'error' -log "Missing required field: application"
			Write-PodeJsonResponse -StatusCode 400 -Value @{ message = "Missing required field: application" }
			return
		}

		if (-not $data.featureName) {
			Write-FormattedLog -tag 'error' -log "Missing required field: featureName"
			Write-PodeJsonResponse -StatusCode 400 -Value @{ message = "Missing required field: featureName" }
			return
		}

		if (-not $data.featureText) {
			Write-FormattedLog -tag 'error' -log "Missing required field: featureText"
			Write-PodeJsonResponse -StatusCode 400 -Value @{ message = "Missing required field: featureText" }
			return
		}

		if (-not $data.tag) {
			Write-FormattedLog -tag 'error' -log "Missing required field: tag"
			Write-PodeJsonResponse -StatusCode 400 -Value @{ message = "Missing required field: tag" }
			return
		}

		$sanitizedApp = Remove-UnsafeCharacter $data.application
		$sanitizedCRUD = Remove-UnsafeCharacter $data.featureName
		$sanitizedCRUDText = Remove-UnsafeCharacter $data.featureText
		$sanitizedTag = Remove-UnsafeCharacter $data.tag

		$sqlx = "INSERT INTO [feature] ([application], [featureName], [featureText], [tag], [created_at], [rank]) VALUES (@application, @featureName, @featureText, @tag, @created_at, 1);"
		$params = @{
			application = $sanitizedApp
			featureName = $sanitizedCRUD
			featureText = $sanitizedCRUDText
			tag = $sanitizedTag
			created_at = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		}
		Write-FormattedLog -tag 'database' -log "db: $($db); sqlx: $($sqlx); params: $($params | ConvertTo-Json -Compress)"
		Invoke-SqliteQuery -DataSource $db -Query $sqlx -SqlParameters $params
		Write-PodeJsonResponse -StatusCode 201 -Value @{ message = "CRUD created successfully" }

	} catch {
		Write-FormattedLog -tag 'error' -log "Error in POST method: $($_.Exception.Message)"
		Write-PodeJsonResponse -StatusCode 500 -Value @{ message = "Internal server error" }
	}

}
