import { type FC, useEffect, useState } from "react";
import { X, AlertCircle, AlertTriangle, Info } from "lucide-react";
import "./AlertModal.css";
import { fetchAlerts } from "../../services/alertsService";
import type { ApiAlert } from "../../types/types";

type Props = {
  open: boolean;
  onClose: () => void;
};

const severityClass = (priority: ApiAlert["priority"]) => {
  if (priority === "CRITICAL" || priority === "HIGH") return "error";
  if (priority === "MEDIUM") return "warning";
  return "info";
};

const priorityIcon = (priority: ApiAlert["priority"]) => {
  const className = `alert-icon ${severityClass(priority)}`;
  if (priority === "CRITICAL" || priority === "HIGH") {
    return <AlertCircle size={20} className={className} />;
  }
  if (priority === "MEDIUM") {
    return <AlertTriangle size={20} className={className} />;
  }
  return <Info size={20} className={className} />;
};

const AlertModal: FC<Props> = ({ open, onClose }) => {
  const [alerts, setAlerts] = useState<ApiAlert[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedAlert, setSelectedAlert] = useState<ApiAlert | null>(null);

  useEffect(() => {
    if (!open) return;

    const loadAlerts = async () => {
      setLoading(true);
      setError(null);
      const { data, error: fetchError } = await fetchAlerts();
      if (fetchError) {
        setError(fetchError);
      } else {
        setAlerts(data);
      }
      setLoading(false);
    };

    loadAlerts();
  }, [open]);

  if (!open) return null;

  return (
    <div className="modal-overlay">
      <div className="alert-modal">
        <div className="modal-header">
          <h2 className="modal-title">התראות</h2>
          <button
            type="button"
            className="close-btn"
            onClick={onClose}
            aria-label="סגור"
          >
            <X size={24} />
          </button>
        </div>

        <div className="alert-modal-body">
          {loading && <div className="loading">טוען...</div>}

          {error && <div className="error-message">שגיאה: {error}</div>}

          {!loading && !error && alerts.length === 0 && (
            <div className="no-alerts">אין התראות</div>
          )}

          {!loading && !error && alerts.length > 0 && !selectedAlert && (
            <div className="alerts-list">
              {alerts.map((alert) => (
                <div
                  key={alert.id}
                  className={`alert-item ${severityClass(alert.priority)}`}
                  onClick={() => setSelectedAlert(alert)}
                >
                  <div className="alert-item-icon">
                    {priorityIcon(alert.priority)}
                  </div>
                  <div className="alert-item-content">
                    <h3>{alert.title}</h3>
                    <p>{alert.description || "—"}</p>
                    <span className="alert-time">
                      {new Date(alert.created_at).toLocaleString("he-IL")}
                    </span>
                  </div>
                  <span
                    className={`severity-badge ${alert.priority.toLowerCase()}`}
                  >
                    {alert.priority}
                  </span>
                </div>
              ))}
            </div>
          )}

          {selectedAlert && (
            <div className="alert-detail">
              <button
                type="button"
                className="back-btn"
                onClick={() => setSelectedAlert(null)}
              >
                ← חזור
              </button>
              <div className="detail-header">
                <div className="detail-icon">
                  {priorityIcon(selectedAlert.priority)}
                </div>
                <div className="detail-title-section">
                  <h2>{selectedAlert.title}</h2>
                  <span
                    className={`severity-badge ${selectedAlert.priority.toLowerCase()}`}
                  >
                    {selectedAlert.priority}
                  </span>
                </div>
              </div>

              <div className="detail-content">
                <div className="detail-field">
                  <label>תיאור:</label>
                  <p>{selectedAlert.description || "—"}</p>
                </div>

                <div className="detail-field">
                  <label>זמן:</label>
                  <p>
                    {new Date(selectedAlert.created_at).toLocaleString("he-IL")}
                  </p>
                </div>

                <div className="detail-field">
                  <label>סטטוס:</label>
                  <p>{selectedAlert.status}</p>
                </div>

                <div className="detail-field">
                  <label>מיקום:</label>
                  <p>
                    {selectedAlert.latitude.toFixed(5)},{" "}
                    {selectedAlert.longitude.toFixed(5)}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        <div className="modal-footer">
          <button className="btn btn-secondary" onClick={onClose}>
            סגור
          </button>
        </div>
      </div>
    </div>
  );
};

export default AlertModal;
