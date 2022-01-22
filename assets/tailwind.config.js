module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      backgroundOpacity: {
        '98': '0.98',
      },
      minHeight: {
        '40': '10rem',
        '60': '15rem',
        '80': '20rem',
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],
}
