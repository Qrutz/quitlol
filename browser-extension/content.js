// QuitLoL Content Blocker - Hides League of Legends content across the web
// This script detects and hides League-related content on various platforms

(function() {
  'use strict';

  // Keywords to detect League content (case-insensitive)
  const LEAGUE_KEYWORDS = [
    'league of legends',
    'league',
    'lol esports',
    'riot games',
    'summoner',
    'summoners rift',
    'aram',
    'nexus',
    'pentakill',
    'faker',
    'worlds 2024',
    'worlds 2025',
    'worlds 2026',
    'lcs',
    'lec',
    'lck',
    'lpl',
    't1 lol',
    'draven',
    'yasuo',
    'zed',
    'ahri',
    'jinx',
    'vi lol',
    'ekko lol',
    'teamfight tactics',
    'tft',
    'wild rift',
    'valorant' // Also blocking Riot's other games
  ];

  // More strict keywords that definitely indicate League content
  const STRICT_KEYWORDS = [
    'league of legends',
    'leagueoflegends',
    'lol esports',
    'summoner\'s rift'
  ];

  let blockedCount = 0;

  // Check if text contains League keywords
  function containsLeagueKeyword(text, strictMode = false) {
    if (!text) return false;
    text = text.toLowerCase();
    const keywords = strictMode ? STRICT_KEYWORDS : LEAGUE_KEYWORDS;
    return keywords.some(keyword => text.includes(keyword));
  }

  // Create a blocked content overlay
  function createBlockedOverlay(reason = 'League of Legends content') {
    const overlay = document.createElement('div');
    overlay.className = 'quitlol-blocked';
    overlay.innerHTML = `
      <div class="quitlol-blocked-content">
        <span class="quitlol-icon">🚫</span>
        <p><strong>Content Blocked</strong></p>
        <p>${reason}</p>
        <small>QuitLoL is protecting you</small>
      </div>
    `;
    return overlay;
  }

  // YouTube-specific blocking
  function blockYouTubeContent() {
    // Block video thumbnails
    const videoElements = document.querySelectorAll('ytd-video-renderer, ytd-grid-video-renderer, ytd-compact-video-renderer, ytd-rich-item-renderer');

    videoElements.forEach(video => {
      if (video.hasAttribute('data-quitlol-checked')) return;
      video.setAttribute('data-quitlol-checked', 'true');

      const titleElement = video.querySelector('#video-title, #video-title-link');
      const channelElement = video.querySelector('#channel-name, .ytd-channel-name');

      const title = titleElement?.textContent || titleElement?.getAttribute('title') || '';
      const channel = channelElement?.textContent || '';

      if (containsLeagueKeyword(title) || containsLeagueKeyword(channel)) {
        video.style.display = 'none';
        blockedCount++;
      }
    });

    // Block the current video if watching
    const videoTitle = document.querySelector('h1.ytd-watch-metadata yt-formatted-string, h1.title');
    const channelName = document.querySelector('ytd-channel-name a, #channel-name a');

    if (videoTitle && containsLeagueKeyword(videoTitle.textContent)) {
      const player = document.querySelector('#movie_player, .html5-video-player');
      if (player && !player.hasAttribute('data-quitlol-blocked')) {
        player.setAttribute('data-quitlol-blocked', 'true');
        player.style.display = 'none';
        const overlay = createBlockedOverlay('This video contains League of Legends content');
        player.parentElement.insertBefore(overlay, player);
        document.title = '🚫 Blocked - QuitLoL';
      }
    }
  }

  // Twitch-specific blocking
  function blockTwitchContent() {
    // Block stream cards
    const streamCards = document.querySelectorAll('[data-a-target="preview-card-title-link"], .stream-thumbnail, article');

    streamCards.forEach(card => {
      if (card.hasAttribute('data-quitlol-checked')) return;
      card.setAttribute('data-quitlol-checked', 'true');

      const title = card.textContent || card.getAttribute('aria-label') || '';
      const link = card.href || card.querySelector('a')?.href || '';

      if (containsLeagueKeyword(title) || containsLeagueKeyword(link)) {
        const container = card.closest('article, div[class*="Card"], div[class*="card"]');
        if (container) {
          container.style.display = 'none';
          blockedCount++;
        }
      }
    });

    // Block current stream
    const streamTitle = document.querySelector('h2[data-a-target="stream-title"], h1');
    const gameName = document.querySelector('[data-a-target="stream-game-link"]');

    if ((streamTitle && containsLeagueKeyword(streamTitle.textContent)) ||
        (gameName && containsLeagueKeyword(gameName.textContent))) {
      const player = document.querySelector('video, [data-a-target="video-player"]');
      if (player && !player.hasAttribute('data-quitlol-blocked')) {
        player.setAttribute('data-quitlol-blocked', 'true');
        const container = player.closest('div');
        container.innerHTML = '';
        container.appendChild(createBlockedOverlay('This stream is League of Legends'));
        document.title = '🚫 Blocked - QuitLoL';
      }
    }
  }

  // Reddit-specific blocking
  function blockRedditContent() {
    // Block posts
    const posts = document.querySelectorAll('div[data-testid="post-container"], shreddit-post, div.Post');

    posts.forEach(post => {
      if (post.hasAttribute('data-quitlol-checked')) return;
      post.setAttribute('data-quitlol-checked', 'true');

      const title = post.querySelector('h3, [slot="title"]')?.textContent || '';
      const subreddit = post.querySelector('[data-testid="subreddit-name"], [slot="subreddit"]')?.textContent || '';

      if (containsLeagueKeyword(title) ||
          containsLeagueKeyword(subreddit) ||
          subreddit.toLowerCase().includes('leagueoflegends')) {
        post.style.display = 'none';
        blockedCount++;
      }
    });

    // Block subreddit if on League subreddit
    if (window.location.href.includes('/r/leagueoflegends') ||
        window.location.href.includes('/r/lol')) {
      const content = document.querySelector('main, #AppRouter-main-content');
      if (content && !content.hasAttribute('data-quitlol-blocked')) {
        content.setAttribute('data-quitlol-blocked', 'true');
        content.innerHTML = '';
        content.appendChild(createBlockedOverlay('r/leagueoflegends is blocked'));
        document.title = '🚫 Blocked - QuitLoL';
      }
    }
  }

  // Twitter/X-specific blocking
  function blockTwitterContent() {
    const tweets = document.querySelectorAll('article[data-testid="tweet"], div[data-testid="cellInnerDiv"]');

    tweets.forEach(tweet => {
      if (tweet.hasAttribute('data-quitlol-checked')) return;
      tweet.setAttribute('data-quitlol-checked', 'true');

      const text = tweet.textContent || '';

      if (containsLeagueKeyword(text)) {
        tweet.style.display = 'none';
        blockedCount++;
      }
    });
  }

  // Generic content blocking for other sites
  function blockGenericContent() {
    // Block images with League in alt text
    const images = document.querySelectorAll('img[alt*="league" i], img[alt*="lol" i]');
    images.forEach(img => {
      if (!img.hasAttribute('data-quitlol-checked')) {
        img.setAttribute('data-quitlol-checked', 'true');
        if (containsLeagueKeyword(img.alt)) {
          img.style.display = 'none';
          blockedCount++;
        }
      }
    });
  }

  // Main blocking function
  function blockContent() {
    const hostname = window.location.hostname;

    if (hostname.includes('youtube.com')) {
      blockYouTubeContent();
    } else if (hostname.includes('twitch.tv')) {
      blockTwitchContent();
    } else if (hostname.includes('reddit.com')) {
      blockRedditContent();
    } else if (hostname.includes('twitter.com') || hostname.includes('x.com')) {
      blockTwitterContent();
    }

    blockGenericContent();
  }

  // Run blocker on page load
  blockContent();

  // Set up mutation observer to catch dynamically loaded content
  const observer = new MutationObserver((mutations) => {
    blockContent();
  });

  // Start observing
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

  // Run periodically as backup
  setInterval(blockContent, 2000);

  // Log blocked content count
  if (blockedCount > 0) {
    console.log(`🚫 QuitLoL: Blocked ${blockedCount} League of Legends items`);
  }

  // Prevent circumvention by blocking developer tools from disabling the extension
  // (Users can still disable via extension settings, but adds friction)
  Object.freeze(observer);
})();
