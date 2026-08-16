import { Controller } from "@hotwired/stimulus"

// Removes its element, optionally after a delay. Used by flash toasts.
export default class extends Controller {
  static values = { delay: Number }

  connect() {
    if (this.delayValue > 0) {
      this.timeout = setTimeout(() => this.close(), this.delayValue)
    }
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  close() {
    this.element.remove()
  }
}
