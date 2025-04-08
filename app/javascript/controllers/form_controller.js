import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "loading"]

  submit(event) {
    this.buttonTarget.disabled = true
    this.buttonTarget.classList.add("opacity-50", "cursor-not-allowed")
    this.loadingTarget.classList.remove("hidden")
  }

  reset() {
    this.buttonTarget.disabled = false
    this.buttonTarget.classList.remove("opacity-50", "cursor-not-allowed")
    this.loadingTarget.classList.add("hidden")
  }
}
