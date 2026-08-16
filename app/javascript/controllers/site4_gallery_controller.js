import { Controller } from "@hotwired/stimulus"

// Galería de un vehículo.
//
// El visor a pantalla completa existe en el HTML pero viene oculto (`hidden`);
// sin JavaScript no hay nada que ver y el visitante navega por las fotos en el
// carril de miniaturas. Acá se enciende, se maneja el índice, el contador y las
// flechas del teclado, y se devuelve el foco al botón que la abrió.
export default class extends Controller {
  static targets = ["thumb", "slide", "viewer", "open", "counter"]
  static values = { count: Number }

  connect() {
    this.index = 0
    if (this.hasOpenTarget) this.openTarget.hidden = false

    this.onKeydown = this.onKeydown.bind(this)
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  open(event) {
    if (event?.currentTarget?.dataset?.index !== undefined) {
      this.index = Number(event.currentTarget.dataset.index)
    }
    this.renderViewer(true)
    this.renderThumbs()
  }

  select(event) {
    this.index = Number(event.currentTarget.dataset.index)
    this.renderViewer(true)
    this.renderThumbs()
  }

  close() {
    this.renderViewer(false)
    if (this.hasOpenTarget) this.openTarget.focus({ preventScroll: true })
  }

  next() {
    this.move(1)
  }

  previous() {
    this.move(-1)
  }

  move(step) {
    this.index = (this.index + step + this.countValue) % this.countValue
    this.renderSlides()
    this.renderThumbs()
  }

  onKeydown(event) {
    if (!this.hasViewerTarget || this.viewerTarget.hidden) return

    if (event.key === "Escape") this.close()
    if (event.key === "ArrowRight") this.next()
    if (event.key === "ArrowLeft") this.previous()
  }

  renderViewer(visible) {
    if (this.hasViewerTarget) {
      this.viewerTarget.hidden = !visible
      this.viewerTarget.setAttribute("aria-hidden", String(!visible))
    }
    document.body.classList.toggle("overflow-hidden", visible)
    this.renderSlides()
  }

  renderSlides() {
    this.slideTargets.forEach((slide, i) => {
      slide.hidden = i !== this.index
    })
    this.counterTargets.forEach((counter) => {
      counter.textContent = `${this.index + 1} / ${this.countValue}`
    })
  }

  renderThumbs() {
    this.thumbTargets.forEach((thumb, i) => {
      const active = i === this.index
      thumb.classList.toggle("ring-s4-accent", active)
      thumb.setAttribute("aria-current", String(active))
    })
  }
}
