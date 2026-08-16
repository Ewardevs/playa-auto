import { Controller } from "@hotwired/stimulus"

// Formulario de filtros del catálogo.
//
// Lo único que agrega es enviar el formulario cuando cambia un desplegable, así
// no hace falta apretar "Aplicar" para cada ajuste. Todo lo demás —abrir el
// panel, quitar una ficha, ordenar— funciona sin JavaScript: acá no hay lógica
// de filtrado, solo un atajo.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
