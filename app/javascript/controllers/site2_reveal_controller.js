import { Controller } from "@hotwired/stimulus"

// Aparición al entrar en pantalla.
//
// El estado oculto lo arma este controlador (`is-armed`), nunca la plantilla:
// si el JavaScript no carga, la clase no se agrega y el contenido se ve desde
// el primer momento. Un efecto decorativo no puede ser la razón por la que
// alguien no lee el catálogo.
export default class extends Controller {
  static targets = ["item"]
  static values = { stagger: { type: Number, default: 60 } }

  connect() {
    this.items = this.hasItemTarget ? this.itemTargets : [this.element]

    if (this.reducedMotion || !("IntersectionObserver" in window)) {
      this.items.forEach((item) => item.classList.add("s2-reveal", "is-in"))
      return
    }

    this.items.forEach((item) => item.classList.add("s2-reveal", "is-armed"))

    this.observer = new IntersectionObserver(
      (entries) => this.onIntersect(entries),
      { rootMargin: "0px 0px -8% 0px", threshold: 0.05 }
    )

    this.items.forEach((item) => this.observer.observe(item))
  }

  disconnect() {
    this.observer?.disconnect()
  }

  onIntersect(entries) {
    // El escalonado es por tanda, no por posición en la lista: si no, el
    // vigésimo elemento del catálogo esperaría más de un segundo para aparecer.
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
