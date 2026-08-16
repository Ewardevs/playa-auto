import { Controller } from "@hotwired/stimulus"

// Riel de filtros.
//
// Cada filtro es un <details> nativo, así que abre, cierra y se anuncia sin
// JavaScript. Esto agrega dos comodidades y nada más: cerrar el desplegable
// anterior al abrir otro, y enviar el formulario al elegir una opción.
export default class extends Controller {
  static targets = ["popover"]

  connect() {
    this.onToggle = this.onToggle.bind(this)
    this.popoverTargets.forEach((el) => el.addEventListener("toggle", this.onToggle))

    this.onClickOutside = this.onClickOutside.bind(this)
    document.addEventListener("click", this.onClickOutside)
  }

  disconnect() {
    this.popoverTargets.forEach((el) => el.removeEventListener("toggle", this.onToggle))
    document.removeEventListener("click", this.onClickOutside)
  }

  onToggle(event) {
    if (!event.target.open) return

    this.popoverTargets.forEach((el) => {
      if (el !== event.target) el.open = false
    })
  }

  onClickOutside(event) {
    if (this.element.contains(event.target)) return

    this.popoverTargets.forEach((el) => { el.open = false })
  }

  submit() {
    this.element.requestSubmit()
  }
}
