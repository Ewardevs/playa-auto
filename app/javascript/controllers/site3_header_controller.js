import { Controller } from "@hotwired/stimulus"

// Barra isla.
//
// Se esconde al bajar y vuelve al subir: en una isla flotante eso se puede
// hacer sin que el contenido salte, porque la barra no ocupa lugar en el flujo.
// El menú móvil es una segunda isla debajo de la primera.
export default class extends Controller {
  static targets = ["menu", "burger", "burgerOpen", "burgerClose"]

  static THRESHOLD = 120

  connect() {
    this.menuOpen = false
    this.hidden = false
    this.lastY = window.scrollY
    this.ticking = false

    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.menuOpen) this.close()
    }
    document.addEventListener("keydown", this.onKeydown)

    this.element.classList.add("transition-transform", "duration-500", "ease-out")
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  onScroll() {
    if (this.ticking) return
    this.ticking = true

    requestAnimationFrame(() => {
      const y = window.scrollY
      // Con el menú abierto la barra no se mueve: esconderla dejaría el menú
      // colgando de la nada.
      const shouldHide = !this.menuOpen && y > this.constructor.THRESHOLD && y > this.lastY

      if (shouldHide !== this.hidden) {
        this.hidden = shouldHide
        this.element.style.transform = shouldHide ? "translateY(-140%)" : ""
      }

      this.lastY = y
      this.ticking = false
    })
  }

  toggle() {
    this.menuOpen = !this.menuOpen
    this.render()
  }

  close() {
    this.menuOpen = false
    this.render()
  }

  render() {
    if (this.hasMenuTarget) this.menuTarget.hidden = !this.menuOpen
    if (this.hasBurgerOpenTarget) this.burgerOpenTarget.hidden = this.menuOpen
    if (this.hasBurgerCloseTarget) this.burgerCloseTarget.hidden = !this.menuOpen
    if (this.hasBurgerTarget) this.burgerTarget.setAttribute("aria-expanded", String(this.menuOpen))

    document.body.classList.toggle("overflow-hidden", this.menuOpen)

    if (this.menuOpen && this.hidden) {
      this.hidden = false
      this.element.style.transform = ""
    }
  }
}
