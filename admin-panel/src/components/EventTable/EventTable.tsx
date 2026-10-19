import { useEffect, useMemo, useState } from "react";
import type { FC } from "react";
import "./EventTable.css";
import Avatar from "../Avatar/Avatar";
import { fetchAlerts } from "../../services/alertsService";
import type {
  ApiAlert,
  ApiAlertPriority,
  ApiAlertStatus,
  EventItem,
  OriginEventStatus,
} from "../../types/types";

interface EventTableProps {
  onSelect?: (id: number) => void;
  onAction?: (id: number, action: string) => void;
}

type EventRow = EventItem & {
  statusLabel: string;
  priorityLabel: string;
  description: string;
};

const STATUS_MAP: Record<
  ApiAlertStatus,
  { ui: OriginEventStatus; label: string }
> = {
  OPEN: { ui: "opened", label: "פתוח" },
  DISPATCHED: { ui: "assigned", label: "נשלח" },
  ACCEPTED: { ui: "assigned", label: "אושר" },
  IN_PROGRESS: { ui: "arrived", label: "בטיפול" },
  RESOLVED: { ui: "solved", label: "נפתר" },
  CANCELLED: { ui: "closed", label: "בוטל" },
};

const PRIORITY_MAP: Record<
  ApiAlertPriority,
  { ui: EventItem["priority"]; label: string }
> = {
  LOW: { ui: "low", label: "נמוך" },
  MEDIUM: { ui: "medium", label: "בינוני" },
  HIGH: { ui: "high", label: "גבוה" },
  CRITICAL: { ui: "critical", label: "קריטי" },
};

const formatAge = (iso: string) => {
  const seconds = Math.max(
    0,
    Math.floor((Date.now() - new Date(iso).getTime()) / 1000),
  );
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remaining = seconds % 60;
  return [hours, minutes, remaining]
    .map((value) => String(value).padStart(2, "0"))
    .join(":");
};

