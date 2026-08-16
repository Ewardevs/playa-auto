import { Controller } from "@hotwired/stimulus"

// Brand → model. Choosing a brand loads that brand's models into the second
// select, keeping the current value when it is still valid.
//
// The pairing is validated again on the server, so this is a convenience, not
// the guarantee.
export default class extends Controller {
  static targets = ["parent", "child"]
  static values = { url: String, prompt: String }

  connect() {
    this.initialValue = this.childTarget.value
  }

  async load() {
    const parentId = this.parentTarget.value

    if (!parentId) {
      this.replaceOptions([])
      return
    }

    this.setBusy(true)

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set("brand_id", parentId)

      const response = await fetch(url, { headers: { Accept: "application/json" } })
      if (!response.ok) throw new Error(`Models request failed: ${response.status}`)

      this.replaceOptions(await response.json())
    } catch (error) {
      console.error("[dependent-select]", error)
    } finally {
      this.setBusy(false)
    }
  }

  replaceOptions(options) {
    const previous = this.childTarget.value || this.initialValue
    this.childTarget.innerHTML = ""

    const blank = new Option(this.promptValue || "", "")
    this.childTarget.add(blank)

    options.forEach(({ id, name }) => {
      const option = new Option(name, id)
      if (String(id) === String(previous)) option.selected = true
      this.childTarget.add(option)
    })

    this.childTarget.disabled = options.length === 0
  }

  setBusy(busy) {
    this.childTarget.classList.toggle("opacity-50", busy)
    this.childTarget.disabled = busy
  }
}
