#!/usr/bin/env bash
set -euo pipefail

CARD_FILE="src/components/Card.astro"
LAYOUT_FILE="src/layouts/BaseLayout.astro"
COMMIT_MSG="fix: MediaSession artwork for iOS lock screen media widget"

echo "Checking files exist..."
[[ -f "$CARD_FILE" ]]   || { echo "❌  $CARD_FILE not found."; exit 1; }
[[ -f "$LAYOUT_FILE" ]] || { echo "❌  $LAYOUT_FILE not found."; exit 1; }

echo "Copying album.jpg..."
mkdir -p public/images
echo "album.jpg already in place, skipping copy."
echo "Done."

echo "Patching MediaSession into $CARD_FILE..."
if grep -q "mediaSession" "$CARD_FILE"; then
  echo "MediaSession already present, skipping."
else
  python3 -c "
import sys, re
with open('$CARD_FILE') as f:
    src = f.read()
block = '''

        if (\"mediaSession\" in navigator) {
            navigator.mediaSession.metadata = new MediaMetadata({
                title:  tracks[index].title,
                artist: \"Ben Kappes\",
                album:  tracks[index].venue,
                artwork: [{ src: \"/images/album.jpg\", sizes: \"512x512\", type: \"image/jpeg\" }]
            });
        }
'''
patched = re.sub(r'(audio\.src\s*=\s*tracks\[index\]\.src\s*;)', r'\1' + block, src, count=1)
if patched == src:
    print('ERROR: anchor line not found')
    sys.exit(1)
with open('$CARD_FILE', 'w') as f:
    f.write(patched)
print('Patched.')
"
fi

echo "Checking title in $LAYOUT_FILE..."
if grep -q "Ben Kappes | Music" "$LAYOUT_FILE"; then
  echo "Title already correct."
else
  python3 -c "
import sys, re
with open('$LAYOUT_FILE') as f:
    src = f.read()
patched = re.sub(r'<title>.*?</title>', '<title>Ben Kappes | Music</title>', src, count=1, flags=re.DOTALL)
if patched == src:
    patched = re.sub(r'(<head[^>]*>)', r'\1\n  <title>Ben Kappes | Music</title>', src, count=1)
if patched == src:
    print('ERROR: no title or head tag found')
    sys.exit(1)
with open('$LAYOUT_FILE', 'w') as f:
    f.write(patched)
print('Title set.')
"
fi

echo "Committing and pushing..."
git add "$CARD_FILE" "$LAYOUT_FILE" public/images/album.jpg
if git diff --cached --quiet; then
  echo "Nothing new to commit."
else
  git commit -m "$COMMIT_MSG"
  git push
  echo "Pushed."
fi

echo "Done!"
