import { Controller } from "@hotwired/stimulus"

// Drives the navigation rail in both of its modes:
//   - desktop: collapse to an icon rail, remembered across visits
//   - mobile:  slide in as an off-canvas drawer over a scrim
//
// The collapsed choice is stored locally because it is a per-device preference,
// not account data.
export default class extends Controller {
  static targets = ["rail", "scrim", "label", "collapseIcon"]

  static STORAGE_KEY = "playa:sidebar-collapsed"

  connect() {
    this.mobileOpen = false
    this.collapsed = localStorage.getItem(this.constructor.STORAGE_KEY) === "true"
    this.render()

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.mobileOpen) this.closeMobile()
    }
    document.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("overflow-hidden")
  }

  toggleCollapse() {
    this.collapsed = !this.collapsed
    localStorage.setItem(this.constructor.STORAGE_KEY, String(this.collapsed))
    this.render()
  }

  openMobile() {
    this.mobileOpen = true
    this.render()
  }

  closeMobile() {
    this.mobileOpen = false
    this.render()
  }

  render() {
    if (!this.hasRailTarget) return

    const rail = this.railTarget

    // Desktop width. Classes are written out in full so Tailwind can see them.
    rail.classList.toggle("lg:w-[4.25rem]", this.collapsed)
    rail.classList.toggle("lg:w-64", !this.collapsed)

    // Mobile drawer position.
    rail.classList.toggle("translate-x-0", this.mobileOpen)
    rail.classList.toggle("-translate-x-full", !this.mobileOpen)

    // Text hides when the rail is an icon strip — but never on mobile, where the
    // drawer is always full width.
    this.labelTargets.forEach((label) => {
      label.classList.toggle("lg:hidden", this.collapsed)
    })

    if (this.hasCollapseIconTarget) {
      this.collapseIconTarget.classList.toggle("rotate-180", this.collapsed)
    }

    if (this.hasScrimTarget) this.scrimTarget.hidden = !this.mobileOpen
    document.body.classList.toggle("overflow-hidden", this.mobileOpen)

    // Content offset follows the rail width.
    const shell = document.getElementById("admin-shell")
    if (shell) {
      shell.classList.toggle("lg:pl-[4.25rem]", this.collapsed)
      shell.classList.toggle("lg:pl-64", !this.collapsed)
    }
  }
}
