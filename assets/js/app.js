// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"

let Hooks = {}

Hooks.TestTimer = {
  mounted() {
    const zeroPad = (num) => String(num).padStart(2, '0')

    const endsAt = new Date(this.el.dataset.endsAt)

    let setContent = () => {
      const seconds = Math.floor((endsAt - new Date()) / 1000 + 1)

      this.el.textContent = [Math.floor(seconds / 60), seconds % 60].map(zeroPad).join(":")
    }

    setContent()
    setInterval(setContent, 1000);
  }
}

Hooks.LinkCopier = {
  mounted() {
    const link =
      window.location.protocol
      + "//"
      + window.location.host
      + this.el.dataset.link

    this.el.addEventListener("click", () => {
      navigator.clipboard.writeText(link)
      this.pushEvent("link-copied")
    })
  }
}

Hooks.Proctor = {
  mounted() {
    const stopCheating = () => this.pushEvent("stop-cheating", {})
    const startCheating = () => this.pushEvent("start-cheating", {})
    const isMobile = 'ontouchstart' in document.documentElement;

    let ratioCheated = false

    function checkWindowRatio() {
      const ratio = Math.min(window.innerWidth, window.innerHeight) / Math.max(window.innerWidth, window.innerHeight)

      if (ratio > 0.80) {
        startCheating()
        ratioCheated = true
      }
      else if (ratioCheated)
        stopCheating()

      document.querySelector("#proctor").textContent = ratio
    }

    window.addEventListener("focus", () => stopCheating())
    window.addEventListener("blur", () => startCheating())
    if (isMobile) {
      window.addEventListener("resize", () => checkWindowRatio())
      checkWindowRatio()
    }
  }}

Hooks.TimeZoneGetter = {
  mounted() {
    this.el.value = Intl.DateTimeFormat().resolvedOptions().timeZone
  }
}

Hooks.DateTimeWithTZSetter = {
  updateTime() {
    function getLocalISOString(date) {
      const offset = date.getTimezoneOffset()
      const isoString = new Date(date.getTime() - offset * 60 * 1000).toISOString()
      return isoString.split(".")[0]
    }

    function zeroPad(num) {
      return String(num).padStart(2, '0')
    }

    function formatDateTime(date) {
      const hours = zeroPad(date.getHours())
      const minutes = zeroPad(date.getMinutes())
      const day = zeroPad(date.getDate())
      const month = zeroPad(date.getMonth() + 1)
      const year = date.getFullYear()
      return `${hours}:${minutes} ${day}.${month}.${year}`
    }

    const isInput = this.el.tagName === "INPUT"
    const datetimeAttribute = this.el.dataset.datetime

    if (this.el.value !== "" && isInput || !datetimeAttribute) return

    const datetime = new Date(datetimeAttribute)
    if (isInput)
      this.el.value = getLocalISOString(datetime)
    else
      this.el.textContent = formatDateTime(datetime)
  },
  mounted() { this.updateTime() },
  updated() { this.updateTime() },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks, params: { _csrf_token: csrfToken } })

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

