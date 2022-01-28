import topbar from "topbar"
import {
  scrollTop,
  getCurrentScroll,
  scrollIntoView,
  openFullscreen,
  closeFullscreen } from "./utils"

const Hooks = {}

Hooks.InfiniteScroll = {
  page() { return parseInt(this.el.dataset.page) },
  last_page() { return parseInt(this.el.dataset.last) },
  mounted() {
    window.stickyOffset = document.getElementById('sticky-nav').offsetTop;

    document.querySelectorAll('#pagination, #filter').forEach(el => {
      el.onclick = function() {
        if (scrollTop() > window.stickyOffset) {
          window.scrollTo({ top: window.stickyOffset })
        }
      }
    })

    /* infinite scroll */
    this.pending = this.page()
    window.addEventListener("scroll", _e => {
      if (this.pending == this.page() &&
          getCurrentScroll() > 90 &&
          this.page() < this.last_page() &&
          !document.querySelector('body').classList.contains('overflow-y-hidden')) {
        this.pending = this.page() + 1
        topbar.show()
        this.pushEvent("load-more", {})
      }
    })
  },
  updated(){
    this.pending = this.page()
    topbar.hide()
  },
  reconnected(){ this.pending = this.page() }
}

Hooks.OpenModal = {
  mounted() {
    document.querySelector('body').classList.add('overflow-y-hidden')
  },
  destroyed() {
    document.querySelector('body').classList.remove('overflow-y-hidden')
    scrollIntoView(".current-ozfa")
  },
  updated() {
    scrollIntoView(".current-ozfa")
  }
}

Hooks.ViewImage = {
  beforeUpdate() {
    this.el.src = "";
  }
}

Hooks.ViewOzfa = {
  mounted() {
    recalculateCSSvh()
    window.addEventListener('resize', recalculateCSSvh)

    initOzfaFullscreenButtons()
  },
  updated() {
    initOzfaFullscreenButtons()
  },
  destroyed() {
    document.documentElement.style.removeProperty('--vh')
    closeFullscreen()
  },
}

recalculateCSSvh = () => {
  document.documentElement.style.setProperty('--vh', `${window.innerHeight * 0.01}px`);
}

initOzfaFullscreenButtons = () => {
  document.querySelectorAll('#view-ozfa .open-full-screen').forEach(el => {
    el.onclick = function() {
      openFullscreen(document.getElementById('view-ozfa'))
    }
  })

  document.querySelectorAll('#view-ozfa .close-full-screen').forEach(el => {
    el.onclick = function() {
      closeFullscreen()
    }
  })
}

showOzfaControls = () => {
  document.getElementById("view-ozfa-controls").classList.remove("hidden")
}

hideOzfaControls = () => {
  document.getElementById("view-ozfa-controls").classList.add("hidden")
}

export default Hooks
