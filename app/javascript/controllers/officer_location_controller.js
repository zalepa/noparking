import { Controller } from "@hotwired/stimulus"

// Streams the officer's location via watchPosition while the page is open.
//
// On first grant (no lat/lng in the URL), we reload once so the server can
// render rows with initial distances. After that, watchPosition takes over:
// we resort rows client-side on every significant move and periodically
// POST the position to /officer/locations so managers can see officer
// positions in real time.
export default class extends Controller {
  static targets = ["message", "subtext", "list", "row", "distance"]
  static values  = {
    lat: { type: String, default: "" },
    lng: { type: String, default: "" }
  }

  STORAGE_KEY = "noparking:officer_location_consent"
  EARTH_RADIUS_MILES = 3958.8
  MIN_MOVE_METERS = 20
  MIN_INTERVAL_MS = 30_000
  POST_INTERVAL_MS = 60_000

  connect() {
    this.watchId = null
    this.lastUpdate = null
    this.lastPost = 0

    if (this.hasCoordinates()) {
      this.startWatching()
    } else if (localStorage.getItem(this.STORAGE_KEY) === "granted") {
      this.request()
    }
  }

  disconnect() {
    if (this.watchId !== null) navigator.geolocation.clearWatch(this.watchId)
  }

  hasCoordinates() {
    return this.latValue && this.lngValue
  }

  request() {
    if (!navigator.geolocation) {
      this.showError("Your browser doesn't support location sharing.")
      return
    }
    this.showStatus("Getting your location…")
    navigator.geolocation.getCurrentPosition(
      (pos) => this.reloadWith(pos.coords.latitude, pos.coords.longitude),
      (err) => {
        localStorage.removeItem(this.STORAGE_KEY)
        this.showError(this.errorMessage(err))
      },
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 30000 }
    )
  }

  refresh(event) {
    event?.preventDefault()
    navigator.geolocation.getCurrentPosition(
      (pos) => this.handlePosition(pos),
      (err) => console.warn("refresh failed", err),
      { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
    )
  }

  reloadWith(lat, lng) {
    localStorage.setItem(this.STORAGE_KEY, "granted")
    const url = new URL(window.location.href)
    url.searchParams.set("lat", lat.toFixed(6))
    url.searchParams.set("lng", lng.toFixed(6))
    window.location.replace(url.toString())
  }

  startWatching() {
    if (!navigator.geolocation) return
    this.watchId = navigator.geolocation.watchPosition(
      (pos) => this.handlePosition(pos),
      (err) => console.warn("watchPosition error", err),
      { enableHighAccuracy: true, maximumAge: 10000 }
    )
  }

  handlePosition(pos) {
    const { latitude, longitude, accuracy } = pos.coords
    const now = Date.now()

    if (this.lastUpdate) {
      const moved = this.distanceMeters(this.lastUpdate.lat, this.lastUpdate.lng, latitude, longitude)
      const elapsed = now - this.lastUpdate.time
      if (moved < this.MIN_MOVE_METERS && elapsed < this.MIN_INTERVAL_MS) return
    }
    this.lastUpdate = { lat: latitude, lng: longitude, time: now }

    this.resortRows(latitude, longitude)

    if (now - this.lastPost >= this.POST_INTERVAL_MS) {
      this.lastPost = now
      this.postPosition(latitude, longitude, accuracy)
    }
  }

  resortRows(lat, lng) {
    if (!this.hasListTarget || this.rowTargets.length === 0) return

    const entries = this.rowTargets.map((row) => {
      const rowLat = parseFloat(row.dataset.lat)
      const rowLng = parseFloat(row.dataset.lng)
      const miles = (Number.isFinite(rowLat) && Number.isFinite(rowLng))
        ? this.distanceMiles(lat, lng, rowLat, rowLng)
        : Infinity
      return { row, miles }
    })

    entries.sort((a, b) => a.miles - b.miles)

    entries.forEach(({ row, miles }) => {
      const badge = row.querySelector('[data-officer-location-target="distance"]')
      if (badge && Number.isFinite(miles)) {
        const precision = miles < 10 ? 1 : 0
        badge.textContent = `${miles.toFixed(precision)} mi`
        badge.className = "text-xs font-semibold text-gray-900 shrink-0 bg-gray-100 rounded-full px-2 py-0.5"
      }
      this.listTarget.appendChild(row)
    })
  }

  postPosition(lat, lng, accuracy) {
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    fetch("/officer/locations", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": token || ""
      },
      body: JSON.stringify({ latitude: lat, longitude: lng, accuracy_meters: accuracy })
    }).catch((err) => console.warn("location post failed", err))
  }

  distanceMiles(lat1, lng1, lat2, lng2) {
    const rad = Math.PI / 180
    const dLat = (lat2 - lat1) * rad
    const dLng = (lng2 - lng1) * rad
    const a = Math.sin(dLat / 2) ** 2 +
              Math.cos(lat1 * rad) * Math.cos(lat2 * rad) * Math.sin(dLng / 2) ** 2
    return 2 * this.EARTH_RADIUS_MILES * Math.asin(Math.sqrt(a))
  }

  distanceMeters(lat1, lng1, lat2, lng2) {
    return this.distanceMiles(lat1, lng1, lat2, lng2) * 1609.344
  }

  showStatus(text) {
    if (this.hasMessageTarget) this.messageTarget.textContent = text
  }

  showError(text) {
    if (this.hasMessageTarget) this.messageTarget.textContent = "Couldn't get your location"
    if (this.hasSubtextTarget) this.subtextTarget.textContent = text
  }

  errorMessage(err) {
    switch (err.code) {
      case err.PERMISSION_DENIED:
        return "Location permission was denied. Enable it in your browser settings to sort by distance."
      case err.POSITION_UNAVAILABLE:
        return "Your device couldn't determine its position."
      case err.TIMEOUT:
        return "Location request timed out. Try again."
      default:
        return "Unknown error getting your location."
    }
  }
}
