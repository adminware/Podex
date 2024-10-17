'# required powershell modules'
Install-Module -Name PSSQLite -MinimumVersion 1.1.0 -MaximumVersion 1.99.99 -Verbose # MIT
Install-Module -Name Pode -MinimumVersion 2.11.0 -MaximumVersion 2.99.99 -Verbose # MIT

'# development powershell modules'
Install-Module -Name Pester -MinimumVersion 5.6.1 -MaximumVersion 5.99.99 -Verbose # Apache 2.0
Install-Module -Name PSScriptAnalyzer -MinimumVersion 1.23.0 -MaximumVersion 1.99.99 -Verbose # MIT

'# required npm packages'
npm install htmx.org@next htmx-ext-client-side-templates htmx-ext-debug htmx-ext-json-enc mustache
npm install tailwindcss @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio

'# development npm packages'
npm install -D eslint globals htmx-ext-debug @eslint/js prettier prettier-plugin-tailwindcss prettier-plugin-sql

'# update packages'
npm update

npm run format
npm run lint
npm run analyze
npm run test
npm run css

'# copy distribution files'
Copy-Item -Path './node_modules/htmx-ext-client-side-templates/client-side-templates.js' -Destination './public/js/client-side-templates.js' -Force -Verbose
Copy-Item -Path './node_modules/htmx-ext-debug/debug.js' -Destination './public/js/debug.js' -Force -Verbose
Copy-Item -Path './node_modules/htmx-ext-json-enc/json-enc.js' -Destination './public/js/json-enc.js' -Force -Verbose
Copy-Item -Path './node_modules/htmx.org/dist/htmx.js' -Destination './public/js/htmx.js' -Force -Verbose
Copy-Item -Path './node_modules/htmx.org/dist/htmx.min.js' -Destination './public/js/htmx.min.js' -Force -Verbose
Copy-Item -Path './node_modules/mustache/mustache.js' -Destination './public/js/mustache.js' -Force -Verbose
Copy-Item -Path './node_modules/mustache/mustache.min.js' -Destination './public/js/mustache.min.js' -Force -Verbose

'# initialize database'
$db = './podex.db'
if ((Test-Path -Path $db)) {
	$confirm = Read-Host "Do you want to reinitialize the database? (y/N)"
	if ($confirm -eq "y") {
		Invoke-SqliteQuery -DataSource $db -Query (Get-Content -Path './api/debug/init.sql' -Raw) -Verbose
	}
}
