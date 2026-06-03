import {ChevronUp} from "lucide-react";
import "./CollapseButton.css";



// ── CollapseButton ─────────────────────────────────────────────────────
function CollapseButton({ label, onClick, isCollapsed }: { label: string; onClick?: () => void; isCollapsed?: boolean }) {
  return (
    <button className="collapse-btn" onClick={onClick}>
      <ChevronUp size={14} style={{ transform: isCollapsed ? 'rotate(180deg)' : 'rotate(0deg)', transition: 'transform 0.3s ease' }} />
      {label}
    </button>
  );
}
export default CollapseButton;