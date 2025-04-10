import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "warning"]

  toggleWarning() {
    const selected = this.selectTarget.value
    const isDark = selected === "Dark"

    this.warningTarget.classList.toggle("hidden", !isDark)
  }
}
