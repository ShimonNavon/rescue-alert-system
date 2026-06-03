import { type FC, useEffect, useState } from "react";
import { X, AlertCircle, AlertTriangle, Info, CheckCircle } from "lucide-react";
import "./AlertModal.css";
import { fetchAlerts } from "../../services/alertsService";
import type { Alert } from "../../types/types";

type Props = {
    open: boolean;
    onClose: () => void;
};

const AlertModal: FC<Props> = ({ open, onClose }) => {
    const [alerts, setAlerts] = useState<Alert[]>([]);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [selectedAlert, setSelectedAlert] = useState<Alert | null>(null);

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

    const getIconForType = (type: string) => {
        switch (type) {
            case "error":
                return <AlertCircle size={20} className="alert-icon error" />;
            case "warning":
                return <AlertTriangle size={20} className="alert-icon warning" />;
            case "success":
                return <CheckCircle size={20} className="alert-icon success" />;
            case "info":
            default:
                return <Info size={20} className="alert-icon info" />;
        }
    };

    if (!open) return null;

    return (
        <div className="modal-overlay">
            <div className="alert-modal">
                {/* HEADER */}
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

                {/* BODY */}
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
                                    className={`alert-item ${alert.type}`}
                                    onClick={() => setSelectedAlert(alert)}
                                >
                                    <div className="alert-item-icon">
                                        {getIconForType(alert.type)}
                                    </div>
                                    <div className="alert-item-content">
                                        <h3>{alert.title}</h3>
                                        <p>{alert.message}</p>
                                        <span className="alert-time">
                                            {new Date(alert.timestamp).toLocaleString(
                                                "he-IL"
                                            )}
                                        </span>
                                    </div>
                                    {alert.severity && (
                                        <span className={`severity-badge ${alert.severity}`}>
                                            {alert.severity}
                                        </span>
                                    )}
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
                                    {getIconForType(selectedAlert.type)}
                                </div>
                                <div className="detail-title-section">
                                    <h2>{selectedAlert.title}</h2>
                                    {selectedAlert.severity && (
                                        <span
                                            className={`severity-badge ${selectedAlert.severity}`}
                                        >
                                            {selectedAlert.severity}
                                        </span>
                                    )}
                                </div>
                            </div>

                            <div className="detail-content">
                                <div className="detail-field">
                                    <label>תיאור:</label>
                                    <p>{selectedAlert.message}</p>
                                </div>

                                <div className="detail-field">
                                    <label>זמן:</label>
                                    <p>
                                        {new Date(selectedAlert.timestamp).toLocaleString(
                                            "he-IL"
                                        )}
                                    </p>
                                </div>

                                <div className="detail-field">
                                    <label>סוג:</label>
                                    <p>{selectedAlert.type}</p>
                                </div>

                                {selectedAlert.read !== undefined && (
                                    <div className="detail-field">
                                        <label>סטטוס:</label>
                                        <p>{selectedAlert.read ? "נקרא" : "לא נקרא"}</p>
                                    </div>
                                )}

                                {Object.entries(selectedAlert).map(([key, value]) => {
                                    if (
                                        ![
                                            "id",
                                            "title",
                                            "message",
                                            "type",
                                            "timestamp",
                                            "read",
                                            "severity",
                                        ].includes(key)
                                    ) {
                                        return (
                                            <div key={key} className="detail-field">
                                                <label>
                                                    {key.charAt(0).toUpperCase() +
                                                        key.slice(1)}
                                                    :
                                                </label>
                                                <p>{String(value)}</p>
                                            </div>
                                        );
                                    }
                                    return null;
                                })}
                            </div>
                        </div>
                    )}
                </div>

                {/* FOOTER */}
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
