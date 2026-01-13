# QuitLoL Browser Extension

A browser extension that blocks and hides all League of Legends content across the web.

## What It Does

- **Blocks YouTube videos** about League of Legends
- **Hides Twitch streams** playing League
- **Filters Reddit posts** from r/leagueoflegends and posts mentioning League
- **Removes Twitter/X posts** about League
- **Redirects** direct visits to League-related websites
- **Hides content** on Facebook, Instagram, TikTok with League keywords

## Installation

### Chrome / Edge / Brave

1. Download or clone this repository
2. Open Chrome and go to `chrome://extensions/`
3. Enable "Developer mode" (toggle in top right)
4. Click "Load unpacked"
5. Select the `browser-extension` folder
6. The extension is now active!

### Firefox

1. Download or clone this repository
2. Open Firefox and go to `about:debugging#/runtime/this-firefox`
3. Click "Load Temporary Add-on"
4. Navigate to the `browser-extension` folder and select `manifest.json`
5. The extension is now active!

**Note:** In Firefox, temporary extensions are removed when you close the browser. For permanent installation, you'll need to package and sign the extension.

## Icons (Optional)

**The extension works perfectly without custom icons.** Chrome/Firefox will just display a default extension icon.

If you want a custom icon, you can create PNG icons from the included `icons/icon.svg`:

### Online Tool (Easiest):
1. Go to https://cloudconvert.com/svg-to-png
2. Upload `icons/icon.svg`
3. Convert to PNG at these sizes:
   - 16x16 (save as `icon16.png`)
   - 48x48 (save as `icon48.png`)
   - 128x128 (save as `icon128.png`)
4. Place the PNG files in the `icons/` folder
5. Update `manifest.json` to reference the icons (see Git history for the icon config)

### Using ImageMagick (Command line):
```bash
convert -background none -resize 16x16 icons/icon.svg icons/icon16.png
convert -background none -resize 48x48 icons/icon.svg icons/icon48.png
convert -background none -resize 128x128 icons/icon.svg icons/icon128.png
```

## How It Works

### Content Detection
The extension scans web pages for League-related keywords including:
- "League of Legends", "LoL", "Riot Games"
- Champion names (Yasuo, Zed, Ahri, Jinx, etc.)
- Game modes (ARAM, Summoner's Rift)
- Esports (LCS, LEC, LCK, Worlds)
- Related games (Valorant, TFT, Wild Rift)

### Dynamic Blocking
- Uses MutationObserver to catch dynamically loaded content
- Runs checks every 2 seconds as a backup
- Blocks content before it fully loads (run_at: document_start)

### Site Redirects
Automatically redirects these sites to a Google search for "how to quit gaming addiction":
- leagueoflegends.com
- lolesports.com
- riotgames.com
- reddit.com/r/leagueoflegends

## Customization

### Add More Keywords
Edit `content.js` and add keywords to the `LEAGUE_KEYWORDS` array:

```javascript
const LEAGUE_KEYWORDS = [
  'league of legends',
  'your custom keyword',
  // ...
];
```

### Change Redirect Target
Edit `rules.json` and change the redirect URL:

```json
{
  "redirect": {
    "url": "https://your-custom-url.com"
  }
}
```

### Add More Sites to Block
1. Add the site pattern to `manifest.json` under `content_scripts.matches`
2. Add blocking logic in `content.js`

## Privacy

This extension:
- ✅ Works entirely locally (no data sent anywhere)
- ✅ No tracking or analytics
- ✅ No external connections
- ✅ Open source - check the code yourself

## Limitations

- **Not 100% foolproof**: Determined users can disable the extension
- **Keyword-based**: May miss some content or accidentally block unrelated content
- **Performance**: Continuous scanning uses some CPU/memory
- **Platform-specific**: Each website has different HTML structure that may change

## For Maximum Effectiveness

Combine this browser extension with:
1. The main QuitLoL system blocker (in parent directory)
2. Ask someone else to set your browser extension password
3. Use a separate browser profile for work/study without the extension disabled

## Development

To modify the extension:
1. Edit the files
2. Go to extensions page (`chrome://extensions`)
3. Click the refresh icon on the QuitLoL extension card
4. Test your changes

## Troubleshooting

**Extension not blocking content?**
- Make sure it's enabled in `chrome://extensions`
- Check that the site is listed in manifest.json
- Try refreshing the page
- Check browser console for errors (F12 → Console)

**Blocking too much content?**
- Edit the `LEAGUE_KEYWORDS` array in `content.js`
- Remove keywords that are too generic

**Firefox shows "This extension will be removed"?**
- This is normal for temporary extensions in Firefox
- Re-load it each time you restart Firefox, or package it properly

## License

Same as parent project (MIT)

## Contributing

Improvements welcome! Please test thoroughly before submitting PRs.
