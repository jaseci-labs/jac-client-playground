import theme from "./tailwind.theme.js";

export default {
  content: [
    "./app.jac",
    "./app.cl.jac",
    "./components/**/*.{jac,js,jsx,ts,tsx}",
    "./pages/**/*.{jac,js,jsx,ts,tsx}",
    "./hooks/**/*.{jac,js,jsx,ts,tsx}",
    "./lib/**/*.{jac,js,jsx,ts,tsx}",
  ],
  theme: {
    extend: theme.extend,
  },
  plugins: [],
};
