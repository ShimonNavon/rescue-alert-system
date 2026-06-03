import type {User } from "../../types/types";
import {  UserCircle } from "lucide-react";


export default function Avatar({ row }: { row: Partial<User> }) {
  if (row.dotType === "system") {
    return (
      <div className="situation__avatar situation__avatar--system">
        <UserCircle size={14} />
      </div>
    );
  }

  const initials = row?.name?.slice(0, 1).toUpperCase() || "U";

  return (
    <div className="situation__avatar">
      {initials}
      {row.dotType === "single" && row.dotColor && (
        <div
          className="situation__avatar-dot"
          style={{ background: row.dotColor || "grey"}}
        />
      )}
      {row.dotType === "multi" && row.dotColors && (
        <div className="situation__avatar-dots">
          {row.dotColors.map((color, i) => (
            <div
              key={i}
              className="situation__avatar-dot-sm"
              style={{ background: color || "grey" }}
            />
          ))}
        </div>
      )}
    </div>
  );
}
