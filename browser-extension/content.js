// QuitLoL Content Blocker - Hides League of Legends content across the web
// This script detects and hides League-related content on various platforms

(function() {
  'use strict';

  // Enable debug mode (set to false to disable logging)
  const DEBUG = true;

  // Keywords to detect League content (case-insensitive)
  const LEAGUE_KEYWORDS = [
    // Core terms
    'league of legends',
    'leagueoflegends',
    'league', // Standalone "league" - matches most titles
    'lol esports',
    'riot games',
    'summoner',
    'summoners rift',
    'summoner\'s rift',
    'aram',
    'nexus',
    'pentakill',
    'teamfight tactics',
    'tft',
    'wild rift',

    // Esports leagues
    'lcs',
    'lec',
    'lck',
    'lpl',
    'worlds 2024',
    'worlds 2025',
    'worlds 2026',
    'msi',
    'league worlds',
    'lolesports',

    // Popular champions (top 50 most searched)
    'yasuo',
    'zed',
    'ahri',
    'jinx',
    'draven',
    'vayne',
    'thresh',
    'lee sin',
    'ekko',
    'katarina',
    'riven',
    'lux',
    'akali',
    'ezreal',
    'kayn',
    'jhin',
    'sylas',
    'irelia',
    'teemo',
    'master yi',
    'darius',
    'garen',
    'nasus',
    'vi',
    'caitlyn',
    'miss fortune',
    'ashe',
    'twisted fate',
    'blitzcrank',
    'senna',
    'aphelios',
    'viego',
    'gwen',
    'yone',
    'seraphine',
    'samira',
    'vex',
    'zeri',
    'renata',
    'belveth',
    'nilah',
    'ksante',
    'briar',
    'naafiri',
    'smolder',

    // Pro players & streamers (top names)
    'faker',
    'showmaker',
    'chovy',
    'caps',
    'rekkles',
    'doublelift',
    'bjergsen',
    'jensen',
    'perkz',
    'jankos',
    'theshy',
    'rookie',
    'uzi',
    'deft',
    'canyon',
    'nuguri',
    'keria',
    'gumayusi',
    'zeus lol',
    'oner lol',
    'bwipo',
    't1 faker',
    'gen g',
    'drx',
    'jdg',
    'edg',

    // Teams
    't1 lol',
    'team liquid lol',
    'cloud9 lol',
    'fnatic lol',
    'g2 esports lol',
    'tsm lol',
    '100 thieves lol',
    'flyquest',

    // Game terms
    'baron nashor',
    'dragon soul',
    'rift herald',
    'inhibitor',
    'turret dive',
    'gank',
    'jungle diff',
    'top diff',
    'mid diff',
    'bot diff',
    'sup diff',
    'ff15',
    'surrender at 15',
    'blue side',
    'red side',
    'ranked lol',
    'challenger lol',
    'grandmaster lol',
    'bronze to challenger',
    'iron to challenger',
    'unranked to challenger'
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

    // Debug: log what we're checking
    if (DEBUG && text.length > 0) {
      const found = keywords.filter(k => text.includes(k));
      if (found.length > 0) {
        console.log(`  -> Matched keywords: ${found.join(', ')}`);
      }
    }

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
    // Block ALL types of video thumbnails (home, search, sidebar, recommendations)
    const videoElements = document.querySelectorAll(
      'ytd-video-renderer, ytd-grid-video-renderer, ytd-compact-video-renderer, ytd-rich-item-renderer, ytd-playlist-video-renderer, ytd-movie-renderer, ytd-reel-item-renderer, ytd-playlist-panel-video-renderer, ytm-compact-video-renderer, ytm-video-with-context-renderer'
    );

    videoElements.forEach(video => {
      if (video.hasAttribute('data-quitlol-checked')) return;
      video.setAttribute('data-quitlol-checked', 'true');

      // Get title from multiple possible locations
      const titleElement = video.querySelector('#video-title, #video-title-link, a#video-title, .title, h3, h4');
      const channelElement = video.querySelector('#channel-name, .ytd-channel-name, #text, ytd-channel-name a, yt-formatted-string.ytd-channel-name');

      const title = titleElement?.textContent || titleElement?.getAttribute('title') || titleElement?.getAttribute('aria-label') || '';
      const channel = channelElement?.textContent || '';
      const href = titleElement?.href || '';

      if (containsLeagueKeyword(title) || containsLeagueKeyword(channel) || containsLeagueKeyword(href)) {
        video.style.display = 'none';
        blockedCount++;
      }
    });

    // Block Shorts
    const shortsElements = document.querySelectorAll('ytd-reel-item-renderer, ytd-short, ytm-reel-item-renderer');
    shortsElements.forEach(short => {
      if (short.hasAttribute('data-quitlol-checked')) return;
      short.setAttribute('data-quitlol-checked', 'true');

      const text = short.textContent || '';
      if (containsLeagueKeyword(text)) {
        short.style.display = 'none';
        blockedCount++;
      }
    });

    // Block the current video if watching (AGGRESSIVE)
    if (window.location.pathname.includes('/watch')) {
      // Multiple ways to get the video title
      const videoTitle =
        document.querySelector('h1.ytd-watch-metadata yt-formatted-string')?.textContent ||
        document.querySelector('h1.title yt-formatted-string')?.textContent ||
        document.querySelector('ytd-watch-metadata h1')?.textContent ||
        document.querySelector('.title.ytd-video-primary-info-renderer')?.textContent ||
        document.title ||
        '';

      const channelName =
        document.querySelector('ytd-channel-name a')?.textContent ||
        document.querySelector('#channel-name a')?.textContent ||
        document.querySelector('ytd-video-owner-renderer a')?.textContent ||
        '';

      // Debug logging
      if (DEBUG && (videoTitle || channelName)) {
        // Only log when we actually find content (to avoid spam)
        console.log('🚫 QuitLoL - Found watch page content:');
        console.log('  Video Title:', videoTitle);
        console.log('  Channel Name:', channelName);
        console.log('  Title contains League?', containsLeagueKeyword(videoTitle));
        console.log('  Channel contains League?', containsLeagueKeyword(channelName));
      }

      if (containsLeagueKeyword(videoTitle) || containsLeagueKeyword(channelName)) {
        if (DEBUG) {
          console.log('🚫 QuitLoL: BLOCKING YouTube video - League content detected!');
        }

        // Block the video player
        const player = document.querySelector('#movie_player, .html5-video-player, video');
        const primaryCol = document.querySelector('#primary');

        if (player && !player.hasAttribute('data-quitlol-blocked')) {
          player.setAttribute('data-quitlol-blocked', 'true');

          // Hide video player
          if (player.tagName === 'VIDEO') {
            player.pause();
            player.src = '';
          }
          player.style.display = 'none';

          // Show blocked overlay
          const overlay = createBlockedOverlay('This video contains League of Legends content');

          // Insert overlay where the player is
          const container = player.closest('#player-container, #player, .html5-video-container') || player.parentElement;
          if (container) {
            container.style.position = 'relative';
            container.insertBefore(overlay, container.firstChild);
          }

          document.title = '🚫 Blocked - QuitLoL';
        }

        // Also hide the entire primary column as backup
        if (primaryCol && !primaryCol.hasAttribute('data-quitlol-blocked')) {
          primaryCol.setAttribute('data-quitlol-blocked', 'true');
          primaryCol.style.opacity = '0.1';
          primaryCol.style.pointerEvents = 'none';
        }
      }
    }

    // Block on channel pages if it's a League channel
    if (window.location.pathname.includes('/channel') || window.location.pathname.includes('/@')) {
      const channelName = document.querySelector('ytd-channel-name yt-formatted-string, #channel-name')?.textContent || '';
      const channelTitle = document.querySelector('#channel-header ytd-channel-name')?.textContent || document.title || '';

      if (containsLeagueKeyword(channelName) || containsLeagueKeyword(channelTitle)) {
        const main = document.querySelector('ytd-page-manager, #page-manager');
        if (main && !main.hasAttribute('data-quitlol-blocked')) {
          main.setAttribute('data-quitlol-blocked', 'true');
          main.innerHTML = '';
          main.appendChild(createBlockedOverlay('This channel posts League of Legends content'));
          document.title = '🚫 Blocked - QuitLoL';
        }
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

  // Wait for page to be ready, then run blocker
  function init() {
    if (DEBUG) {
      console.log('🚫 QuitLoL: Extension loaded');
    }

    // Run initial block
    blockContent();

    // Set up mutation observer if document.body exists
    if (document.body) {
      const observer = new MutationObserver((mutations) => {
        blockContent();
      });

      observer.observe(document.body, {
        childList: true,
        subtree: true
      });

      if (DEBUG) {
        console.log('🚫 QuitLoL: MutationObserver started');
      }
    } else {
      if (DEBUG) {
        console.log('🚫 QuitLoL: document.body not ready, waiting...');
      }
      // If body doesn't exist yet, wait for it
      setTimeout(init, 100);
      return;
    }

    // Run periodically as backup (especially important for YouTube SPA navigation)
    setInterval(blockContent, 1000);

    // Log blocked content count
    if (blockedCount > 0) {
      console.log(`🚫 QuitLoL: Blocked ${blockedCount} League of Legends items`);
    }
  }

  // Start when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
