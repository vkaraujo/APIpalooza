import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "tip"]

  updateTip() {
    const type = this.selectTarget.value

    const tips = {
      trivia: "🧠 Try any number — like 42 or 7. They all have weird stories.",
      math: "➗ Use a number with some mathy charm. Try 1729!",
      date: "📅 Use MM/DD format, like 6/14 (June 14th).",
      year: "🏛️ Enter a 4-digit year, like 1969 or 2000."
    }

    this.tipTarget.textContent = tips[type] || ""
  }
}
