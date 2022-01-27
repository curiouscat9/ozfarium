export const scrollTop = () => {
  return document.documentElement.scrollTop || document.body.scrollTop
}

export const getCurrentScroll = () => {
  const scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
  const clientHeight = document.documentElement.clientHeight

  return scrollTop() / (scrollHeight - clientHeight) * 100
}

export const scrollIntoView = (selector) => {
  if (document.querySelector(selector)) {
    document.querySelector(selector).scrollIntoView(false)
  }
}

export const openFullscreen = (elem) => {
  if (!elem) {
    false
  } else if (elem.requestFullscreen) {
    elem.requestFullscreen();
  } else if (elem.webkitRequestFullscreen) { /* Safari */
    elem.webkitRequestFullscreen();
  } else if (elem.msRequestFullscreen) { /* IE11 */
    elem.msRequestFullscreen();
  }
}

export const closeFullscreen = () => {
  if (document.exitFullscreen) {
    document.exitFullscreen();
  } else if (document.webkitExitFullscreen) { /* Safari */
    document.webkitExitFullscreen();
  } else if (document.msExitFullscreen) { /* IE11 */
    document.msExitFullscreen();
  }
}
