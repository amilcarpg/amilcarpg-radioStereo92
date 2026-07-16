(() => {
  'use strict';

  const DEFAULT_CONFIG = Object.freeze({
    primaryStreamUrl: 'https://sonic.globalstream.pro:10918/stream',
    fallbackStreamUrl: '',
    analyticsMeasurementId: '',
  });
  const config = { ...DEFAULT_CONFIG, ...(window.RADIO_CONFIG || {}) };
  const RETRY_DELAYS = [1000, 2000, 4000, 8000, 16000, 30000];
  const CONSENT_KEY = 'stereo92.analytics-consent';
  const LANGUAGE_KEY = 'stereo92.language';

  const translations = {
    es: {
      language: 'Idioma', tagline: 'MÁS RADIO', volume: 'Volumen', play: 'Reproducir', pause: 'Pausar',
      idle: 'Lista para reproducir', connecting: 'Conectando…', playing: 'En vivo', paused: 'Reproducción pausada', retrying: 'Reconectando…', failed: 'No se pudo conectar',
      timerTitle: 'Temporizador de apagado', timerConfigure: 'Configurar temporizador de apagado', timerCancel: 'Cancelar temporizador', accept: 'Aceptar',
      privacy: 'Privacidad', privacyTitle: 'Ayúdanos a mejorar', privacyMessage: 'Con tu permiso, recopilamos datos anónimos de estabilidad y uso para detectar fallos. La radio funciona igual si no aceptas.', privacyAccept: 'Aceptar', privacyDecline: 'Ahora no',
      timerActive: (time) => `Apagado en ${time}`, timerFinished: 'La reproducción se detuvo al finalizar el temporizador.', minutes: (count) => `${count} minutos`,
    },
    en: {
      language: 'Language', tagline: 'MORE RADIO', volume: 'Volume', play: 'Play', pause: 'Pause',
      idle: 'Ready to play', connecting: 'Connecting…', playing: 'Live', paused: 'Playback paused', retrying: 'Reconnecting…', failed: 'Could not connect',
      timerTitle: 'Sleep timer', timerConfigure: 'Set sleep timer', timerCancel: 'Cancel timer', accept: 'Confirm',
      privacy: 'Privacy', privacyTitle: 'Help us improve', privacyMessage: 'With your permission, we collect anonymous stability and usage data to detect failures. The radio works the same if you do not accept.', privacyAccept: 'Accept', privacyDecline: 'Not now',
      timerActive: (time) => `Stopping in ${time}`, timerFinished: 'Playback stopped when the timer ended.', minutes: (count) => `${count} minutes`,
    },
    pt: {
      language: 'Idioma', tagline: 'MAIS RÁDIO', volume: 'Volume', play: 'Reproduzir', pause: 'Pausar',
      idle: 'Pronto para reproduzir', connecting: 'Conectando…', playing: 'Ao vivo', paused: 'Reprodução pausada', retrying: 'Reconectando…', failed: 'Não foi possível conectar',
      timerTitle: 'Temporizador', timerConfigure: 'Configurar temporizador', timerCancel: 'Cancelar temporizador', accept: 'Aceitar',
      privacy: 'Privacidade', privacyTitle: 'Ajude-nos a melhorar', privacyMessage: 'Com sua permissão, coletamos dados anônimos de estabilidade e uso para detectar falhas. O rádio funciona igual se você não aceitar.', privacyAccept: 'Aceitar', privacyDecline: 'Agora não',
      timerActive: (time) => `Desligamento em ${time}`, timerFinished: 'A reprodução foi interrompida ao finalizar o temporizador.', minutes: (count) => `${count} minutos`,
    },
    fr: {
      language: 'Langue', tagline: 'PLUS DE RADIO', volume: 'Volume', play: 'Lire', pause: 'Pause',
      idle: 'Prêt à lire', connecting: 'Connexion…', playing: 'En direct', paused: 'Lecture en pause', retrying: 'Nouvelle tentative…', failed: 'Connexion impossible',
      timerTitle: 'Minuterie d’arrêt', timerConfigure: 'Configurer la minuterie', timerCancel: 'Annuler la minuterie', accept: 'Valider',
      privacy: 'Confidentialité', privacyTitle: 'Aidez-nous à nous améliorer', privacyMessage: 'Avec votre autorisation, nous collectons des données anonymes de stabilité et d’utilisation. La radio fonctionne de la même façon si vous refusez.', privacyAccept: 'Accepter', privacyDecline: 'Pas maintenant',
      timerActive: (time) => `Arrêt dans ${time}`, timerFinished: 'La lecture s’est arrêtée à la fin de la minuterie.', minutes: (count) => `${count} minutes`,
    },
  };

  const elements = {
    audio: document.querySelector('#radio-audio'), status: document.querySelector('#status'), playButton: document.querySelector('#play-button'),
    playIcon: document.querySelector('#play-icon'), playLabel: document.querySelector('#play-label'), volume: document.querySelector('#volume'), volumeValue: document.querySelector('#volume-value'),
    timerSelect: document.querySelector('#timer-select'), timerStart: document.querySelector('#timer-start'), timerCancel: document.querySelector('#timer-cancel'), timerControls: document.querySelector('#timer-controls'), timerActive: document.querySelector('#timer-active'), timerRemaining: document.querySelector('#timer-remaining'),
    language: document.querySelector('#language-select'), privacy: document.querySelector('#privacy-button'), consentDialog: document.querySelector('#consent-dialog'),
  };

  let language = getInitialLanguage();
  let status = 'idle';
  let wantsToPlay = false;
  let retryTimer = null;
  let retryAttempt = 0;
  let currentCandidate = 0;
  let timerDeadline = null;
  let timerTicker = null;
  let analyticsLoaded = false;

  function getInitialLanguage() {
    const stored = localStorage.getItem(LANGUAGE_KEY);
    if (translations[stored]) return stored;
    const browserLanguage = (navigator.language || 'es').slice(0, 2).toLowerCase();
    return translations[browserLanguage] ? browserLanguage : 'es';
  }

  function t(key, ...args) {
    const value = translations[language][key] ?? translations.es[key] ?? key;
    return typeof value === 'function' ? value(...args) : value;
  }

  function applyLanguage() {
    document.documentElement.lang = language;
    document.title = 'Radio Stereo 92';
    elements.language.value = language;
    document.querySelectorAll('[data-i18n]').forEach((node) => { node.textContent = t(node.dataset.i18n); });
    document.querySelectorAll('[data-i18n-aria]').forEach((node) => {
      const value = t(node.dataset.i18nAria);
      node.setAttribute('aria-label', value);
      node.setAttribute('title', value);
    });
    document.querySelectorAll('#timer-select option').forEach((option) => { option.textContent = t('minutes', Number(option.value)); });
    renderStatus();
    updateTimerDisplay();
  }

  function renderStatus() {
    elements.status.textContent = t(status);
    elements.status.dataset.state = status === 'failed' ? 'error' : '';
    const isPlaying = status === 'playing' || wantsToPlay;
    elements.playButton.disabled = status === 'connecting';
    elements.playButton.setAttribute('aria-pressed', String(isPlaying));
    elements.playButton.setAttribute('aria-label', isPlaying ? t('pause') : t('play'));
    elements.playLabel.textContent = isPlaying ? t('pause') : t('play');
    elements.playIcon.textContent = isPlaying ? 'Ⅱ' : status === 'failed' ? '↻' : '▶';
  }

  function setStatus(next) {
    status = next;
    renderStatus();
  }

  function streamCandidates() {
    return [config.primaryStreamUrl, config.fallbackStreamUrl]
      .map((url) => String(url || '').trim())
      .filter((url, index, all) => url.startsWith('https://') && all.indexOf(url) === index);
  }

  async function startPlayback() {
    wantsToPlay = true;
    clearRetry();
    if (elements.audio.src && elements.audio.paused === false) return;
    await loadAndPlay();
  }

  async function loadAndPlay() {
    const candidates = streamCandidates();
    if (!wantsToPlay || candidates.length === 0) {
      setStatus('failed');
      return;
    }
    if (currentCandidate >= candidates.length) currentCandidate = 0;
    setStatus(retryAttempt ? 'retrying' : 'connecting');
    elements.audio.src = candidates[currentCandidate];
    elements.audio.load();
    try {
      await elements.audio.play();
    } catch (error) {
      handlePlaybackError(error);
    }
  }

  function pausePlayback({ fromTimer = false } = {}) {
    wantsToPlay = false;
    clearRetry();
    elements.audio.pause();
    setStatus('paused');
    if (fromTimer) {
      setStatus('paused');
      announce(t('timerFinished'));
      logEvent('timer_finished');
    } else {
      logEvent('playback_paused');
    }
  }

  function handlePlaybackError(error) {
    if (!wantsToPlay) return;
    logEvent('playback_error', { reason: error?.name || 'audio_error' });
    scheduleRetry();
  }

  function scheduleRetry() {
    clearRetry();
    const candidates = streamCandidates();
    if (candidates.length > 1) currentCandidate = (currentCandidate + 1) % candidates.length;
    const delay = RETRY_DELAYS[Math.min(retryAttempt, RETRY_DELAYS.length - 1)];
    retryAttempt += 1;
    setStatus('retrying');
    logEvent('retry_started', { attempt: retryAttempt, delay_seconds: delay / 1000 });
    retryTimer = window.setTimeout(() => { retryTimer = null; loadAndPlay(); }, delay);
  }

  function clearRetry() {
    if (retryTimer !== null) window.clearTimeout(retryTimer);
    retryTimer = null;
  }

  function setVolume() {
    const value = Number(elements.volume.value) / 100;
    elements.audio.volume = value;
    elements.volumeValue.textContent = `${Math.round(value * 100)}%`;
  }

  function setTimer() {
    const minutes = Number(elements.timerSelect.value);
    timerDeadline = Date.now() + minutes * 60 * 1000;
    if (timerTicker !== null) window.clearInterval(timerTicker);
    timerTicker = window.setInterval(updateTimerDisplay, 1000);
    elements.timerControls.hidden = true;
    elements.timerActive.hidden = false;
    updateTimerDisplay();
    logEvent('timer_set', { minutes });
  }

  function cancelTimer({ log = true } = {}) {
    if (timerTicker !== null) window.clearInterval(timerTicker);
    timerTicker = null;
    timerDeadline = null;
    elements.timerControls.hidden = false;
    elements.timerActive.hidden = true;
    if (log) logEvent('timer_cancelled');
  }

  function updateTimerDisplay() {
    if (!timerDeadline) return;
    const remaining = timerDeadline - Date.now();
    if (remaining <= 0) {
      cancelTimer({ log: false });
      pausePlayback({ fromTimer: true });
      return;
    }
    const seconds = Math.ceil(remaining / 1000);
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    const formatted = hours > 0
      ? `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`
      : `${String(minutes).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
    elements.timerRemaining.textContent = t('timerActive', formatted);
  }

  function announce(message) {
    elements.status.textContent = message;
  }

  function setMediaSession() {
    if (!('mediaSession' in navigator)) return;
    navigator.mediaSession.metadata = new MediaMetadata({
      title: 'Stereo 92 FM', artist: 'MÁS RADIO', artwork: [{ src: 'assets/stereo92.png', sizes: '512x512', type: 'image/png' }],
    });
    navigator.mediaSession.setActionHandler('play', () => startPlayback());
    navigator.mediaSession.setActionHandler('pause', () => pausePlayback());
    navigator.mediaSession.setActionHandler('stop', () => pausePlayback());
  }

  function getConsent() { return localStorage.getItem(CONSENT_KEY); }

  function handleConsent(choice) {
    localStorage.setItem(CONSENT_KEY, choice);
    if (choice === 'accepted') enableAnalytics();
    else disableAnalytics();
  }

  function enableAnalytics() {
    const id = String(config.analyticsMeasurementId || '').trim();
    if (!id || analyticsLoaded) return;
    window[`ga-disable-${id}`] = false;
    window.dataLayer = window.dataLayer || [];
    window.gtag = function gtag() { window.dataLayer.push(arguments); };
    const script = document.createElement('script');
    script.async = true;
    script.src = `https://www.googletagmanager.com/gtag/js?id=${encodeURIComponent(id)}`;
    script.onload = () => {
      analyticsLoaded = true;
      window.gtag('js', new Date());
      window.gtag('consent', 'default', { analytics_storage: 'granted', ad_storage: 'denied', ad_user_data: 'denied', ad_personalization: 'denied' });
      window.gtag('config', id, { anonymize_ip: true });
    };
    document.head.append(script);
  }

  function disableAnalytics() {
    const id = String(config.analyticsMeasurementId || '').trim();
    if (id) window[`ga-disable-${id}`] = true;
    document.cookie.split(';').forEach((cookie) => {
      const name = cookie.split('=')[0].trim();
      if (name === '_ga' || name.startsWith('_ga_')) {
        document.cookie = `${name}=; Max-Age=0; path=/; SameSite=Lax`;
      }
    });
  }

  function logEvent(name, params = {}) {
    if (getConsent() === 'accepted' && analyticsLoaded && typeof window.gtag === 'function') {
      window.gtag('event', name, params);
    }
  }

  function setupEvents() {
    elements.playButton.addEventListener('click', () => { wantsToPlay ? pausePlayback() : startPlayback(); });
    elements.volume.addEventListener('input', setVolume);
    elements.timerStart.addEventListener('click', setTimer);
    elements.timerCancel.addEventListener('click', () => cancelTimer());
    elements.language.addEventListener('change', () => { language = elements.language.value; localStorage.setItem(LANGUAGE_KEY, language); applyLanguage(); });
    elements.privacy.addEventListener('click', () => elements.consentDialog.showModal());
    elements.consentDialog.addEventListener('close', () => handleConsent(elements.consentDialog.returnValue === 'accepted' ? 'accepted' : 'declined'));
    elements.consentDialog.addEventListener('cancel', (event) => event.preventDefault());
    elements.audio.addEventListener('playing', () => { retryAttempt = 0; setStatus('playing'); logEvent('playback_started'); });
    elements.audio.addEventListener('pause', () => { if (!wantsToPlay && status !== 'paused') setStatus('paused'); });
    elements.audio.addEventListener('error', () => handlePlaybackError(elements.audio.error));
    window.addEventListener('online', () => { if (wantsToPlay && (status === 'retrying' || status === 'failed')) { clearRetry(); loadAndPlay(); } });
  }

  function registerServiceWorker() {
    if ('serviceWorker' in navigator) window.addEventListener('load', () => navigator.serviceWorker.register('service-worker.js').catch(() => {}));
  }

  applyLanguage();
  setVolume();
  setMediaSession();
  setupEvents();
  registerServiceWorker();
  if (getConsent() === 'accepted') enableAnalytics();
  if (getConsent() === null) elements.consentDialog.showModal();
})();
