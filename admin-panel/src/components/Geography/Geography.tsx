import { useEffect, useMemo, useState } from "react";
import SidePanel from "../PTT/SidePanel/SidePanel";
import "./Geography.css";
import MapComponent, { type MapMarker } from "../Map/Map";
import { fetchAlerts } from "../../services/alertsService";
import { fetchUsers } from "../../services/usersService";
import type { ApiAlert, ApiUserProfile } from "../../types/types";

const DEFAULT_CENTER: [number, number] = [32.0853, 34.7818];

export default function Geography() {
  const [alerts, setAlerts] = useState<ApiAlert[]>([]);
  const [users, setUsers] = useState<ApiUserProfile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const loadData = async () => {
    setLoading(true);
    setError(null);
    const [alertsResult, usersResult] = await Promise.all([
      fetchAlerts(),
      fetchUsers(),
    ]);
    setAlerts(alertsResult.data);
    setUsers(usersResult.data);
    setError(alertsResult.error || usersResult.error);
    setLoading(false);
  };

  useEffect(() => {
    loadData();
    const interval = window.setInterval(loadData, 30_000);
    return () => window.clearInterval(interval);
  }, []);

  const markers: MapMarker[] = useMemo(() => {
    const alertMarkers: MapMarker[] = alerts.map((alert) => ({
      id: `alert-${alert.id}`,
      lat: alert.latitude,
      lng: alert.longitude,
      label: `${alert.title} · ${alert.priority}`,
      kind: "alert",
    }));

    const userMarkers: MapMarker[] = users
      .filter(
        (user) => user.latitude !== null && user.longitude !== null,
      )
      .map((user) => ({
        id: `user-${user.id}`,
        lat: user.latitude as number,
        lng: user.longitude as number,
        label: `${user.username} · ${user.role}`,
        kind: "user",
      }));

    return [...alertMarkers, ...userMarkers];
  }, [alerts, users]);

  const center = useMemo<[number, number]>(() => {
    if (markers.length === 0) return DEFAULT_CENTER;
    return [markers[0].lat, markers[0].lng];
  }, [markers]);

  return (
    <div className="panelBoardApp">
      <SidePanel />
      <div className="geography-map">
        <div className="geography-map__toolbar">
          <span>
            {loading
              ? "טוען..."
              : `${alerts.length} אירועים · ${users.length} משתמשים`}
          </span>
          <button type="button" onClick={loadData} disabled={loading}>
            רענן
          </button>
        </div>
        {error && <div className="geography-map__error">שגיאה: {error}</div>}
        {loading && markers.length === 0 ? (
          <div className="geography-map__loading">טוען נתונים...</div>
        ) : (
          <MapComponent
            markers={markers}
            initialCenter={center}
            zoom={markers.length > 0 ? 11 : 13}
            height="calc(100vh - 170px)"
          />
        )}
      </div>
    </div>
  );
}
