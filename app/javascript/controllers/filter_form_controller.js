import { Controller } from "@hotwired/stimulus"

// Submits a filter form when a select changes, so choosing a filter applies it.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
