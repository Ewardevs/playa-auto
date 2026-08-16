import { Controller } from "@hotwired/stimulus"

// Muelle del header.
//
// Transparente sobre la portada y sólido apenas el visitante baja: `is-solid`
// enciende el fondo con desenfoque que ya está escrito en CSS. El menú móvil es
// una segunda isla que se despliega debajo.
export default class extends Controller {
  static targets = ["dock", "burger", "burgerOpen", "burgerClose", "menu"]

  static THRESHOLD = 24

  connect() {
    this.menuOpen = false
    this.ticking = false

    this.onScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.onScroll()

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.menuOpen) this.close()
    }
    document.addEventListener("keydown", this.onKeydown)
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
      if (this.hasDockTarget) {
        this.dockTarget.classList.toggle("is-solid", window.scrollY > this.constructor.THRESHOLD)
      }
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
  }
}
