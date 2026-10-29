/**
 * just use mercy builds for enabled modules and themes stuff
 */

import '../../storage/app/mercy-generated/modules-import.js';
import '../../storage/app/mercy-generated/themes-import.js';
import '../../storage/app/mercy-generated/modules-import.css';
import '../../storage/app/mercy-generated/themes-import.css';

// import './sortable.js';
import Sortable from 'sortablejs';
window.Sortable = Sortable;

/**
 * Echo exposes an expressive API for subscribing to channels and listening
 * for events that are broadcast by Laravel. Echo and event broadcasting
 * allow your team to quickly build robust real-time web applications.
 */

import './echo';
