import { useEffect, useMemo, useState } from "react";
import "./Situation.css";
import Avatar from "../Avatar/Avatar";
import { Timestamp, StatusCell } from "../../utils/utils";
import { fetchUsers } from "../../services/usersService";
import type { ApiUserProfile, User } from "../../types/types";

type SortOrder = "asc" | "desc" | null;

const ROLE_LABELS: Record<string, string> = {
  rescuer: "מחלץ",
  admin: "מנהל",
  user: "משתמש",
};

const ROLE_COLORS: Record<string, string> = {
  rescuer: "#22c55e",
  admin: "#3b82f6",
  user: "#9e9e9e",
};

const toRow = (profile: ApiUserProfile): User => {
  const role = profile.role || "user";
  const hasLocation =
    profile.latitude !== null && profile.longitude !== null;
  return {
    id: profile.id,
    name: profile.username || profile.email,
    lastUpdate: "—",
    status: ROLE_LABELS[role] ?? role,
    event: null,
    info: hasLocation
      ? `${profile.email} · ${profile.latitude!.toFixed(4)}, ${profile.longitude!.toFixed(4)}`
      : profile.email,
    dotColor: ROLE_COLORS[role] ?? "#9e9e9e",
    dotType: "single",
    unread: 0,
  };
};

export default function Situation() {
  const [profiles, setProfiles] = useState<ApiUserProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [contactSearch, setContactSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("הכל");
  const [sortOrder, setSortOrder] = useState<SortOrder>(null);

  const loadUsers = async () => {
    setLoading(true);
    setError(null);
    const { data, error: fetchError } = await fetchUsers();
    setProfiles(data);
    setError(fetchError);
    setLoading(false);
  };

  useEffect(() => {
    loadUsers();
    const interval = window.setInterval(loadUsers, 30_000);
    return () => window.clearInterval(interval);
  }, []);

  const rows = useMemo(() => profiles.map(toRow), [profiles]);

  const parseDate = (value: any) => {
    if (!value) return 0;
    if (value instanceof Date) return value.getTime();
    if (typeof value === "number") return value;
    if (typeof value === "string") {
      const isoDate = new Date(value).getTime();
      if (!isNaN(isoDate)) return isoDate;
      const [datePart, timePart = "00:00"] = value.split(" ");
      const [day, month, year] = datePart.split("/").map(Number);
      const [hours, minutes] = timePart.split(":").map(Number);
      const d = new Date(year, month - 1, day, hours, minutes).getTime();
      if (!isNaN(d)) return d;
    }
    return 0;
  };

  const filtered = rows.filter((row) => {
    const query = contactSearch.toLowerCase();
    const matchesContact =
      query === "" || row.name.toLowerCase().includes(query);
    const matchesStatus =
      statusFilter === "הכל" || row.status?.includes(statusFilter);
    return matchesContact && matchesStatus;
  });

  const sorted = [...filtered].sort((a, b) => {
    if (!sortOrder) return 0;
    const dateA = parseDate(a.lastUpdate);
    const dateB = parseDate(b.lastUpdate);
    return sortOrder === "asc" ? dateA - dateB : dateB - dateA;
  });

  const toggleSort = () => {
    if (sortOrder === "asc") setSortOrder("desc");
    else if (sortOrder === "desc") setSortOrder(null);
    else setSortOrder("asc");
  };

  const getSortSymbol = () =>
    sortOrder === "asc" ? "▲" : sortOrder === "desc" ? "▼" : "";

  return (
    <div className="situation">
      <div className="situation__header">
        <span className="situation__title">סטטוס</span>
        <div className="situation__header-right">
          <span className="situation__count">
            {loading ? "טוען..." : `${rows.length} משתמשים`}
          </span>
          <button
            type="button"
            className="situation__refresh"
            onClick={loadUsers}
            disabled={loading}
          >
            רענן
          </button>
        </div>
      </div>

      {error && <div className="situation__error">שגיאה: {error}</div>}

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
                    <option>מחלץ</option>
                    <option>משתמש</option>
                    <option>מנהל</option>
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
            {loading && rows.length === 0 && (
              <tr>
                <td colSpan={5} className="situation__empty">
                  טוען משתמשים...
                </td>
              </tr>
            )}

            {!loading && !error && sorted.length === 0 && (
              <tr>
                <td colSpan={5} className="situation__empty">
                  אין משתמשים להצגה
                </td>
              </tr>
            )}

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
                <td
                  className="situation__cell situation__cell--info"
                  data-label="מידע"
                >
                  <div className="situation__info-value">
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
