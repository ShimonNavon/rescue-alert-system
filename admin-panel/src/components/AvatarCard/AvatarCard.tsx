import { type User } from "../../types/types";
import Avatar from "@/components/Avatar/Avatar";
import "./AvatarCard.css"

function AvatarCard({ row }: { row: User }) {
  return (
    <div
      // className="avatar-card"
      >
      <div className="avatar-scale">
        <Avatar row={row} />
      </div>

      <span className="avatar-name">{row.name}</span>
    </div>
  );
}
export default AvatarCard;