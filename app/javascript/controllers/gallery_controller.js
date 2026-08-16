import { Controller } from "@hotwired/stimulus"

// Vehicle photo gallery. Swaps which frame is visible — no layout shift, and
// the images themselves are plain <img> tags the browser lazy-loads.
export default class extends Controller {
  static targets = ["frame", "thumb", "counter"]

  connect() {
    this.index = 0
    this.onKeydown = this.onKeydown.bind(this)
    this.element.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    this.element.removeEventListener("keydown", this.onKeydown)
  }

  select(event) {
    this.show(Number(event.currentTarget.dataset.index))
  }

  next() {
    this.show((this.index + 1) % this.frameTargets.length)
  }

  previous() {
    this.show((this.index - 1 + this.frameTargets.length) % this.frameTargets.length)
  }

  onKeydown(event) {
    if (event.key === "ArrowRight") this.next()
    if (event.key === "ArrowLeft") this.previous()
  }

  show(index) {
    if (Number.isNaN(index) || index === this.index) return

    this.index = index

    this.frameTargets.forEach((frame, i) => {
      frame.hidden = i !== index
    })

    this.thumbTargets.forEach((thumb, i) => {
      const active = i === index
      thumb.classList.toggle("border-brand", active)
      thumb.classList.toggle("border-transparent", !active)
      thumb.setAttribute("aria-selected", String(active))
    })

    if (this.hasCounterTarget) this.counterTarget.textContent = String(index + 1)
  }
}
