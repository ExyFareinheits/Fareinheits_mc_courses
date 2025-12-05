/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      screens: {
        'xs': '480px', // Extra small devices
      },
      colors: {
        minecraft: {
          grass: '#7CBD6B',
          dirt: '#8B6F47',
          stone: '#7F8285',
          wood: '#9C7B4E',
          gold: '#FCEE4B',
          diamond: '#5ECFED',
          emerald: '#17DD62',
          obsidian: '#1B1B29',
          lava: '#FF6B35',
          water: '#3F76E4',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        display: ['"Space Grotesk"', 'sans-serif'],
      },
      backgroundImage: {
        'minecraft-pattern': "url('data:image/svg+xml,%3Csvg width=\"16\" height=\"16\" xmlns=\"http://www.w3.org/2000/svg\",%3E%3Cpath d=\"M0 0h8v8H0zM8 8h8v8H8z\" fill=\"%23000\" fill-opacity=\".02\"/%3E%3C/svg%3E')",
      },
      animation: {
        'fade-in': 'fadeIn 0.5s ease-in',
        'fade-in-up': 'fadeInUp 0.5s ease-out',
        'spin-slow': 'spin 3s linear infinite',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        fadeInUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
  plugins: [],
}
