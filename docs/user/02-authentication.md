# Authentication & Account Management

Understand how to log in, secure your account, and manage your session in Jinbocho.

## Login

### Basic Login

1. Go to `https://jinbocho.onrender.com`
2. Enter your **email address**
3. Enter your **password**
4. Click **"Login"**

You'll be logged in and redirected to your library dashboard.

**Note**: Your email is case-insensitive (both `Alice@example.com` and `alice@example.com` work).

## What is a Session?

When you log in, Jinbocho creates a **session** for you:
- Your browser stores an **access token** (valid for 30 minutes)
- A **refresh token** is stored securely to extend your session
- The app automatically refreshes before you're logged out

**You don't need to do anything**—the app handles this behind the scenes.

## Session Timeout

If you're inactive for more than 30 minutes:
- Your access token expires
- The app automatically tries to refresh using your refresh token
- If successful, you stay logged in
- If refresh fails, you're logged out (usually after 7-14 days of inactivity)

**If you see "Please log in again"**:
- Click the link or navigate back to login
- Enter your credentials
- Your library loads where you left off (no data loss)

## Logging Out

### Manual Logout

1. Click your **user menu** (top-right icon or bottom-right on mobile)
2. Click **"Logout"**
3. You're logged out and returned to the login screen

### Automatic Logout

You're automatically logged out if:
- You close your browser entirely (not just the tab)
- You clear browser cookies/cache
- Your session expires after 14+ days

**Note**: Your data is always safe on our servers. Logging out only clears local session info.

## Password Reset

Forgot your password? No problem.

### Step 1: Go to Reset Page

On the login screen, click **"Forgot Password?"**

### Step 2: Enter Your Email

Type the email address associated with your Jinbocho account and click **"Send Reset Email"**.

### Step 3: Check Your Email

Look for an email from **support@jinbocho.io** with the subject **"Reset your Jinbocho password"**.

**Note**: Check your spam/junk folder if you don't see it in 5 minutes.

### Step 4: Click the Reset Link

The email contains a link. Click it to open the password reset page.

**Security note**: This link expires after **1 hour**. If it expires, repeat the process.

### Step 5: Set Your New Password

On the reset page:
1. Enter your new password (minimum 8 characters)
2. Confirm it
3. Click **"Set New Password"**

You'll see **"Password reset successfully"**. Return to login and use your new password.

## Password Requirements

Your password must:
- Be **at least 8 characters** long
- Contain at least one **uppercase letter** (A-Z)
- Contain at least one **lowercase letter** (a-z)
- Contain at least one **number** (0-9)
- Contain at least one **special character** (!@#$%^&*)

**Examples of valid passwords**:
- `MyLibrary2024!`
- `Jinbocho@ReadMore`
- `Books#Forever88`

## Changing Your Password

You can change your password anytime without logging out.

### Step 1: Go to Settings

1. Click **Settings** (gear icon)
2. Click **"Account"** or **"Security"**

### Step 2: Change Password

1. Enter your **current password**
2. Enter your **new password** (must meet requirements above)
3. Confirm the new password
4. Click **"Update Password"**

You'll see **"Password changed successfully"**.

**Note**: You'll stay logged in. Your new password takes effect immediately.

## Multi-Family Accounts (Future)

Currently, one email = one family. In the future, you may be able to:
- Manage multiple families with one email
- Switch between families in a dropdown
- Accept invites to different families

For now, if you need multiple families, create separate email addresses.

## Deleting Your Account

⚠️ **Permanent action**: Deleting your account cannot be undone.

### To Delete Your Account

1. Go to **Settings** → **"Account"**
2. Scroll to **"Danger Zone"**
3. Click **"Delete Account"**
4. You'll be asked to confirm (type your email to confirm)
5. All your data is immediately deleted

**What happens**:
- Your family account is removed
- All books, locations, notes are deleted
- All family members lose access
- **This cannot be reversed**

**If you want to leave without deleting**: Ask the family admin to remove you as a member.

## Security Best Practices

### 🔐 Password Security
- Never share your password with anyone (even family admins)
- Use a unique password you don't use elsewhere
- Consider a password manager (1Password, Bitwarden, LastPass)

### 🔒 Account Security
- Log out on shared computers before leaving
- Use HTTPS (the URL starts with `https://`, not `http://`)
- Enable two-factor authentication when available (coming soon)

### 👥 Family Member Invites
- Only invite people you trust
- Admin can remove members anytime
- Ask members to use strong passwords

### 📱 Device Safety
- Don't stay logged in on public WiFi for long
- Use a VPN if on public WiFi (optional but recommended)
- Clear browser cookies regularly if on a shared device

## Two-Factor Authentication (Coming Soon)

In a future release, you'll be able to enable 2FA:
- Login will require a code from an authenticator app (Google Authenticator, Authy)
- Adds extra security even if someone knows your password
- Optional feature (you can keep standard password login)

## Session on Multiple Devices

You can be logged in on multiple devices simultaneously:
- Same email, different devices
- Each device has its own access token
- Logging out on one device doesn't affect others

**Example**: You can be logged in on your phone and laptop at the same time.

## Troubleshooting

### "Invalid Email or Password"

This error means:
- The email is not registered, **OR**
- The password is wrong

Try:
1. Check your email spelling
2. Verify caps lock is off (password is case-sensitive)
3. Reset your password if you're unsure

### "Too Many Login Attempts"

You've tried to log in with a wrong password too many times. For security:
1. Wait 15 minutes
2. Try again

Or reset your password using **"Forgot Password?"** link.

### "Login Page Keeps Redirecting to Login"

Your session token may be corrupted. Try:
1. Clear browser cookies: **Settings** → **Clear browsing data** → **Cookies and site data**
2. Refresh the page
3. Log in again

### "Session Expired" Mid-Use

Your access token expired while you were using the app. Try:
1. Refresh the page (`Ctrl+R` or `Cmd+R`)
2. If prompted, log in again
3. Your data is still there

## Account Recovery

If you've lost access to your account:

### Lost Email Address

If you no longer have access to the email used to register:
1. Create a new Jinbocho account with a different email
2. Ask a family admin of your original account to add you as a new user to that family (workaround for now)

We're working on account recovery options. For urgent help, contact **support@jinbocho.io**.

### Locked Out Due to Forgotten Password + Lost Email

1. Contact **support@jinbocho.io**
2. Provide your family name and original email
3. We'll verify your identity and help you recover access

---

## Next Steps

- **Manage family members**: See **[User Management](09-user-management.md)**
- **Start using Jinbocho**: See **[Managing Your Library](03-managing-library.md)**
- **Troubleshooting**: See **[Troubleshooting](14-troubleshooting.md)**

**Questions?** Check the **[FAQ](13-faq.md)**.
