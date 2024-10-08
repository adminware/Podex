{

	$isHTMX = $($WebEvent.Request.Headers.'HX-Request')
	$db = (Get-PodeConfig).Podex.DBFile

	Write-FormattedLog -tag 'api' -log "CRUD API: $($WebEvent.Method.ToUpper()) $($WebEvent.Path) `$isHTMX:$($isHTMX) Q: $($WebEvent.Query | ConvertTo-Json -Compress)"

	try {
		$data = $WebEvent.Data

		if (-not $data) {
			Write-FormattedLog -tag 'error' -log "No data received in PUT request"
			Write-PodeJsonResponse -StatusCode 400 -Value @{ message = "No data received in request" }
			return
		}

		Write-FormattedLog -tag 'debug' -log "Parsed PUT data: $($data | ConvertTo-Json -Compress)"

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

		if (-not $data.tag) {
			Write-FormattedLog -tag 'error' -log "Missing required field: tag"
			Write-PodeJsonResponse -StatusCode 400 -Value @{ message = "Missing required field: tag" }
			return
		}

		if (-not [int]::TryParse($data.id, [ref]$null)) {
			Write-FormattedLog -tag 'error' -log "Invalid id value"
			Write-PodeJsonResponse -StatusCode 400 -Value @{ message = "Invalid id value" }
			return
		}

		$sanitizedApp = Remove-UnsafeCharacter $data.application
		$sanitizedCRUD = Remove-UnsafeCharacter $data.featureName

		$sqlx = "UPDATE [feature] SET [application] = @application, [featureName] = @featureName, [rank] = @rank, [tag] = @tag, [updated_at] = CURRENT_TIMESTAMP WHERE [id] = @id;"
		$params = @{
			id = $data.id
			application = $sanitizedApp
			featureName = $sanitizedCRUD
			tag = $data.tag
			rank = $data.rank
		}
		Write-FormattedLog -tag 'database' -log "db: $($db); sqlx: $($sqlx); params: $($params | ConvertTo-Json -Compress)"
		Invoke-SqliteQuery -DataSource $db -Query $sqlx -SqlParameters $params
		Write-FormattedLog -tag 'debug' -log "CRUD updated successfully"
		Write-PodeJsonResponse -StatusCode 200 -Value @{ message = "CRUD updated successfully" }

	} catch {
		Write-FormattedLog -tag 'error' -log "Error updating feature: $_"
		Write-PodeJsonResponse -StatusCode 500 -Value @{ message = "Internal server error" }
	}

}
