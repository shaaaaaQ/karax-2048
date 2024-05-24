/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.nim"],
  theme: {
    extend: {
      animation: {
        "fade-in": "fade-in 2s",
      },
      keyframes: {
        "fade-in": {
          from: { opacity: 0 },
          to: { opacity: 1 },
        },
      },
    },
  },
  plugins: [],
}

