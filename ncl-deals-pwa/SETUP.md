# NCL Deals – Supabase Setup Guide
# ================================
# Follow these steps in order. Takes about 10 minutes.


## STEP 1 – Create a free Supabase project

1. Go to https://supabase.com and click "Start your project"
2. Sign in with GitHub (free, no credit card needed)
3. Click "New project"
4. Fill in:
   - Project name: ncl-deals
   - Database password: choose a strong password and SAVE IT
   - Region: West EU (Ireland) — closest to Newcastle
5. Click "Create new project" and wait ~2 minutes for it to spin up


## STEP 2 – Run the SQL setup

1. In your Supabase project, click "SQL Editor" in the left sidebar
2. Click "New query"
3. Open the file `supabase-setup.sql` (included in this folder)
4. Copy the entire contents and paste into the SQL editor
5. Click "Run" (or press Ctrl+Enter)
6. You should see "Success. No rows returned" — that's correct
7. Go to Table Editor to confirm the `deals` table has 14 rows of seed data


## STEP 3 – Create your admin user

1. In Supabase, go to Authentication > Users
2. Click "Add user" → "Create new user"
3. Enter your admin email and a strong password
4. Click "Create user"
5. That's it — this account is what you'll use to log into the Admin tab in the app


## STEP 4 – Get your API credentials

1. In Supabase, go to Settings > API (left sidebar)
2. Copy two values:
   - "Project URL" — looks like: https://xyzabcdef.supabase.co
   - "anon public" key — a long string starting with "eyJ..."
   (DO NOT use the "service_role" key — keep that secret)


## STEP 5 – Add credentials to the app

1. Open `index.html` in a text editor
2. Find these two lines near the top of the <script> section:
   
   const SUPABASE_URL = 'YOUR_SUPABASE_URL';
   const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';

3. Replace the placeholder values with your real credentials:

   const SUPABASE_URL = 'https://xyzabcdef.supabase.co';
   const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';

4. Save the file


## STEP 6 – Deploy the app

Free hosting options (pick one):

### Option A – Netlify (easiest, recommended)
1. Go to https://netlify.com and sign up free
2. Drag and drop the entire `ncl-deals-pwa` folder onto the Netlify dashboard
3. Your app is live instantly at a URL like: https://random-name.netlify.app
4. Optional: go to Site settings > Domain to set a custom domain

### Option B – Vercel
1. Go to https://vercel.com and sign up
2. Install Vercel CLI: npm i -g vercel
3. Run `vercel` inside the ncl-deals-pwa folder
4. Follow the prompts

### Option C – GitHub Pages
1. Create a GitHub repository
2. Push the ncl-deals-pwa folder contents to the repo
3. Go to repo Settings > Pages > Deploy from branch > main
4. Your app is live at: https://yourusername.github.io/repo-name


## STEP 7 – Test everything

1. Open the live app URL
2. Check deals load on the home screen
3. Tap the "Submit" tab — submit a test deal
4. Tap the "Admin" tab — sign in with your admin email/password
5. You should see the pending submission — approve it
6. Check it appears in the live deals list


## HOW THE SYSTEM WORKS

Student / public view:
  - Deals are fetched live from Supabase every time the page loads
  - If Supabase is unreachable, the app shows cached fallback data

Submit tab (anyone can use):
  - Venues or promoters fill in the form
  - Their submission goes to the `submissions` table with status "pending"
  - They never touch the live `deals` table directly

Admin tab (you only):
  - Log in with your Supabase email/password
  - See a badge showing how many deals are waiting for review
  - Approve → deal goes live instantly
  - Reject → submission is discarded
  - Add, edit, or delete any live deal directly

Security:
  - Supabase Row Level Security ensures only authenticated admins
    can write to the deals table
  - The anon key is safe to include in the app — it can only
    read active deals and insert submissions
  - Your admin password never touches the app's HTML


## KEEPING DEALS CURRENT

Set a reminder once a week to:
1. Check the Admin tab for new submissions from venues
2. Check venues' Instagram/Facebook for deal changes
3. Use the Admin > Edit button to update prices or times


## NEED HELP?

Supabase docs:  https://supabase.com/docs
Netlify docs:   https://docs.netlify.com
