import { useState } from "react";
import "./Situation.css";
import { INITIAL_ROWS } from "../../data/initialRows";
import Avatar from "../Avatar/Avatar";
import { Timestamp, StatusCell } from "../../utils/utils";

type SortOrder = "asc" | "desc" | null;

export default function Situation() {
  const [contactSearch, setContactSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("הכל");
  const [sortOrder, setSortOrder] = useState<SortOrder>(null);

  // Robust parser: handles Date object, ISO string, or "DD/MM/YYYY HH:mm"
  const parseDate = (value: any) => {
    if (!value) return 0;

    if (value instanceof Date) return value.getTime();
    if (typeof value === "number") return value;

    if (typeof value === "string") {
      // ISO format
      const isoDate = new Date(value).getTime();
      if (!isNaN(isoDate)) return isoDate;

      // DD/MM/YYYY HH:mm format
      const [datePart, timePart = "00:00"] = value.split(" ");
      const [day, month, year] = datePart.split("/").map(Number);
      const [hours, minutes] = timePart.split(":").map(Number);
      const d = new Date(year, month - 1, day, hours, minutes).getTime();
      if (!isNaN(d)) return d;

      // fallback
      return 0;
    }

    return 0;
  };

  // Filter rows
  const filtered = INITIAL_ROWS.filter((row) => {
    const cq = contactSearch.toLowerCase();
    const matchesContact = cq === "" || row.name.toLowerCase().includes(cq);
    const matchesStatus =
      statusFilter === "הכל" || row?.status?.includes(statusFilter);
    return matchesContact && matchesStatus;
  });

  // Sort rows by lastUpdate
  const sorted = [...filtered].sort((a, b) => {
    if (!sortOrder) return 0;
    const dateA = parseDate(a.lastUpdate);
    const dateB = parseDate(b.lastUpdate);
    return sortOrder === "asc" ? dateA - dateB : dateB - dateA;
  });

  // Toggle sort order
  const toggleSort = () => {
    if (sortOrder === "asc") setSortOrder("desc");
    else if (sortOrder === "desc") setSortOrder(null);
    else setSortOrder("asc");
  };

  const getSortSymbol = () =>
    sortOrder === "asc" ? "▲" : sortOrder === "desc" ? "▼" : "";

  return (
    <div className="situation">
      {/* Header */}
      <div className="situation__header">
        <span className="situation__title">סטטוס</span>
        <span className="situation__count">{INITIAL_ROWS.length} פריטים</span>
      </div>

      {/* Table */}
      <div className="situation__table-scroll">
        <table className="situation__table">
          <thead>
            <tr className="situation__filters">
              <th className="situation__filter-th situation__filter-th--search">
                <div className="situation__col-cell">
                  <input
                    type="text"
                    placeholder="חפש איש קשר"
                    className="situation__col-input"
                    value={contactSearch}
                    onChange={(e) => setContactSearch(e.target.value)}
                  />
                </div>
              </th>
              <th className="situation__filter-th situation__filter-th--sort">
                <div
                  className="situation__col-cell situation__col-cell--sort"
                  style={{ cursor: "pointer" }}
                  onClick={toggleSort}
                  onKeyDown={(e) => {
                    if (e.key === "Enter" || e.key === " ") {
                      e.preventDefault();
                      toggleSort();
                    }
                  }}
                  role="button"
                  tabIndex={0}
                >
                  עדכון אחרון {getSortSymbol()}
                </div>
              </th>
              <th className="situation__filter-th situation__filter-th--status">
                <div className="situation__col-cell">
                  <select
                    value={statusFilter}
                    className="situation__col-select"
                    onChange={(e) => setStatusFilter(e.target.value)}
                  >
                    <option>הכל</option>
                    <option>לא פעיל</option>
                    <option>זמין</option>
                    <option>התנתק</option>
                    <option>לא התחבר</option>
                  </select>
                </div>
              </th>
              <th className="situation__filter-th situation__filter-th--label-only">
                <div className="situation__col-cell">אירועים</div>
              </th>
              <th className="situation__filter-th situation__filter-th--label-only">
                <div className="situation__col-cell">מידע</div>
              </th>
            </tr>
          </thead>

          <tbody>
            {sorted.map((row) => (
              <tr key={row.id} className="situation__row">
                <td className="situation__cell" data-label="איש קשר">
                  <span className="situation__cell-cluster">
                    <Avatar row={row} />
                    <span className="situation__contact-name">{row.name}</span>
                    {(row.unread ?? 0) > 0 && (
                      <span className="situation__unread">{row.unread}</span>
                    )}
                  </span>
                </td>
                <td className="situation__cell" data-label="עדכון אחרון">
                  <Timestamp value={row.lastUpdate} />
                </td>
                <td className="situation__cell" data-label="סטטוס">
                  <StatusCell status={row.status} />
                </td>
                <td className="situation__cell" data-label="אירועים">
                  {row.event && (
                    <div className="situation__event">
                      <span className="situation__event-label">
                        {row.event.label}
                      </span>
                    </div>
                  )}
                </td>
                <td className="situation__cell situation__cell--info" data-label="מידע">
                  <div className="situation__info-value">
                    {row.event?.badge && (
                      <span className="situation__badge--done">
                        {row.event.badge}
                      </span>
                    )}
                    <span>{row.info}</span>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}