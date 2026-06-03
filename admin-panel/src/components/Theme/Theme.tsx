import { useEffect, useState } from "react";
import "./Theme.css";

const Theme: React.FC = () => {
  // Initialize theme from localStorage or default to light
  const [theme, setTheme] = useState<"light" | "dark">(
    (localStorage.getItem("theme") as "light" | "dark") || "light"
  );

  // Apply theme to document root whenever it changes
  useEffect(() => {
    document.documentElement.setAttribute("data-theme", theme);
    localStorage.setItem("theme", theme);
  }, [theme]);

  // Toggle between light and dark
  const toggleTheme = () => {
    setTheme(theme === "light" ? "dark" : "light");
  };

  return (
    <button onClick={toggleTheme} className="theme-switcher">
      {theme === "light" ? "🌙" : "☀️"}
    </button>
  );
};

export default Theme;