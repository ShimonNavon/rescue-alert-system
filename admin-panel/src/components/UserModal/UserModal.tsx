import type { FC } from "react";
import { X } from "lucide-react";
import type { User } from "../../types/types";
import "./UserModal.css";

type Props = {
  open: boolean;
  onClose: () => void;
  user: User | null;
};

const UserModal: FC<Props> = ({ open, onClose, user }) => {
  if (!open || !user) return null;

  return (
    <div className="user-modal-overlay" onClick={onClose}>
      <div className="user-modal" onClick={(e) => e.stopPropagation()}>
        {/* HEADER */}
        <div className="user-modal-header">
          <button
            type="button"
            className="user-modal-close-btn"
            onClick={onClose}
            aria-label="סגור"
          >
            <X size={20} />
          </button>
          <h2 className="user-modal-title">פרטי משתמש</h2>
        </div>

        {/* BODY */}
        <div className="user-modal-body">
          <div className="user-detail-row">
            <span className="user-detail-value">{user.name}</span>
            <span className="user-detail-label">שם</span>
          </div>

          <div className="user-detail-row">
            <span className="user-detail-value">
              {user.status || "לא זמין"}
            </span>
            <span className="user-detail-label">מצב</span>
          </div>

          <div className="user-detail-row">
            <span className="user-detail-value">{user.lastUpdate || "-"}</span>
            <span className="user-detail-label">עדכון אחרון</span>
          </div>

          {user.event && (
            <div className="user-detail-row">
              <span className="user-detail-value">{user.event.label}</span>
              <span className="user-detail-label">אירוע</span>
            </div>
          )}

          {user.info && (
            <div className="user-detail-row">
              <span className="user-detail-label">מידע נוסף:</span>
              <span className="user-detail-value">{user.info}</span>
            </div>
          )}
        </div>

        {/* FOOTER */}
        <div className="user-modal-footer">
          <button type="button" className="btn-secondary" onClick={onClose}>
            סגור
          </button>
        </div>
      </div>
    </div>
  );
};

export default UserModal;
