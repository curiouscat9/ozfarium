import topbar from "topbar"

const Hooks = {}

const scrollTop = () => {
  return document.documentElement.scrollTop || document.body.scrollTop
}

const getCurrentScroll = () => {
  const scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  const clientHeight = document.documentElement.clientHeight

  return scrollTop() / (scrollHeight - clientHeight) * 100
}

Hooks.InfiniteScroll = {
  page() { return parseInt(this.el.dataset.page) },
  last_page() { return parseInt(this.el.dataset.last) },
  mounted() {
    window.stickyOffset = document.getElementById('sticky-nav').offsetTop;

    document.getElementById('pagination').onclick = function() {
      if (scrollTop() > window.stickyOffset) {
        window.scrollTo({ top: window.stickyOffset })
      }
    }

    document.getElementById('filter').onclick = function() {
      if (scrollTop() > window.stickyOffset) {
        window.scrollTo({ top: window.stickyOffset })
      }
    }

    /* infinite scroll */
    this.pending = this.page()
    window.addEventListener("scroll", _e => {
      if (this.pending == this.page() && getCurrentScroll() > 90 && this.page() < this.last_page()) {
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
    document.querySelector(".current-ozfa").scrollIntoView(false)
  },
  updated() {
    document.querySelector(".current-ozfa").scrollIntoView(false)
  }
}

export default Hooks
