Step-by-Step Workflow for GitHub Pages Project Site
1️⃣ Create the local repo

If your project folder isn’t already a Git repository:

cd /path/to/project
git init               # initialize repo
git branch -m main     # rename default branch to main

2️⃣ Configure Git user identity (first-time only)
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

3️⃣ Stage and commit your files
git add .
git commit -m "Initial commit: Project site"

4️⃣ Create the remote repo on GitHub

Go to GitHub → New repository

Name: project-name (example: htgaa2026)

Owner: your GitHub account

Public

❌ Do NOT initialize with README, .gitignore, or license

Click Create repository

5️⃣ Connect local repo to GitHub
git remote add origin https://github.com/username/project-name.git
git remote -v   # confirm remote

6️⃣ Push files to GitHub using Personal Access Token (PAT)

GitHub no longer accepts passwords; use a PAT instead:

git push -u origin main


Username: GitHub username

Password: PAT generated from GitHub → Settings → Developer settings → Personal access tokens

7️⃣ Enable GitHub Pages

Go to repo → Settings → Pages

Source:

Branch: main

Folder: / (root)

Save → GitHub shows the site URL

https://username.github.io/project-name/

8️⃣ Fix paths for a project site

Since project sites live under a subpath (/project-name/), absolute paths starting with / break:

❌ /css/style.css → breaks

✅ css/style.css → works

Update all HTML, CSS, JS, and image paths to relative paths.

9️⃣ Optional: Test locally
python3 -m http.server 8000


Open http://localhost:8000/ to check that all assets and pages load correctly before pushing.

10️⃣ Repeatable workflow for updates

Whenever you change something:

git add .
git commit -m "Describe changes"
git push


GitHub Pages auto-deploys within ~1 minute

✅ Result: Your project site is live at:

https://username.github.io/project-name/
