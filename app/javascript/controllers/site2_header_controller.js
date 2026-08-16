import { Controller } from "@hotwired/stimulus"

// Barra superior de Site2.
//
// No cambia de color al bajar: se encoge y llena un hilo de progreso. Toda la
// orientación es geométrica, así la barra se lee igual sobre una fotografía
// clara que sobre una oscura y no hay que recolorear nada en JavaScript.
export default class extends Controller {
  static targets = ["bar", "menu", "burger", "burgerOpen", "burgerClose", "progress"]

  static CONDENSED = 80

  connect() {
    this.menuOpen = false
    this.condensed = false
    this.ticking = false

    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.menuOpen) this.close()
    }
    document.addEventListener("keydown", this.onKeydown)

    this.update()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  onScroll() {
    // Una sola lectura de layout por cuadro: leer scrollHeight en cada evento
    // de scroll es la forma más rápida de arruinar el rendimiento de la página.
    if (this.ticking) return
    this.ticking = true
    requestAnimationFrame(() => {
      this.update()
      this.ticking = false
    })
  }

  update() {
    const scrolled = window.scrollY
    const total = document.documentElement.scrollHeight - window.innerHeight
    const ratio = total > 0 ? Math.min(scrolled / total, 1) : 0

    if (this.hasProgressTarget) {
      this.progressTarget.style.transform = `scaleX(${ratio})`
    }

    const condensed = scrolled > this.constructor.CONDENSED
    if (condensed !== this.condensed) {
      this.condensed = condensed
      if (this.hasBarTarget) this.barTarget.classList.toggle("lg:h-14", condensed)
    }
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

    if (this.hasBurgerTarget) {
      this.burgerTarget.setAttribute("aria-expanded", String(this.menuOpen))
    }

    document.body.classList.toggle("overflow-hidden", this.menuOpen)
  }
}
