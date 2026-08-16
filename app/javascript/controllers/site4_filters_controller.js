import { Controller } from "@hotwired/stimulus"

// Hoja de filtros (móvil).
//
// El panel ya está en el flujo de la página; en móvil este controlador lo
// vuelve una hoja que sube desde abajo (`is-armed` fija la hoja y `is-open` la
// muestra). Sin JavaScript el panel se ve arriba de los resultados tal cual.
export default class extends Controller {
  static targets = ["backdrop", "sheet", "openButton", "apply"]

  connect() {
    this.lastFocused = null
    this.element.classList.add("is-armed")

    this.onKeydown = (event) => {
      if (event.key === "Escape" && this.isOpen) this.close()
    }
    document.addEventListener("keydown", this.onKeydown)

    // Al agrandar la ventana la hoja vuelve al flujo; no hay nada que cerrar.
    this.onResize = (event) => {
      if (event.matches && this.isOpen) this.close(true)
    }
    this.desktop = window.matchMedia("(min-width: 1024px)")
    this.desktop.addEventListener("change", this.onResize)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    this.desktop?.removeEventListener("change", this.onResize)
    document.body.classList.remove("overflow-hidden")
  }

  open(event) {
    this.lastFocused = event?.currentTarget ?? null
    this.isOpen = true
    this.render()

    if (this.hasSheetTarget) {
      this.sheetTarget.setAttribute("tabindex", "-1")
      this.sheetTarget.focus({ preventScroll: true })
    }
  }

  close(silent = false) {
    this.isOpen = false
    this.render()
    if (silent) return

    this.lastFocused?.focus?.()
    this.lastFocused = null
  }

  submit() {
    this.element.requestSubmit()
  }

  render() {
    this.element.classList.toggle("is-open", this.isOpen)
    if (this.hasOpenButtonTarget) {
      this.openButtonTarget.setAttribute("aria-expanded", String(this.isOpen))
    }
    document.body.classList.toggle("overflow-hidden", this.isOpen)
  }
}
