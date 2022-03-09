// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration
module.exports = {
  content: [
    './js/**/*.js',
    '../lib/*_web.ex',
    '../lib/*_web/**/*.*ex'
  ],
  theme: {
    extend: {
      transitionProperty: ['visibility'],
      transitionDuration: {
          2000: '2000ms',
      },
      transitionDelay: {
          2000: '2000ms',
          5000: '5000ms',
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms')
  ]
}
