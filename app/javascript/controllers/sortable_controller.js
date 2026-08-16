import { Controller } from "@hotwired/stimulus"

// Reordering by dragging, built on the native HTML5 drag events so the panel
// needs no drag-and-drop library.
//
// The new order is persisted immediately; if the request fails the page is
// reloaded so what is on screen matches what is stored.
export default class extends Controller {
  static targets = ["item"]
  static values = { url: String, enabled: Boolean }

  connect() {
    if (!this.enabledValue) return

    this.dragged = null
    this.element.addEventListener("dragstart", this.onDragStart)
    this.element.addEventListener("dragover", this.onDragOver)
    this.element.addEventListener("dragend", this.onDragEnd)
  }

  disconnect() {
    this.element.removeEventListener("dragstart", this.onDragStart)
    this.element.removeEventListener("dragover", this.onDragOver)
    this.element.removeEventListener("dragend", this.onDragEnd)
  }

  onDragStart = (event) => {
    const item = event.target.closest("[data-image-id]")
    if (!item) return

    this.dragged = item
    item.classList.add("opacity-40")
    event.dataTransfer.effectAllowed = "move"
    // Firefox will not start a drag without data on the transfer.
    event.dataTransfer.setData("text/plain", item.dataset.imageId)
  }

  onDragOver = (event) => {
    if (!this.dragged) return
    event.preventDefault()

    const target = event.target.closest("[data-image-id]")
    if (!target || target === this.dragged) return

    const items = [...this.element.querySelectorAll("[data-image-id]")]
    const draggedIndex = items.indexOf(this.dragged)
    const targetIndex = items.indexOf(target)

    if (draggedIndex < targetIndex) {
      target.after(this.dragged)
    } else {
      target.before(this.dragged)
    }
  }

  onDragEnd = () => {
    if (!this.dragged) return

    this.dragged.classList.remove("opacity-40")
    this.dragged = null
    this.persist()
  }

  async persist() {
    const ids = [...this.element.querySelectorAll("[data-image-id]")].map(
      (item) => item.dataset.imageId
    )

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          Accept: "text/vnd.turbo-stream.html, application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content
        },
        body: JSON.stringify({ ids })
      })

      if (!response.ok) throw new Error(`Reorder failed: ${response.status}`)
    } catch (error) {
      console.error("[sortable]", error)
      window.location.reload()
    }
  }
}