const EventTable: FC<EventTableProps> = ({ onSelect, onAction }) => {
  const [alerts, setAlerts] = useState<ApiAlert[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [filters, setFilters] = useState({
    title: "",
    location: "",
    status: "all",
    priority: "all",
    time: "",
    user: "",
    action: "all",
  });

  const loadAlerts = async () => {
    setLoading(true);
    setError(null);
    const { data, error: fetchError } = await fetchAlerts();
    setAlerts(data);
    setError(fetchError);
    setLoading(false);
  };

  useEffect(() => {
    loadAlerts();
    const interval = window.setInterval(loadAlerts, 30_000);
    return () => window.clearInterval(interval);
  }, []);

  const handleChange = (key: string, value: string) => {
    setFilters((prev) => ({ ...prev, [key]: value }));
  };

  const rows: EventRow[] = useMemo(
    () =>
      alerts.map((alert) => {
        const status = STATUS_MAP[alert.status];
        const priority = PRIORITY_MAP[alert.priority];
        return {
          id: alert.id,
          title: alert.title,
          description: alert.description,
          location: `${alert.latitude.toFixed(4)}, ${alert.longitude.toFixed(4)}`,
          status: status.ui,
          statusLabel: status.label,
          priority: priority.ui,
          priorityLabel: priority.label,
          time: formatAge(alert.created_at),
          user: "מוקד",
        };
      }),
    [alerts],
  );

  const filteredEvents = useMemo(() => {
    return rows.filter((event) => {
      const matchesAction =
        filters.action === "all" ||
        (filters.action === "opened" && event.status === "opened") ||
        (filters.action === "closed" && event.status === "closed");

      return (
        (filters.title === "" ||
          event.title.toLowerCase().includes(filters.title.toLowerCase())) &&
        (filters.location === "" ||
          event.location
            .toLowerCase()
            .includes(filters.location.toLowerCase())) &&
        (filters.status === "all" || event.status === filters.status) &&
        (filters.priority === "all" || event.priority === filters.priority) &&
        (filters.time === "" ||
          event.time.toLowerCase().includes(filters.time.toLowerCase())) &&
        (filters.user === "" ||
          event.user.toLowerCase().includes(filters.user.toLowerCase())) &&
        matchesAction
      );
    });
  }, [filters, rows]);

  return (
    <div className="table-wrapper" dir="rtl">
      <div className="event-table-toolbar">
        <span>
          {loading ? "טוען..." : `${filteredEvents.length} אירועים`}
        </span>
        <button type="button" onClick={loadAlerts} disabled={loading}>
          רענן
        </button>
      </div>

      {error && <div className="event-table-error">שגיאה: {error}</div>}

      <table className="event-table">
        <thead>
          <tr>
            <th></th>
            <th>אירוע</th>
            <th>מיקום</th>
            <th>סטטוס</th>
            <th>עדיפות</th>
            <th>משך זמן</th>
            <th>משתמש</th>
            <th>פעולות</th>
          </tr>

          <tr className="filters">
            <th className="filter-cell filter-cell--clear">
              <button
                type="button"
                className="clear-btn"
                onClick={() =>
                  setFilters({
                    title: "",
                    location: "",
                    status: "all",
                    priority: "all",
                    time: "",
                    user: "",
                    action: "all",
                  })
                }
              >
                נקה
              </button>
            </th>

            <th className="filter-cell" data-label="אירוע">
              <input
                placeholder="חפש..."
                onChange={(e) => handleChange("title", e.target.value)}
              />
            </th>

            <th className="filter-cell" data-label="מיקום">
              <input
                placeholder="חפש..."
                onChange={(e) => handleChange("location", e.target.value)}
              />
            </th>

            <th className="filter-cell" data-label="סטטוס">
              <select onChange={(e) => handleChange("status", e.target.value)}>
                <option value="all">הכל</option>
                <option value="opened">פתוח</option>
                <option value="assigned">משוייך</option>
                <option value="arrived">בטיפול</option>
                <option value="solved">נפתר</option>
                <option value="closed">סגור</option>
              </select>
            </th>

            <th className="filter-cell" data-label="עדיפות">
              <select
                onChange={(e) => handleChange("priority", e.target.value)}
              >
                <option value="all">הכל</option>
                <option value="critical">קריטי</option>
                <option value="high">גבוה</option>
                <option value="medium">בינוני</option>
                <option value="low">נמוך</option>
              </select>
            </th>

            <th className="filter-cell" data-label="משך זמן">
              <input
                placeholder="00:00"
                onChange={(e) => handleChange("time", e.target.value)}
              />
            </th>

            <th className="filter-cell" data-label="משתמש">
              <input
                placeholder="משתמש"
                onChange={(e) => handleChange("user", e.target.value)}
              />
            </th>
            <th className="filter-cell" data-label="פעולות">
              <select onChange={(e) => handleChange("action", e.target.value)}>
                <option value="all">הכל</option>
                <option value="opened">פתוחים</option>
                <option value="closed">סגורים</option>
              </select>
            </th>
          </tr>
        </thead>

        <tbody>
          {loading && rows.length === 0 && (
            <tr>
              <td colSpan={8} className="event-table-empty">
                טוען אירועים...
              </td>
            </tr>
          )}

          {!loading && !error && filteredEvents.length === 0 && (
            <tr>
              <td colSpan={8} className="event-table-empty">
                אין אירועים להצגה
              </td>
            </tr>
          )}

          {filteredEvents.map((event) => (
            <tr key={event.id}>
              <td className="cell-select">
                <input
                  type="radio"
                  name="selectedEvent"
                  onChange={() => onSelect?.(event.id)}
                  aria-label="בחר אירוע"
                />
              </td>

              <td data-label="אירוע" title={event.description}>
                {event.title}
              </td>
              <td data-label="מיקום">{event.location}</td>

              <td data-label="סטטוס">
                <span className={`badge status ${event.status}`}>
                  {event.statusLabel}
                </span>
              </td>

              <td data-label="עדיפות">
                <span className={`badge priority ${event.priority}`}>
                  {event.priorityLabel}
                </span>
              </td>

              <td data-label="משך זמן">{event.time}</td>
              <td className="combineAvatar" data-label="משתמש">
                <span className="events_avatar">
                  <Avatar row={{ name: event.user }} />
                  {event.user}
                </span>
              </td>

              <td className="actions" data-label="פעולות">
                <button
                  type="button"
                  className="action-btn view"
                  onClick={() => onAction?.(event.id, "view")}
                >
                  צפייה
                </button>
                <button
                  type="button"
                  className="action-btn close"
                  onClick={() => onAction?.(event.id, "close")}
                >
                  סגור
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
};

export default EventTable;
