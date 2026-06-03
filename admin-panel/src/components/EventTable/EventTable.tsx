import { useMemo, useState } from "react";
import type { FC } from "react";
import "./EventTable.css";
import { events } from "../../data/events";
import Avatar from "../Avatar/Avatar";

interface EventTableProps {
  onSelect?: (id: number) => void;
  onAction?: (id: number, action: string) => void;
}

const EventTable: FC<EventTableProps> = ({ onSelect, onAction }) => {
  const [filters, setFilters] = useState({
    title: "",
    location: "",
    status: "all",
    priority: "all",
    time: "",
    user: "",
    action: "all",
  });

  const handleChange = (key: string, value: string) => {
    setFilters((prev) => ({ ...prev, [key]: value }));
  };

  const filteredEvents = useMemo(() => {
    return events.filter((event) => {
      const matchesAction =
        filters.action === "all" ||
        (filters.action === "opened" && event.status === "opened") ||
        (filters.action === "closed" && event.status === "closed") ||
        (filters.action === "assigned" && event.status === "assigned") ||
        (filters.action === "arrived" && event.status === "arrived") ||
        (filters.action === "solved" && event.status === "solved");

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
  }, [filters]);

  return (
    <div className="table-wrapper" dir="rtl">
      <table className="event-table">
        <thead>
          {/* 🔹 HEADER LABELS */}
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

          {/* 🔹 FILTER ROW INSIDE HEADER */}
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
                <option value="arrived">הגיעה</option>
                <option value="solved">נפתר</option>
                <option value="closed">סגור</option>
              </select>
            </th>

            <th className="filter-cell" data-label="עדיפות">
              <select
                onChange={(e) => handleChange("priority", e.target.value)}
              >
                <option value="all">הכל</option>
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
                <option value="open">ניתן לסגור</option>
                <option value="closed">סגור בלבד</option>
              </select>
            </th>
          </tr>
        </thead>

        <tbody>
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

              <td data-label="אירוע">{event.title}</td>
              <td data-label="מיקום">{event.location}</td>

              <td data-label="סטטוס">
                <span className={`badge status ${event.status}`}>
                  {event.status}
                </span>
              </td>

              <td data-label="עדיפות">
                <span className={`badge priority ${event.priority}`}>
                  {event.priority}
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
