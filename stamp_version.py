# This script runs automatically on every Netlify deploy.
# It stamps sw.js with a unique timestamp so all students
# get the new version without doing anything.
import datetime, re

version = f"ncl-deals-{datetime.datetime.now().strftime('%Y%m%d%H%M%S')}"

with open('sw.js', 'r') as f:
    sw = f.read()

sw = re.sub(r'const VERSION = "ncl-deals-[^"]+";', f'const VERSION = "{version}";', sw)

with open('sw.js', 'w') as f:
    f.write(sw)

print(f"✓ Service worker version stamped: {version}")
