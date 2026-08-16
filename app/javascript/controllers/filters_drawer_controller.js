import { Controller } from "@hotwired/stimulus"

// Catalogue filters as a bottom drawer on mobile. The same form is a sidebar on
// desktop, so this only manages open/closed state on small screens.
export default class extends Controller {
  static targets = ["panel", "scrim"]

  connect() {
    this.onKeydown = (event) => {
      if (event.key === "Escape") this.close()
    }
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  open() {
    this.panelTarget.hidden = false
    this.scrimTarget.hidden = false
    document.body.classList.add("overflow-hidden")
    // Let the element paint hidden-to-visible before animating it in.
    requestAnimationFrame(() => this.panelTarget.classList.remove("translate-y-full"))
  }

  close() {
    this.panelTarget.classList.add("translate-y-full")
    this.scrimTarget.hidden = true
    document.body.classList.remove("overflow-hidden")
    setTimeout(() => { this.panelTarget.hidden = true }, 200)
  }
}
