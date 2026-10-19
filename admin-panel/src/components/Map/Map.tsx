import { useState, type FC } from "react";
import { MapContainer, TileLayer, Marker, useMapEvents } from "react-leaflet";
import { divIcon, type LatLngExpression } from "leaflet";
import "leaflet/dist/leaflet.css";

export type MapMarker = {
  id: string;
  lat: number;
  lng: number;
  label: string;
  kind: "alert" | "user";
};

type MapProps = {
  onSelect?: (lat: number, lng: number) => void;
  initialCenter?: [number, number]; // [lat, lng]
  zoom?: number;
  height?: string | number;
  markers?: MapMarker[];
};

const DEFAULT_CENTER: [number, number] = [32.0853, 34.7818]; // Tel Aviv [lat, lng]

const alertIcon = divIcon({
  className: "",
  html: `<span style="font-size:30px; line-height:1; background:transparent;">🚨</span>`,
  iconSize: [30, 30],
  iconAnchor: [15, 30],
});

const userIcon = divIcon({
  className: "",
  html: `<span style="display:block;width:18px;height:18px;border-radius:50%;background:#22c55e;border:3px solid white;box-shadow:0 0 0 2px #22c55e;"></span>`,
  iconSize: [24, 24],
  iconAnchor: [12, 12],
});

const ClickableMarker: FC<{
  position: [number, number];
  onClick?: (lat: number, lng: number) => void;
  setPosition: (pos: [number, number]) => void;
}> = ({ position, onClick, setPosition }) => {
  const emojiIcon = divIcon({
    className: "",
    html: `<span style="font-size:32px; line-height:1; background:transparent;">🚩</span>`,
    iconSize: [32, 32],
    iconAnchor: [16, 32],
  });

  useMapEvents({
    click(e) {
      const coords: [number, number] = [e.latlng.lat, e.latlng.lng];
      setPosition(coords);
      onClick?.(coords[0], coords[1]);
    },
  });

  return <Marker position={position} icon={emojiIcon} />;
};

const MapComponent: FC<MapProps> = ({
  onSelect,
  initialCenter = DEFAULT_CENTER,
  zoom = 13,
  height = "650px",
  markers = [],
}) => {
  const [position, setPosition] = useState<LatLngExpression>(initialCenter);

  return (
    <div style={{ width: "100%", height }}>
      <MapContainer
        center={position}
        zoom={zoom}
        style={{ width: "100%", height: "100%" }}
      >
        <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
        {markers.map((marker) => (
          <Marker
            key={marker.id}
            position={[marker.lat, marker.lng]}
            icon={marker.kind === "alert" ? alertIcon : userIcon}
            title={marker.label}
          />
        ))}
        {onSelect && (
          <ClickableMarker
            position={position as [number, number]}
            setPosition={setPosition as any}
            onClick={onSelect}
          />
        )}
      </MapContainer>
    </div>
  );
};

export default MapComponent;
