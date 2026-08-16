import { Controller } from "@hotwired/stimulus"

// Public header.
//
// On the home page it starts transparent over the hero photograph and turns
// solid once the visitor scrolls past it. Everywhere else it is solid from the
// first paint and this controller only runs the mobile drawer.
export default class extends Controller {
  static targets = ["bar", "menu", "burger", "burgerOpen", "burgerClose", "navLink", "mark", "wordmark"]
  static values = { transparent: Boolean }

  static THRESHOLD = 24

  connect() {
    this.menuOpen = false
    this.solid = !this.transparentValue

    if (this.transparentValue) {
      this.onScroll = this.onScroll.bind(this)
      window.addEventListener("scroll", this.onScroll, { passive: true })
      this.onScroll()
    }

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.menuOpen) this.closeMenu()
    }
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    if (this.transparentValue) window.removeEventListener("scroll", this.onScroll)
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  onScroll() {
    // An open drawer already has a solid background; don't fight it.
    const shouldBeSolid = window.scrollY > this.constructor.THRESHOLD || this.menuOpen
    if (shouldBeSolid === this.solid) return

    this.solid = shouldBeSolid
    this.render()
  }

  toggleMenu() {
    this.menuOpen = !this.menuOpen
    this.render()
  }

  closeMenu() {
    this.menuOpen = false
    this.render()
  }

  render() {
    const solid = this.solid || this.menuOpen

    this.barTarget.classList.toggle("bg-paper", solid)
    this.barTarget.classList.toggle("border-sand", solid)
    this.barTarget.classList.toggle("bg-transparent", !solid)
    this.barTarget.classList.toggle("border-transparent", !solid)

    this.navLinkTargets.forEach((link) => {
      link.classList.toggle("text-stone", solid)
      link.classList.toggle("hover:text-graphite", solid)
      link.classList.toggle("text-white/85", !solid)
      link.classList.toggle("hover:text-white", !solid)
    })

    if (this.hasMarkTarget) {
      this.markTarget.classList.toggle("bg-brand", solid)
      this.markTarget.classList.toggle("text-white", true)
      this.markTarget.classList.toggle("bg-white/15", !solid)
      this.markTarget.classList.toggle("backdrop-blur-sm", !solid)
    }

    if (this.hasWordmarkTarget) {
      this.wordmarkTarget.classList.toggle("text-graphite", solid)
      this.wordmarkTarget.classList.toggle("text-white", !solid)
    }

    if (this.hasBurgerTarget) {
      this.burgerTarget.classList.toggle("text-graphite", solid)
      this.burgerTarget.classList.toggle("hover:bg-paper-2", solid)
      this.burgerTarget.classList.toggle("text-white", !solid)
      this.burgerTarget.classList.toggle("hover:bg-white/10", !solid)
      this.burgerTarget.setAttribute("aria-expanded", String(this.menuOpen))
    }

    if (this.hasMenuTarget) this.menuTarget.hidden = !this.menuOpen
    if (this.hasBurgerOpenTarget) this.burgerOpenTarget.hidden = this.menuOpen
    if (this.hasBurgerCloseTarget) this.burgerCloseTarget.hidden = !this.menuOpen

    document.body.classList.toggle("overflow-hidden", this.menuOpen)
  }
}
