/**
 * just use mercy builds for enabled modules and themes stuff
 */

// 1) all javascript stuff
import '../../storage/app/mercy-generated/modules-import'
import '../../storage/app/mercy-generated/themes-import'
// 2) module stylesheets, first sass then css
import '../../storage/app/mercy-generated/modules-import.scss'
import '../../storage/app/mercy-generated/modules-import.css'
// 3) theme stylesheets, first sass then css
import '../../storage/app/mercy-generated/themes-import.scss'
import '../../storage/app/mercy-generated/themes-import.css'


/**
 * Echo exposes an expressive API for subscribing to channels and listening
 * for events that are broadcast by Laravel. Echo and event broadcasting
 * allow your team to quickly build robust real-time web applications.
 */

import './echo';
