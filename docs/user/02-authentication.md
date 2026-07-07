# Authentication & Account Management

Understand how to log in, secure your account, manage your session, and belong to
more than one library in Jinbocho.

## Login

### Basic Login

1. Go to your Jinbocho instance's URL
2. Enter your **email address**
3. Enter your **password**
4. Click **"Login"**

You'll be logged in and redirected either to your library dashboard, or to the
**library picker** if you belong to more than one library — see
**[Belonging to Multiple Libraries](#belonging-to-multiple-libraries)** below.

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

Look for an email with the subject **"Reset your Jinbocho password"**.

**Note**: Check your spam/junk folder if you don't see it in 5 minutes.

!!! info "Self-hosted instances without email configured"
    If whoever manages your Jinbocho instance hasn't configured an email
    provider (SMTP), reset emails aren't actually sent — they're written to
    the auth-service logs instead. Ask them to check the logs for the reset
    link, or to configure SMTP so this works automatically going forward.

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

### Step 1: Go to Your Profile

Click your name or avatar (top-right corner) → **Profile**.

### Step 2: Change Password

1. Enter your **current password**
2. Enter your **new password** (must meet requirements above)
3. Confirm the new password
4. Click **"Update Password"**

You'll see **"Password changed successfully"**.

**Note**: You'll stay logged in. Your new password takes effect immediately.

## Belonging to Multiple Libraries

A single Jinbocho account (one email) can belong to **more than one library** —
for example your own library plus one a friend or partner invited you to — and
can hold a **different role in each** (say, Admin in your own library and Viewer
in someone else's).

### The Library Picker

If your account has zero or two-or-more **active** memberships, you land on the
**library picker** after login instead of going straight to a dashboard. It shows:

| Section | What it shows | What you can do |
|---------|----------------|------------------|
| **Your libraries** | Every library where your membership is active | Click **Enter** to open that library |
| **Pending invites** | Invitations sent to your email/account that you haven't answered yet | **Accept** to join, or **Decline** (confirmation required) |
| **Suspended** | Libraries where an Admin temporarily suspended your membership | Greyed out, no action — contact that library's Admin |

If you belong to **exactly one active library**, Jinbocho skips the picker
entirely and takes you straight to that library's dashboard.

### Switching Libraries Later

Once inside a library, a **library switcher** is available from the header — use
it to jump to another library you belong to, or to check for new pending invites,
without logging out.

### Accepting or Declining an Invite

1. Open the library picker (automatic after login, or via the header switcher)
2. Find the invite under **Pending invites**
3. Click **Accept** to join with the role the Admin assigned, or **Decline** to
   turn it down (you'll be asked to confirm)

### Roles Are Per-Library

Your role (**Admin**, **Editor**, or **Viewer**) is set independently for each
library you belong to. See **[User Management](09-user-management.md)** for what
each role can do.

## Deleting a Library

⚠️ **Permanent action**: Deleting a library cannot be undone, and it deletes the
login access of **every** member, not just the Admin who deletes it.

Only an **Admin** can delete a library, from **Settings → Danger Zone**.

### What Happens

1. You type the library's exact name and your password to confirm.
2. Jinbocho deletes the library's data in sequence: catalog data (books, locations,
   loans), then AI-related data (suggestion/dedup history, if the AI module is
   installed on your instance), then the library and every member account tied
   to it in the authentication service.
3. Each step is confirmed before moving to the next. **This is not instant or
   atomic** — if one step fails, Jinbocho tells you exactly which step failed
   (catalog, AI, or the final account/library step) so you can safely retry from
   there without redoing what already succeeded.
4. Once all steps complete, every member — including you — loses access
   immediately and permanently.

!!! danger "This cannot be reversed"
    There is no recycle bin or grace period. Make sure you have a
    **[full backup](08-export-import.md#backup-restore)** if you might ever
    want this data again.

**If you just want to leave without deleting the whole library**: ask another
Admin to remove you as a member instead (see **[User Management](09-user-management.md)**).
If you're the only Admin, promote another member to Admin first.

## Your Privacy: What Data We Keep and Your Rights

When you register, you're asked to accept the current **Privacy Policy** and
**Terms of Service** — this is recorded against your account (which version you
accepted, and when).

- Every member can read a summary of what data is stored and why, and how to
  reach out about it, under **Settings → Privacy & your data**.
- There is currently no self-service "export my personal data" button for
  individual members. If you want a copy of your data, ask your library's Admin
  to download a **[full backup](08-export-import.md#backup-restore)** (which
  includes the full member roster, books, loans and reading history), or contact
  **jinbochoapp@gmail.com** directly.
- To have your data removed, ask an Admin to remove you as a member, or to
  delete the whole library if you want everything gone (see above).

## Security Best Practices

### 🔐 Password Security
- Never share your password with anyone (even Admins)
- Use a unique password you don't use elsewhere
- Consider a password manager (1Password, Bitwarden, LastPass)

### 🔒 Account Security
- Log out on shared computers before leaving
- Use HTTPS (the URL starts with `https://`, not `http://`)

### 👥 Invites
- Only invite people you trust
- Admins can remove or suspend members anytime
- Ask members to use strong passwords

### 📱 Device Safety
- Don't stay logged in on public WiFi for long
- Use a VPN if on public WiFi (optional but recommended)
- Clear browser cookies regularly if on a shared device

## Session on Multiple Devices

You can be logged in on multiple devices simultaneously:
- Same email, different devices
- Each device has its own access token
- Logging out on one device does not affect others

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
2. Ask an Admin of your original library to invite that new account as a member (workaround for now)

We're working on account recovery options. For urgent help, contact **jinbochoapp@gmail.com**.

### Locked Out Due to Forgotten Password + Lost Email

1. Contact **jinbochoapp@gmail.com**
2. Provide your library name and original email
3. We'll verify your identity and help you recover access

---

## Next Steps

- **Manage members and roles**: See **[User Management](09-user-management.md)**
- **Start using Jinbocho**: See **[Managing Your Library](03-managing-library.md)**
- **Troubleshooting**: See **[Troubleshooting](14-troubleshooting.md)**

**Questions?** Check the **[FAQ](13-faq.md)**.
