import { Controller } from "@hotwired/stimulus"

// Carril de fotos con anclaje de scroll.
//
// El scroll es del navegador; este controlador solo lo refleja (indicador,
// contador, botones) y lo empuja cuando alguien usa los botones o el teclado.
// Sin JavaScript el carril sigue siendo recorrible con el dedo o con la rueda.
export default class extends Controller {
  static targets = ["track", "slide", "bar", "counter", "previous", "next"]

  connect() {
    this.index = 0
    this.render()
  }

  onScroll() {
    // El scroll dispara decenas de eventos por gesto: un cuadro basta.
    if (this.ticking) return
    this.ticking = true
    requestAnimationFrame(() => {
      const next = this.nearestIndex()
      if (next !== this.index) {
        this.index = next
        this.render()
      }
      this.ticking = false
    })
  }

  onKeydown(event) {
    if (event.key === "ArrowRight") {
      event.preventDefault()
      this.next()
    } else if (event.key === "ArrowLeft") {
      event.preventDefault()
      this.previous()
    }
  }

  previous() { this.scrollTo(this.index - 1) }
  next()     { this.scrollTo(this.index + 1) }

  goTo(event) {
    this.scrollTo(Number(event.currentTarget.dataset.index))
  }

  scrollTo(index) {
    const clamped = Math.max(0, Math.min(index, this.slideTargets.length - 1))
    const slide = this.slideTargets[clamped]
    if (!slide) return

    this.trackTarget.scrollTo({
      left: slide.offsetLeft - this.trackTarget.offsetLeft,
      behavior: this.reducedMotion ? "auto" : "smooth"
    })
  }

  // La foto cuyo borde izquierdo está más cerca de la posición de scroll.
  nearestIndex() {
    const left = this.trackTarget.scrollLeft
    let best = 0
    let bestDistance = Infinity

    this.slideTargets.forEach((slide, index) => {
      const distance = Math.abs(slide.offsetLeft - this.trackTarget.offsetLeft - left)
      if (distance < bestDistance) {
        bestDistance = distance
        best = index
      }
    })

    return best
  }

  render() {
    const total = this.slideTargets.length

    this.barTargets.forEach((bar, index) => {
      bar.classList.toggle("bg-s2-signal", index === this.index)
      bar.classList.toggle("bg-s2-line-2", index !== this.index)
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.index + 1} / ${total}`
    }

    if (this.hasPreviousTarget) this.previousTarget.disabled = this.index === 0
    if (this.hasNextTarget) this.nextTarget.disabled = this.index >= total - 1
  }

  get reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
