import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

// Initializes a Leaflet map centered on the user's current location
// with a draggable marker. Writes lat/lng/address into hidden form
// fields and dispatches "location-picker:updated" on the controller
// element so the wizard can enable its Next button.
export default class extends Controller {
  static targets = [
    "map",
    "loading",
    "address",
    "instructions",
    "latitudeField",
    "longitudeField",
    "addressField"
  ]

  DEFAULT_CENTER = [40.7128, -74.0060] // NYC fallback
  DEFAULT_ZOOM = 17

  connect() {
    // Initialize lazily — the map panel may be hidden until step 2.
    // Leaflet needs a sized container; wait until it becomes visible.
    this.initialized = false
    this.observer = new IntersectionObserver((entries) => {
      if (entries.some((e) => e.isIntersecting) && !this.initialized) {
        this.initialize()
      }
    }, { threshold: 0.1 })
    this.observer.observe(this.mapTarget)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  initialize() {
    this.initialized = true

    this.map = L.map(this.mapTarget, {
      zoomControl: true,
      attributionControl: true
    }).setView(this.DEFAULT_CENTER, this.DEFAULT_ZOOM)

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "© OpenStreetMap"
    }).addTo(this.map)

    this.marker = L.marker(this.DEFAULT_CENTER, { draggable: true }).addTo(this.map)
    this.marker.on("dragend", () => this.onMarkerMoved())
    this.map.on("click", (e) => {
      this.marker.setLatLng(e.latlng)
      this.onMarkerMoved()
    })

    // Ensure the map sizes correctly once visible
    setTimeout(() => this.map.invalidateSize(), 50)

    this.locate()
  }

  locate() {
    if (!navigator.geolocation) {
      this.hideLoading()
      return
    }
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const { latitude, longitude } = position.coords
        const latlng = [latitude, longitude]
        this.map.setView(latlng, this.DEFAULT_ZOOM)
        this.marker.setLatLng(latlng)
        this.onMarkerMoved()
        this.hideLoading()
      },
      (err) => {
        console.warn("Geolocation failed:", err)
        this.hideLoading()
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 30000 }
    )
  }

  hideLoading() {
    if (this.hasLoadingTarget) this.loadingTarget.classList.add("hidden")
  }

  onMarkerMoved() {
    const { lat, lng } = this.marker.getLatLng()
    this.latitudeFieldTarget.value = lat.toFixed(6)
    this.longitudeFieldTarget.value = lng.toFixed(6)

    this.dispatch("updated", {
      detail: { latitude: lat, longitude: lng },
      prefix: "location-picker",
      bubbles: true
    })

    this.reverseGeocode(lat, lng)
  }

  async reverseGeocode(lat, lng) {
    if (this.hasAddressTarget) this.addressTarget.textContent = "Looking up address…"
    try {
      const url = `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=18&addressdetails=1`
      const res = await fetch(url, { headers: { "Accept": "application/json" } })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const data = await res.json()
      const display = data.display_name || ""
      if (this.hasAddressTarget) this.addressTarget.textContent = display || "Address not available"
      this.addressFieldTarget.value = display
    } catch (err) {
      console.warn("Reverse geocode failed:", err)
      if (this.hasAddressTarget) this.addressTarget.textContent = "Address not available"
    }
  }
}
