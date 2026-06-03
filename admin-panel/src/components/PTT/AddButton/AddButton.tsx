import { useState } from "react";
import {Plus} from "lucide-react";
import "./AddButton.css";


function AddButton({ label }: { label: string }) {
  const [hovered, setHovered] = useState(false);

  return (
    <div
      className="add-btn"
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      <div className={`add-circle ${hovered ? "hovered" : ""}`}>
        <Plus size={22} />
      </div>

      <span className="add-label">{label}</span>
    </div>
  );
}
export default AddButton;