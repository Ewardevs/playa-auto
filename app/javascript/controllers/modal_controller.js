import { Controller } from "@hotwired/stimulus"

// Thin wrapper over the native <dialog>. Focus trapping, the backdrop and
// Escape-to-close come from the browser; this only opens it and lets other code
// open it by id.
export default class extends Controller {
  static targets = ["dialog"]
  static values = { id: String }

  connect() {
    this.onExternalOpen = (event) => {
      if (event.detail?.id === this.idValue) this.open()
    }
    document.addEventListener("modal:open", this.onExternalOpen)
  }

  disconnect() {
    document.removeEventListener("modal:open", this.onExternalOpen)
  }

  open(event) {
    event?.preventDefault()
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }
}
