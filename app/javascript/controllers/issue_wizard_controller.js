import { Controller } from "@hotwired/stimulus"

// Coordinates the three-step issue reporting wizard:
//   photo → location → details
//
// Responsibilities:
//   • Show/hide step panels based on the current step value
//   • Update the step label and progress dots
//   • Populate the details-step review with the captured photo + address
//   • Guard form submission (block while step < details, require location)
export default class extends Controller {
  static targets = [
    "form",
    "panel",
    "stepLabel",
    "dot",
    "locationNext",
    "reviewPhoto",
    "reviewPhotoEmpty",
    "reviewAddress"
  ]
  static values = { step: { type: String, default: "photo" } }

  STEPS = ["photo", "location", "details"]
  LABELS = { photo: "Step 1 of 3", location: "Step 2 of 3", details: "Step 3 of 3" }

  connect() {
    this.stepValueChanged()
    // Listen for location updates from the location-picker controller
    this.element.addEventListener("location-picker:updated", this.onLocationUpdated)
    // Stop bubbled submit events that aren't ours
    this.element.addEventListener("keydown", this.onKeydown)
  }

  disconnect() {
    this.element.removeEventListener("location-picker:updated", this.onLocationUpdated)
    this.element.removeEventListener("keydown", this.onKeydown)
  }

  // Prevent Enter from submitting the form outside the details step
  onKeydown = (event) => {
    if (event.key === "Enter" && event.target.tagName !== "TEXTAREA" && this.stepValue !== "details") {
      event.preventDefault()
    }
  }

  onLocationUpdated = (event) => {
    const { latitude, longitude } = event.detail || {}
    if (this.hasLocationNextTarget && latitude && longitude) {
      this.locationNextTarget.disabled = false
    }
  }

  advance() {
    const idx = this.STEPS.indexOf(this.stepValue)
    if (idx < this.STEPS.length - 1) {
      this.stepValue = this.STEPS[idx + 1]
    }
  }

  back() {
    const idx = this.STEPS.indexOf(this.stepValue)
    if (idx > 0) {
      this.stepValue = this.STEPS[idx - 1]
    }
  }

  stepValueChanged() {
    this.panelTargets.forEach((panel) => {
      const matches = panel.dataset.step === this.stepValue
      panel.classList.toggle("hidden", !matches)
    })

    if (this.hasStepLabelTarget) {
      this.stepLabelTarget.textContent = this.LABELS[this.stepValue] || ""
    }

    this.dotTargets.forEach((dot) => {
      const step = dot.dataset.step
      const active = step === this.stepValue
      const completed = this.STEPS.indexOf(step) < this.STEPS.indexOf(this.stepValue)
      dot.classList.toggle("bg-blue-600", active)
      dot.classList.toggle("w-6", active)
      dot.classList.toggle("bg-blue-400", completed && !active)
      dot.classList.toggle("bg-gray-300", !active && !completed)
    })

    if (this.stepValue === "details") {
      this.populateReview()
    }

    // Scroll to top so the user sees the new step's heading
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  populateReview() {
    // Photo
    const dataField = this.formTarget.querySelector("[data-camera-target='dataField']")
    if (this.hasReviewPhotoTarget && this.hasReviewPhotoEmptyTarget) {
      if (dataField && dataField.value) {
        this.reviewPhotoTarget.src = dataField.value
        this.reviewPhotoTarget.classList.remove("hidden")
        this.reviewPhotoEmptyTarget.classList.add("hidden")
      } else {
        this.reviewPhotoTarget.classList.add("hidden")
        this.reviewPhotoEmptyTarget.classList.remove("hidden")
      }
    }

    // Address
    const addressField = this.formTarget.querySelector("[data-location-picker-target='addressField']")
    if (this.hasReviewAddressTarget) {
      this.reviewAddressTarget.textContent = (addressField && addressField.value) || "—"
    }
  }

  beforeSubmit(event) {
    if (this.stepValue !== "details") {
      event.preventDefault()
      return
    }
    const latField = this.formTarget.querySelector("[data-location-picker-target='latitudeField']")
    const lngField = this.formTarget.querySelector("[data-location-picker-target='longitudeField']")
    if (!latField?.value || !lngField?.value) {
      event.preventDefault()
      this.stepValue = "location"
    }
  }
}
