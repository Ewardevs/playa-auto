import { Controller } from "@hotwired/stimulus"

// Records that a visitor opened WhatsApp from a vehicle, so the panel can
// report on the channel that actually converts.
//
// Fire-and-forget: the link opens immediately and never waits for this. sendBeacon
// survives the page being backgrounded, which is exactly what happens when
// WhatsApp takes over.
export default class extends Controller {
  static values = { url: String }

  record() {
    if (!this.urlValue) return

    const token = document.querySelector("meta[name=csrf-token]")?.content
    const body = new FormData()
    if (token) body.append("authenticity_token", token)

    try {
      if (navigator.sendBeacon) {
        navigator.sendBeacon(this.urlValue, body)
      } else {
        fetch(this.urlValue, { method: "POST", body, keepalive: true })
      }
    } catch (error) {
      // Tracking must never get in the way of the conversation.
      console.debug("[whatsapp-track]", error)
    }
  }
}
