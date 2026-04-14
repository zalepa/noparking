import { Controller } from "@hotwired/stimulus"

// Toggleable disclosure menu (used by the mobile hamburger on the navbar).
// Closes on Escape, on outside click, and when Turbo finishes a navigation.
export default class extends Controller {
  static targets = ["panel", "button"]

  connect() {
    this.closeBound = this.close.bind(this)
    this.outsideBound = this.handleOutside.bind(this)
    this.keyBound = this.handleKey.bind(this)
    document.addEventListener("turbo:load", this.closeBound)
    document.addEventListener("click", this.outsideBound, true)
    document.addEventListener("keydown", this.keyBound)
  }

  disconnect() {
    document.removeEventListener("turbo:load", this.closeBound)
    document.removeEventListener("click", this.outsideBound, true)
    document.removeEventListener("keydown", this.keyBound)
  }

  toggle(event) {
    event.preventDefault()
    const open = this.panelTarget.classList.toggle("hidden") === false
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", open ? "true" : "false")
  }

  close() {
    this.panelTarget.classList.add("hidden")
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  handleOutside(event) {
    if (this.element.contains(event.target)) return
    this.close()
  }

  handleKey(event) {
    if (event.key === "Escape") this.close()
  }
}
