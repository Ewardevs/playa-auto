import { Controller } from "@hotwired/stimulus"

// Menu that closes on outside click, on Escape and after an item is chosen.
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.onDocumentClick = (event) => {
      if (!this.element.contains(event.target)) this.close()
    }
    this.onKeydown = (event) => {
      if (event.key === "Escape") this.close()
    }

    document.addEventListener("click", this.onDocumentClick)
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("keydown", this.onKeydown)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.hidden ? this.open() : this.close()
  }

  open() {
    this.menuTarget.hidden = false
  }

  close() {
    if (this.hasMenuTarget) this.menuTarget.hidden = true
  }
}
