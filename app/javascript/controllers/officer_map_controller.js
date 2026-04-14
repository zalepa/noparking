import { Controller } from "@hotwired/stimulus"
import * as L from "leaflet"

// Renders a Leaflet map showing each officer's most recent known location.
// The officer markers are pulled from data-* attributes on per-officer
// elements inside the same controller scope so the server owns the data.
export default class extends Controller {
  static targets = ["map", "officer"]

  connect() {
    if (this.officerTargets.length === 0) {
      // No recent locations — render nothing; the empty state handles it.
      return
    }

    this.map = L.map(this.mapTarget, {
      zoomControl: true,
      attributionControl: true
    })

    L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "© OpenStreetMap"
    }).addTo(this.map)

    const latlngs = []
    this.officerTargets.forEach((el) => {
      const lat   = parseFloat(el.dataset.lat)
      const lng   = parseFloat(el.dataset.lng)
      const name  = el.dataset.name || "Officer"
      const ago   = el.dataset.ago  || ""
      if (!Number.isFinite(lat) || !Number.isFinite(lng)) return

      const marker = L.circleMarker([lat, lng], {
        radius: 10, weight: 3, color: "#ffffff",
        fillColor: "#2563eb", fillOpacity: 1
      }).addTo(this.map)
      marker.bindPopup(`<strong>${this.escape(name)}</strong><br><span style="color:#6b7280">Seen ${this.escape(ago)} ago</span>`)
      latlngs.push([lat, lng])
    })

    if (latlngs.length === 1) {
      this.map.setView(latlngs[0], 14)
    } else if (latlngs.length > 1) {
      this.map.fitBounds(L.latLngBounds(latlngs).pad(0.3))
    }

    setTimeout(() => this.map.invalidateSize(), 50)
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
      this.map = null
    }
  }

  escape(str) {
    return String(str).replace(/[&<>"']/g, (c) => ({
      "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;"
    }[c]))
  }
}
