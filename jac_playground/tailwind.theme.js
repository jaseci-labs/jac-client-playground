const palette = {
  background: "hsl(0 0% 100%)",
  foreground: "hsl(222.2 47.4% 11.2%)",
  card: {
    DEFAULT: "hsl(0 0% 100%)",
    foreground: "hsl(222.2 47.4% 11.2%)",
  },
  muted: {
    DEFAULT: "hsl(210 40% 96.1%)",
    foreground: "hsl(215.4 16.3% 46.9%)",
  },
  accent: {
    DEFAULT: "hsl(210 40% 96.1%)",
    foreground: "hsl(222.2 47.4% 11.2%)",
  },
  primary: {
    DEFAULT: "hsl(221.2 83.2% 53.3%)",
    foreground: "hsl(210 40% 98%)",
  },
  secondary: {
    DEFAULT: "hsl(210 40% 96.1%)",
    foreground: "hsl(222.2 47.4% 11.2%)",
  },
  border: "hsl(214.3 31.8% 91.4%)",
  input: "hsl(214.3 31.8% 91.4%)",
  ring: "hsl(221.2 83.2% 53.3%)",
  editor: {
    background: "hsl(222.2 47.4% 11.2%)",
    foreground: "hsl(210 40% 96%)",
  },
};

const theme = {
  extend: {
    colors: palette,
    borderColor: {
      DEFAULT: palette.border,
    },
    ringColor: {
      DEFAULT: palette.ring,
    },
  },
};

export { palette };
export default theme;
