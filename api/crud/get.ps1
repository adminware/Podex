{

	$isHTMX = $($WebEvent.Request.Headers.'HX-Request')
	$db = (Get-PodeConfig).Podex.DBFile

	Write-FormattedLog -tag 'api' -log "CRUD API: $($WebEvent.Method.ToUpper()) $($WebEvent.Path) `$isHTMX:$($isHTMX) Q: $($WebEvent.Query | ConvertTo-Json -Compress)"

	try {
		$tagFilter = $WebEvent.Query['tagFilter']
		$search = $WebEvent.Query['search']
		$page = [int]($WebEvent.Query['page'] ?? 1)
		$pageSize = [int]($WebEvent.Query['pageSize'] ?? 10)

		# Write-FormattedLog -tag 'debug' -log "query: $($WebEvent.Query | ConvertTo-Json -Compress)"

		$offset = ($page - 1) * $pageSize

		$sqlx = "SELECT [id], [application], [featureName], [tag], date([created_at]) as [created_at], [rank] FROM [feature]"
		$countSqlx = "SELECT Count(*) as count FROM [feature]"
		$whereClause = ""
		$params = @{}

		if ($tagFilter -or $search) {
			$whereClause = " WHERE"
			if ($tagFilter) {
				$whereClause += " lower([tag]) = lower(@tagFilter)"
				$params['tagFilter'] = $tagFilter
			}
			if ($search) {
				if ($tagFilter) { $whereClause += " AND" }
				$whereClause += " ([application] LIKE @search OR [featureName] LIKE @search)"
				$params['search'] = "%$search%"
			}
		}

		$sqlx += $whereClause
		$countSqlx += $whereClause

		$sqlx += " ORDER BY [rank] DESC, [created_at] DESC LIMIT @pageSize OFFSET @offset;"

		$params['pageSize'] = $pageSize
		$params['offset'] = $offset

		# Write-FormattedLog -tag 'database' -log "db: $($db); sqlx: $($sqlx); tagFilter: $tagFilter; search: $search; params: $($params | ConvertTo-Json -Compress)"
		$rs = (Invoke-SqliteQuery -DataSource $db -Query $sqlx -SqlParameters $params -As PSObject)

		# Write-FormattedLog -tag 'database' -log "db: $($db); countSqlx: $($countSqlx); tagFilter: $tagFilter; search: $search; params: $($params | ConvertTo-Json -Compress)"
		$totalItems = (Invoke-SqliteQuery -DataSource $db -Query $countSqlx -SqlParameters $params -As PSObject).count

		$tags = (Invoke-SqliteQuery -DataSource $db -Query "select [tag], case when [tag] = '$($tagFilter)' then 'selected' else '' end as [selected] from [tag] order by [tag] asc ;" -As PSObject)

		$startIndex = $offset + 1
		$endIndex = [Math]::Min($offset + $pageSize, $totalItems)
		$totalPages = [Math]::Ceiling($totalItems / $pageSize)
		$hasPreviousPage = $page -gt 1
		$hasNextPage = $page -lt $totalPages

		$pages = @()
		for ($i = 1; $i -le $totalPages; $i++) {
			$pages += @{
				number = $i
				isActive = $i -eq $page
			}
		}

		$response = @{
			features = $rs
			tags = $tags
			startIndex = $startIndex
			endIndex = $endIndex
			totalItems = $totalItems
			hasPreviousPage = $hasPreviousPage
			hasNextPage = $hasNextPage
			previousPage = if ($hasPreviousPage) { $page - 1 } else { $null }
			nextPage = if ($hasNextPage) { $page + 1 } else { $null }
			pages = $pages
			currentPage = $page
		}

		# Write-FormattedLog -tag 'debug' -log ($response | ConvertTo-Json -Depth 5 -Compress) -save $true

		if ($isHTMX) {
			Write-FormattedLog -tag 'debug' -log "CRUDs found: $($rs.Count)"
			$response | ConvertTo-Json -Depth 5 | Write-PodeJsonResponse -StatusCode 200
		} else {
			if ($response.features) {
				Write-FormattedLog -tag 'debug' -log "CRUDs found: $($rs.Count)"
				$response | ConvertTo-Json -Depth 5 | Write-PodeJsonResponse -StatusCode 200
			} else {
				Write-FormattedLog -tag 'debug' -log "No features found"
				Write-PodeJsonResponse -StatusCode 204 -Value @{ message = "No features found" }
			}
		}

	} catch {
		Write-FormattedLog -tag 'error' -log "Error retrieving features: $_"
		Write-PodeJsonResponse -StatusCode 500 -Value @{ message = "Internal server error" }
	}

}
