# SSH Key Setup for Automated Deployment

## SSH Key Generated

✅ **Key created**: `~/.ssh/accessilist_deploy` (ED25519)

### Public Key

Copy this public key to your AWS server:

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICXuHfv5soKLH87qdjZVWjJ2crYMMQH+J1ezFmayXpLM accessilist-deployment-a00288946@a00288946-C02ZPYXBMD6N
```

## Setup on AWS Server

### Step 1: Add Public Key to Server

SSH into your server and add the public key:

```bash
# SSH to server (you'll need password this one time)
ssh YOUR_USERNAME@webaim.org

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add the public key to authorized_keys
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICXuHfv5soKLH87qdjZVWjJ2crYMMQH+J1ezFmayXpLM accessilist-deployment-a00288946@a00288946-C02ZPYXBMD6N" >> ~/.ssh/authorized_keys

# Set proper permissions
chmod 600 ~/.ssh/authorized_keys

# Exit server
exit
```

### Step 2: Test SSH Connection

```bash
# Test connection (should NOT ask for password)
ssh -i ~/.ssh/accessilist_deploy YOUR_USERNAME@webaim.org

# If it works, you'll be logged in without entering a password
# Type 'exit' to logout
```

### Step 3: Configure SSH Config (Optional)

Add this to `~/.ssh/config` for easier connections:

```
Host webaim-deploy
  HostName webaim.org
  User YOUR_USERNAME
  IdentityFile ~/.ssh/accessilist_deploy
  IdentitiesOnly yes
```

Then you can connect with just:
```bash
ssh webaim-deploy
```

## Environment Variables

Set these in your local environment for automated scripts:

```bash
# Add to ~/.zshrc or ~/.bash_profile
export SSH_USER="YOUR_USERNAME"
export SSH_HOST="webaim.org"
export DEPLOY_PATH="/var/websites/webaim/htdocs/training/online/accessilist"
```

## Run Automated Migration

Once SSH key is set up on the server:

```bash
# Set environment variables (or update in script)
export SSH_USER="YOUR_USERNAME"

# Run migration script
./scripts/deployment/migrate-sessions-directory.sh
```

## Security Notes

- ✅ ED25519 key (modern, secure, fast)
- ✅ Key is deployment-specific (labeled clearly)
- ✅ Private key stored securely with 600 permissions
- ✅ No passphrase for automation (consider adding for extra security)
- ⚠️  Never commit private key to git (already in .gitignore)
- ⚠️  Rotate keys periodically

## Troubleshooting

### Permission Denied

If you get "Permission denied (publickey)":
1. Verify public key is in server's `~/.ssh/authorized_keys`
2. Check permissions on server: `chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys`
3. Verify SSH service allows public key authentication

### Connection Refused

If connection is refused:
1. Check server firewall allows SSH (port 22)
2. Verify server hostname is correct
3. Check SSH service is running on server

### Key Not Found

If local key not found:
```bash
ls -la ~/.ssh/accessilist_deploy*
# Should show both private and public key files
```

## Next Steps

1. ✅ SSH key generated locally
2. ⏳ Add public key to AWS server (manual step above)
3. ⏳ Test SSH connection
4. ⏳ Run migration script
5. ⏳ Deploy code
6. ⏳ Verify production
