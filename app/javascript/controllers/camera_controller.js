import { Controller } from "@hotwired/stimulus"

// Handles the photo-capture step.
//   • Opens the rear camera via getUserMedia
//   • Draws a captured frame to a canvas and stores it as base64 JPEG
//     in the hidden issue[photo_data] field
//   • Falls back to a native file picker (with capture=environment) when
//     getUserMedia is unavailable or permission is denied
export default class extends Controller {
  static targets = [
    "viewport",
    "video",
    "preview",
    "canvas",
    "error",
    "skipped",
    "fileInput",
    "dataField",
    "liveActions",
    "capturedActions",
    "fallbackActions",
    "captureButton"
  ]

  MAX_DIMENSION = 1600
  JPEG_QUALITY = 0.82

  connect() {
    this.stream = null
    this.startCamera()
  }

  disconnect() {
    this.stopCamera()
  }

  async startCamera() {
    if (!navigator.mediaDevices?.getUserMedia) {
      this.showFallback()
      return
    }
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: { ideal: "environment" } },
        audio: false
      })
      this.videoTarget.srcObject = this.stream
      await this.videoTarget.play().catch(() => {})
    } catch (err) {
      console.warn("Camera unavailable:", err)
      this.showFallback()
    }
  }

  stopCamera() {
    if (this.stream) {
      this.stream.getTracks().forEach((t) => t.stop())
      this.stream = null
    }
  }

  showFallback() {
    this.videoTarget.classList.add("hidden")
    if (this.hasErrorTarget) this.errorTarget.classList.remove("hidden")
    if (this.hasLiveActionsTarget) this.liveActionsTarget.classList.add("hidden")
    if (this.hasFallbackActionsTarget) this.fallbackActionsTarget.classList.remove("hidden")
  }

  capture() {
    if (!this.videoTarget.videoWidth) return
    const { videoWidth: vw, videoHeight: vh } = this.videoTarget
    const scale = Math.min(1, this.MAX_DIMENSION / Math.max(vw, vh))
    const w = Math.round(vw * scale)
    const h = Math.round(vh * scale)

    const canvas = this.canvasTarget
    canvas.width = w
    canvas.height = h
    const ctx = canvas.getContext("2d")
    ctx.drawImage(this.videoTarget, 0, 0, w, h)

    const dataUrl = canvas.toDataURL("image/jpeg", this.JPEG_QUALITY)
    this.setCapturedImage(dataUrl)
  }

  retake() {
    this.dataFieldTarget.value = ""
    this.previewTarget.src = ""
    this.previewTarget.classList.add("hidden")
    this.videoTarget.classList.remove("hidden")
    if (this.hasSkippedTarget) this.skippedTarget.classList.add("hidden")
    this.liveActionsTarget.classList.remove("hidden")
    this.capturedActionsTarget.classList.add("hidden")
    if (!this.stream) this.startCamera()
  }

  skip() {
    this.dataFieldTarget.value = ""
    this.stopCamera()
    this.videoTarget.classList.add("hidden")
    this.previewTarget.classList.add("hidden")
    if (this.hasErrorTarget) this.errorTarget.classList.add("hidden")
    if (this.hasSkippedTarget) this.skippedTarget.classList.remove("hidden")
  }

  triggerFileInput() {
    this.fileInputTarget.click()
  }

  fileSelected(event) {
    const file = event.target.files && event.target.files[0]
    if (!file) return
    const reader = new FileReader()
    reader.onload = (e) => {
      // Downscale via canvas to keep payloads reasonable
      const img = new Image()
      img.onload = () => {
        const scale = Math.min(1, this.MAX_DIMENSION / Math.max(img.width, img.height))
        const w = Math.round(img.width * scale)
        const h = Math.round(img.height * scale)
        const canvas = this.canvasTarget
        canvas.width = w
        canvas.height = h
        canvas.getContext("2d").drawImage(img, 0, 0, w, h)
        this.setCapturedImage(canvas.toDataURL("image/jpeg", this.JPEG_QUALITY))
      }
      img.src = e.target.result
    }
    reader.readAsDataURL(file)
  }

  setCapturedImage(dataUrl) {
    this.dataFieldTarget.value = dataUrl
    this.previewTarget.src = dataUrl
    this.previewTarget.classList.remove("hidden")
    this.videoTarget.classList.add("hidden")
    if (this.hasErrorTarget) this.errorTarget.classList.add("hidden")
    if (this.hasSkippedTarget) this.skippedTarget.classList.add("hidden")
    if (this.hasLiveActionsTarget) this.liveActionsTarget.classList.add("hidden")
    if (this.hasFallbackActionsTarget) this.fallbackActionsTarget.classList.add("hidden")
    if (this.hasCapturedActionsTarget) this.capturedActionsTarget.classList.remove("hidden")
    this.stopCamera()
  }
}
