import { Controller } from "@hotwired/stimulus"

// Enquiry form. Stamps the moment the form became usable (the server rejects
// submissions that arrive impossibly fast) and blocks the double-tap that would
// otherwise file the same enquiry twice on a slow connection.
export default class extends Controller {
  static targets = ["openedAt", "submit"]

  connect() {
    if (this.hasOpenedAtTarget) {
      this.openedAtTarget.value = Math.floor(Date.now() / 1000)
    }

    this.onSubmit = this.onSubmit.bind(this)
    this.element.addEventListener("submit", this.onSubmit)
  }

  disconnect() {
    this.element.removeEventListener("submit", this.onSubmit)
  }

  onSubmit() {
    if (!this.hasSubmitTarget) return

    // Turbo re-renders the page on the response, so this only needs to hold for
    // the round trip.
    this.submitTarget.disabled = true
    this.submitTarget.classList.add("opacity-70", "pointer-events-none")
  }
}
