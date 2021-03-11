import topbar from "topbar"

const Hooks = {}

const getCurrentScroll = () => {
  const scrollTop = document.documentElement.scrollTop || document.body.scrollTop
  const scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  const clientHeight = document.documentElement.clientHeight

  return scrollTop / (scrollHeight - clientHeight) * 100
}

Hooks.InfiniteScroll = {
  page() { return this.el.dataset.page },
  mounted() {
    var navbar = document.getElementById('sticky-nav');
    var stickyOffset = navbar.offsetTop;

    window.onscroll = function() {
      if (window.pageYOffset >= stickyOffset) {
        navbar.classList.add("sticky")
      } else {
        navbar.classList.remove("sticky");
      }
    }
    navbar.onclick = function() {
      window.scrollTo({ top: stickyOffset });
    }

    this.pending = this.page()
    window.addEventListener("scroll", _e => {
      if (this.pending == this.page() && getCurrentScroll() > 90) {
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

export default Hooks
