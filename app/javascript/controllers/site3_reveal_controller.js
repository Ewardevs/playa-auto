import { Controller } from "@hotwired/stimulus"

// Aparición al entrar en pantalla.
//
// El estado oculto lo arma este controlador (`is-armed`): sin JavaScript la
// clase nunca se agrega y el contenido se ve desde el primer pintado.
export default class extends Controller {
  static targets = ["item"]
  static values = { stagger: { type: Number, default: 70 } }

  connect() {
    this.items = this.hasItemTarget ? this.itemTargets : [this.element]

    if (this.reducedMotion || !("IntersectionObserver" in window)) {
      this.items.forEach((item) => item.classList.add("s3-reveal", "is-in"))
      return
    }

    this.items.forEach((item) => item.classList.add("s3-reveal", "is-armed"))

    this.observer = new IntersectionObserver(
      (entries) => this.onIntersect(entries),
      { rootMargin: "0px 0px -6% 0px", threshold: 0.05 }
    )
    this.items.forEach((item) => this.observer.observe(item))
  }

  disconnect() {
    this.observer?.disconnect()
  }

  onIntersect(entries) {
    // Escalonado por tanda, no por posición absoluta: si no, el último elemento
    // de una lista larga esperaría más de un segundo.
    entries
      .filter((entry) => entry.isIntersecting)
      .forEach((entry, position) => {
        entry.target.style.transitionDelay = `${Math.min(position, 5) * this.staggerValue}ms`
        entry.target.classList.add("is-in")
        this.observer.unobserve(entry.target)
      })
  }

  get reducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
