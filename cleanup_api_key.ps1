# ⚠️ EMERGENCY API KEY CLEANUP SCRIPT
# Run this if your API key has been committed to GitHub

Write-Host "==================================================================" -ForegroundColor Red
Write-Host "🚨 EMERGENCY: API KEY EXPOSURE CLEANUP" -ForegroundColor Red
Write-Host "==================================================================" -ForegroundColor Red
Write-Host ""

# Step 1: Confirm with user
Write-Host "This script will:" -ForegroundColor Yellow
Write-Host "1. Show you the current exposed API key" -ForegroundColor Yellow
Write-Host "2. Help you remove it from git history" -ForegroundColor Yellow
Write-Host "3. Guide you to revoke the key on Google Cloud" -ForegroundColor Yellow
Write-Host ""

$continue = Read-Host "Do you want to continue? (yes/no)"
if ($continue -ne "yes") {
    Write-Host "Aborted." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "STEP 1: Checking current api_service.dart" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# Check if api_service.dart exists
if (Test-Path "lib\api\api_service.dart") {
    Write-Host "Current content:" -ForegroundColor Yellow
    Get-Content "lib\api\api_service.dart"
    Write-Host ""
    
    # Extract and show the API key
    $content = Get-Content "lib\api\api_service.dart" -Raw
    if ($content -match "apikey\s*=\s*'([^']+)'") {
        $apiKey = $matches[1]
        Write-Host "⚠️ FOUND EXPOSED API KEY: $apiKey" -ForegroundColor Red
        Write-Host ""
        Write-Host "ACTION REQUIRED:" -ForegroundColor Red
        Write-Host "1. Go to: https://console.cloud.google.com/apis/credentials" -ForegroundColor Red
        Write-Host "2. Find and DELETE this key: $apiKey" -ForegroundColor Red
        Write-Host "3. Create a NEW API key" -ForegroundColor Red
        Write-Host ""
        
        Read-Host "Press ENTER after you've revoked the key on Google Cloud Console"
    }
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "STEP 2: Removing file from Git tracking" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# Remove from git cache
Write-Host "Removing api_service.dart from git tracking..." -ForegroundColor Yellow
git rm --cached lib\api\api_service.dart 2>$null

# Verify it's in gitignore
Write-Host "Verifying .gitignore..." -ForegroundColor Yellow
$gitignore = Get-Content ".gitignore" -Raw
if ($gitignore -notmatch "lib/api/api_service.dart") {
    Write-Host "Adding to .gitignore..." -ForegroundColor Yellow
    Add-Content ".gitignore" "`nlib/api/api_service.dart"
}

Write-Host "✓ File will no longer be tracked by git" -ForegroundColor Green

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "STEP 3: Cleaning Git History (ADVANCED)" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

Write-Host "" 
Write-Host "⚠️ WARNING: The following steps will rewrite git history!" -ForegroundColor Red
Write-Host "This is PERMANENT and affects all team members." -ForegroundColor Red
Write-Host ""

$cleanHistory = Read-Host "Do you want to remove this file from ALL git history? (yes/no)"

if ($cleanHistory -eq "yes") {
    Write-Host ""
    Write-Host "Checking if git-filter-repo is installed..." -ForegroundColor Yellow
    
    # Check for git-filter-repo (better than filter-branch)
    $filterRepo = git filter-repo --version 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Using git-filter-repo (recommended)..." -ForegroundColor Green
        git filter-repo --path lib/api/api_service.dart --invert-paths --force
    } else {
        Write-Host "git-filter-repo not found. Using git filter-branch (slower)..." -ForegroundColor Yellow
        git filter-branch --force --index-filter "git rm --cached --ignore-unmatch lib/api/api_service.dart" --prune-empty --tag-name-filter cat -- --all
    }
    
    Write-Host ""
    Write-Host "✓ File removed from git history" -ForegroundColor Green
    Write-Host ""
    Write-Host "⚠️ You MUST force push to update the remote repository:" -ForegroundColor Red
    Write-Host "   git push origin --force --all" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠️ WARNING: Inform your team members to re-clone the repository!" -ForegroundColor Red
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "STEP 4: Setting up secure configuration" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file..." -ForegroundColor Yellow
    
    $newApiKey = Read-Host "Enter your NEW API key (or leave blank to set later)"
    
    if ($newApiKey) {
        "GEMINI_API_KEY=$newApiKey" | Out-File -FilePath ".env" -Encoding UTF8
        Write-Host "✓ Created .env file with your new key" -ForegroundColor Green
    } else {
        Copy-Item ".env.example" ".env"
        Write-Host "✓ Created .env file from template" -ForegroundColor Green
        Write-Host "  Remember to edit it and add your new API key!" -ForegroundColor Yellow
    }
} else {
    Write-Host ".env file already exists" -ForegroundColor Green
}

# Create api_service.dart from template if it doesn't exist
if (-not (Test-Path "lib\api\api_service.dart")) {
    Write-Host "Creating api_service.dart from template..." -ForegroundColor Yellow
    Copy-Item "lib\api\api_service.dart.example" "lib\api\api_service.dart"
    
    $newApiKey = Read-Host "Enter your NEW API key (or leave blank to set later)"
    if ($newApiKey) {
        (Get-Content "lib\api\api_service.dart") -replace 'YOUR_ACTUAL_API_KEY_HERE', $newApiKey | Set-Content "lib\api\api_service.dart"
        Write-Host "✓ Created api_service.dart with your new key" -ForegroundColor Green
    } else {
        Write-Host "✓ Created api_service.dart from template" -ForegroundColor Green
        Write-Host "  Remember to edit it and add your new API key!" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Cyan
Write-Host "STEP 5: Final verification" -ForegroundColor Cyan
Write-Host "==================================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Checking git status..." -ForegroundColor Yellow
git status

Write-Host ""
Write-Host "==================================================================" -ForegroundColor Green
Write-Host "✓ CLEANUP COMPLETE!" -ForegroundColor Green
Write-Host "==================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Verify your new API key works in the app" -ForegroundColor White
Write-Host "2. Commit the .gitignore changes:       git add .gitignore" -ForegroundColor White
Write-Host "3. Commit the new template files:        git add .env.example lib/api/api_service.dart.example SECURITY_GUIDE.md" -ForegroundColor White
Write-Host "4. Create commit:                        git commit -m 'Add API key security measures'" -ForegroundColor White
Write-Host "5. If you cleaned history, force push:   git push origin --force --all" -ForegroundColor White
Write-Host ""
Write-Host "⚠️ IMPORTANT: Monitor your Google Cloud Console for any unexpected API usage!" -ForegroundColor Red
Write-Host ""
