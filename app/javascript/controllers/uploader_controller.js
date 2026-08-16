import { Controller } from "@hotwired/stimulus"

// Drag-and-drop photo upload. Dropping files puts them on the real file input
// and submits the form, so the upload goes through the same validated endpoint
// as picking files by hand — there is no second, weaker path into the system.
export default class extends Controller {
  static targets = ["form", "input", "zone", "progress"]

  dragover(event) {
    event.preventDefault()
    this.zoneTarget.classList.add("border-accent", "bg-accent-soft")
  }

  dragleave(event) {
    event.preventDefault()
    this.resetZone()
  }

  drop(event) {
    event.preventDefault()
    this.resetZone()

    const files = Array.from(event.dataTransfer?.files || []).filter((file) =>
      file.type.startsWith("image/")
    )
    if (files.length === 0) return

    // DataTransfer is the supported way to assign a FileList programmatically.
    const transfer = new DataTransfer()
    files.forEach((file) => transfer.items.add(file))
    this.inputTarget.files = transfer.files

    this.submit()
  }

  submit() {
    if (!this.inputTarget.files || this.inputTarget.files.length === 0) return

    this.showProgress()
    this.element.requestSubmit()
  }

  showProgress() {
    if (this.hasProgressTarget) this.progressTarget.hidden = false
  }

  resetZone() {
    this.zoneTarget.classList.remove("border-accent", "bg-accent-soft")
  }
}
