import type { FC } from "react";
import { X } from "lucide-react";
import "./SettingsModal.css";

type Props = {
  open: boolean;
  onClose: () => void;
};

const SettingsModal: FC<Props> = ({ open, onClose }) => {
  if (!open) return null;

  return (
    <div className="settings-modal-overlay" onClick={onClose}>
      <div className="settings-modal" onClick={(e) => e.stopPropagation()}>
        {/* HEADER */}
        <div className="settings-modal-header">
          <button
            type="button"
            className="settings-modal-close-btn"
            onClick={onClose}
            aria-label="סגור"
          >
            <X size={20} />
          </button>
          <h2 className="settings-modal-title">הגדרות</h2>
        </div>

        {/* BODY */}
        <div className="settings-modal-body">
          {/* Theme Setting */}
          <div className="settings-item">
            <label className="settings-label">עיצוב</label>
            <select className="settings-input">
              <option value="auto">אוטומטי</option>
              <option value="light">בהיר</option>
              <option value="dark">אפל</option>
            </select>
          </div>

          {/* Language Setting */}
          <div className="settings-item">
            <label className="settings-label">שפה</label>
            <select className="settings-input">
              <option value="he">עברית</option>
              <option value="en" disabled>
                אנגלית
              </option>
            </select>
          </div>

          {/* Notifications Setting */}
          <div className="settings-item">
            <label className="settings-label">הודעות</label>
            <input
              type="checkbox"
              className="settings-checkbox"
              defaultChecked={true}
            />
          </div>

          {/* Sound Setting */}
          <div className="settings-item">
            <label className="settings-label">סאונד</label>
            <input
              type="checkbox"
              className="settings-checkbox"
              defaultChecked={true}
            />
          </div>
        </div>

        {/* FOOTER */}
        <div className="settings-modal-footer">
          <button type="button" className="btn-primary" onClick={onClose}>
            שמור
          </button>
          <button type="button" className="btn-secondary" onClick={onClose}>
            סגור
          </button>
        </div>
      </div>
    </div>
  );
};

export default SettingsModal;
