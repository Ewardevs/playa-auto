import { Controller } from "@hotwired/stimulus"

// Light/dark switch. The initial theme is applied by an inline script in the
// layout head so the page never flashes the wrong one; this controller only
// handles the toggle and keeps the icons in sync.
export default class extends Controller {
  static targets = ["lightIcon", "darkIcon"]

  static STORAGE_KEY = "playa:theme"

  connect() {
    this.sync()
  }

  toggle() {
    const dark = !document.documentElement.classList.contains("dark")
    document.documentElement.classList.toggle("dark", dark)
    localStorage.setItem(this.constructor.STORAGE_KEY, dark ? "dark" : "light")
    this.sync()
  }

  sync() {
    const dark = document.documentElement.classList.contains("dark")
    if (this.hasLightIconTarget) this.lightIconTarget.hidden = dark
    if (this.hasDarkIconTarget) this.darkIconTarget.hidden = !dark
  }
}
