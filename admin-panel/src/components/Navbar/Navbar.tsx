import { type FC, useEffect, useState } from "react";
import { Bell, Menu, Settings, User, X } from "lucide-react";
import "./Navbar.css";
import Theme from "../Theme/Theme";
import UserModal from "../UserModal/UserModal";
import SettingsModal from "../SettingsModal/SettingsModal";
import AlertModal from "../AlertModal/AlertModal";
import myImage from "../../assets/logo.png";
import { navItems } from "../../data/navItem";
import { NavLink } from "react-router-dom";
import type { User as UserType } from "../../types/types";
import { INITIAL_ROWS } from "../../data/initialRows";

type NavbarProps = {
  setWindowOpen: (open: boolean) => void;
};

const Navbar: FC<NavbarProps> = ({setWindowOpen }) => {
  const [menuOpen, setMenuOpen] = useState(false);
  const [userModalOpen, setUserModalOpen] = useState(false);
  const [settingsModalOpen, setSettingsModalOpen] = useState(false);
  const [alertModalOpen, setAlertModalOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState<UserType | null>(null);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") setMenuOpen(false);
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, []);

  useEffect(() => {
    if (!menuOpen) return;
    const prev = document.body.style.overflow;
    document.body.style.overflow = "hidden";
    return () => {
      document.body.style.overflow = prev;
    };
  }, [menuOpen]);

  function openNewEvent() {
    setWindowOpen(true);
    setMenuOpen(false);
  }

  function handleUserButtonClick() {
    // Get the current user (first user from initial data)
    const currentUser = INITIAL_ROWS[0];
    setSelectedUser(currentUser);
    setUserModalOpen(true);
    setMenuOpen(false);
  }

  function handleSettingsButtonClick() {
    setSettingsModalOpen(true);
    setMenuOpen(false);
  }

  function handleAlertButtonClick() {
    setAlertModalOpen(true);
    setMenuOpen(false);
  }

  return (
    <div className={`navbar-shell ${menuOpen ? "menu-open" : ""}`}>
      <header className="navbar">
        <button
          type="button"
          id="nav-menu-toggle"
          className="nav-menu-toggle icon"
          aria-expanded={menuOpen}
          aria-controls="nav-primary"
          aria-label={menuOpen ? "סגור תפריט" : "פתח תפריט"}
          onClick={() => setMenuOpen((o) => !o)}
        >
          {menuOpen ? <X size={20} /> : <Menu size={20} />}
        </button>

        <div className="nav-left">
          <Theme />
          <button
            type="button"
            className="icon nav-desktop-only"
            aria-label="חשבון"
            onClick={handleUserButtonClick}
          >
            <User size={18} />
          </button>
          <button
            type="button"
            className="icon nav-desktop-only"
            aria-label="התראות"
            onClick={handleAlertButtonClick}
          >
            <Bell size={18} />
          </button>
          <button
            type="button"
            className="icon nav-desktop-only"
            aria-label="הגדרות"
            onClick={handleSettingsButtonClick}
          >
            <Settings size={18} />
          </button>
        </div>

        <nav className="nav-center" id="nav-primary" aria-label="ניווט ראשי">
          <button type="button" onClick={openNewEvent} className="btnprimary">
            + אירוע חדש
          </button>

          {navItems.map((item, index) => (
            <NavLink to={item.route} key={index} className="link">
              <span>{item.label}</span>
              <span> {item.icon}</span>
            </NavLink>
          ))}

          <div className="nav-mobile-icons" aria-label="פעולות מהירות">
            <button type="button" className="icon" aria-label="חשבון" onClick={handleUserButtonClick}>
              <User size={18} />
            </button>
            <button type="button" className="icon" aria-label="התראות" onClick={handleAlertButtonClick}>
              <Bell size={18} />
            </button>
            <button type="button" className="icon" aria-label="הגדרות" onClick={handleSettingsButtonClick}>
              <Settings size={18} />
            </button>
          </div>
        </nav>

        <div className="nav-right">
          <span className="logo-text" />
          <img src={myImage} className="logo-icon" alt="" />
        </div>
      </header>

      <button
        type="button"
        className="nav-backdrop"
        aria-hidden={!menuOpen}
        tabIndex={-1}
        onClick={() => setMenuOpen(false)}
      />

      <UserModal
        open={userModalOpen}
        onClose={() => setUserModalOpen(false)}
        user={selectedUser}
      />

      <SettingsModal
        open={settingsModalOpen}
        onClose={() => setSettingsModalOpen(false)}
      />

      <AlertModal
        open={alertModalOpen}
        onClose={() => setAlertModalOpen(false)}
      />
    </div>
  );
};

export default Navbar;
