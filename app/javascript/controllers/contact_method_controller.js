import { Controller } from "@hotwired/stimulus"

// Toggles between email and phone inputs in the registration form.
// Keeps one active at a time, disables the inactive input so it isn't
// submitted or validated, and updates the hidden `contact_method` field.
//
// Targets:
//   - methodField:   hidden input storing "email" or "phone"
//   - emailTab:      button that activates email mode
//   - phoneTab:      button that activates phone mode
//   - emailPanel:    wrapper around the email input
//   - phonePanel:    wrapper around the phone input
//   - emailInput:    the actual email input (for focus/disable)
//   - phoneInput:    the actual phone input (for focus/disable)
export default class extends Controller {
  static targets = [
    "methodField",
    "emailTab", "phoneTab",
    "emailPanel", "phonePanel",
    "emailInput", "phoneInput"
  ]

  static classes = ["active", "inactive"]

  connect() {
    this.apply(this.methodFieldTarget.value || "email", { focus: false })
  }

  selectEmail(event) {
    event.preventDefault()
    this.apply("email", { focus: true })
  }

  selectPhone(event) {
    event.preventDefault()
    this.apply("phone", { focus: true })
  }

  apply(method, { focus }) {
    const isEmail = method === "email"
    this.methodFieldTarget.value = method

    this.setTabState(this.emailTabTarget, isEmail)
    this.setTabState(this.phoneTabTarget, !isEmail)

    this.emailPanelTarget.classList.toggle("hidden", !isEmail)
    this.phonePanelTarget.classList.toggle("hidden", isEmail)

    // Disable the inactive input so it isn't required/submitted.
    this.emailInputTarget.disabled = !isEmail
    this.phoneInputTarget.disabled = isEmail

    if (focus) {
      const target = isEmail ? this.emailInputTarget : this.phoneInputTarget
      target.focus()
    }
  }

  setTabState(tab, active) {
    tab.setAttribute("aria-selected", active ? "true" : "false")
    if (this.hasActiveClass && this.hasInactiveClass) {
      const activeClasses = this.activeClasses
      const inactiveClasses = this.inactiveClasses
      if (active) {
        tab.classList.remove(...inactiveClasses)
        tab.classList.add(...activeClasses)
      } else {
        tab.classList.remove(...activeClasses)
        tab.classList.add(...inactiveClasses)
      }
    }
  }
}
