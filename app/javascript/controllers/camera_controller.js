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
    "nativePlaceholder",
    "fileInput",
    "cameraInput",
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

  // On mobile, defer to the OS camera app. It has zoom, flash, HDR, focus
  // controls — all the things a pinch-zoom-hijacking in-page viewport doesn't.
  // On desktop, use getUserMedia for a live webcam preview.
  isMobile() {
    return window.matchMedia("(hover: none) and (pointer: coarse)").matches
  }

  async startCamera() {
    if (this.isMobile()) {
      this.useNativeCamera()
      return
    }
    if (!navigator.mediaDevices?.getUserMedia) {
      this.showFallback()
      return
    }

    // Check existing permission state first so we don't re-prompt users who
    // already granted access (Permissions API is cached per-origin in Chrome,
    // Edge, and Firefox). If state is "prompt", we defer getUserMedia until
    // the user actually taps Capture — browsers only remember a grant after
    // the user explicitly approves, so asking pre-emptively on every page
    // load is what causes the "keeps asking" experience.
    const state = await this.cameraPermissionState()
    if (state === "denied") {
      this.showFallback()
      return
    }
    if (state === "granted") {
      await this.requestStream()
    } else {
      this.showNativePlaceholderForPrompt()
    }
  }

  async cameraPermissionState() {
    if (!navigator.permissions?.query) return "prompt"
    try {
      const result = await navigator.permissions.query({ name: "camera" })
      return result.state
    } catch {
      return "prompt"
    }
  }

  // Desktop variant of the native placeholder — looks the same but tapping
  // it requests the stream (and triggers the browser's one-time prompt).
  showNativePlaceholderForPrompt() {
    this.pendingPrompt = true
    this.videoTarget.classList.add("hidden")
    if (this.hasNativePlaceholderTarget) this.nativePlaceholderTarget.classList.remove("hidden")
  }

  async requestStream() {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia({
        video: { facingMode: { ideal: "environment" } },
        audio: false
      })
      this.videoTarget.srcObject = this.stream
      this.videoTarget.classList.remove("hidden")
      if (this.hasNativePlaceholderTarget) this.nativePlaceholderTarget.classList.add("hidden")
      await this.videoTarget.play().catch(() => {})
      this.pendingPrompt = false
    } catch (err) {
      console.warn("Camera unavailable:", err)
      this.showFallback()
    }
  }

  useNativeCamera() {
    this.nativeMode = true
    this.videoTarget.classList.add("hidden")
    if (this.hasNativePlaceholderTarget) this.nativePlaceholderTarget.classList.remove("hidden")
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
    if (this.nativeMode) {
      if (this.hasCameraInputTarget) this.cameraInputTarget.click()
      return
    }
    // Desktop: user tapped the dark placeholder (or Capture before stream
    // was running) — this is the one place we ask for camera permission.
    if (this.pendingPrompt || !this.stream) {
      this.requestStream()
      return
    }
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
    if (this.hasSkippedTarget) this.skippedTarget.classList.add("hidden")
    this.liveActionsTarget.classList.remove("hidden")
    this.capturedActionsTarget.classList.add("hidden")
    if (this.nativeMode) {
      if (this.hasNativePlaceholderTarget) this.nativePlaceholderTarget.classList.remove("hidden")
      if (this.hasCameraInputTarget) this.cameraInputTarget.click()
    } else {
      this.videoTarget.classList.remove("hidden")
      if (!this.stream) this.startCamera()
    }
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
    if (this.hasNativePlaceholderTarget) this.nativePlaceholderTarget.classList.add("hidden")
    this.stopCamera()
  }
}
