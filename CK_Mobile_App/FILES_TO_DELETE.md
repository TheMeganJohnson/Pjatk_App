# Files to DELETE before deploying to Render

## From myproject/ directory:
- test_direct_connection.py (testing only)
- test_api.py (testing only) 
- setup_database.py (we use manual_setup.py instead)
- generate_secret_key.py (we already have the key)
- build.sh (Render uses its own build process)
- Procfile (Render doesn't use this)
- runtime.txt (Render manages Python version)
- DEPLOYMENT_GUIDE.md (we have specific RENDER_DEPLOYMENT.md)
- RENDER_DEPLOYMENT.md (duplicate, keep the one in root)

## From root CK_Mobile_App/ directory:
- MIGRATION_GUIDE.md (no longer needed)

## From myproject/mysql_compat/ directory:
- This entire directory (our current approach works without it)

## Keep these files:
✓ requirements.txt (root)
✓ RENDER_DEPLOYMENT.md (root)
✓ DEPLOYMENT_CHECKLIST.md (root)
✓ myproject/manual_setup.py (critical for MySQL 5.5)
✓ myproject/.env (for local development)
✓ All Django project files in myproject/
