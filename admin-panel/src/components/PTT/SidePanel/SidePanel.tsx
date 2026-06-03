import { useState } from "react";
import {
  MoreVertical,
  Search,
  Mic,
  Check,
  MessageSquare,
  ChevronLeft,
} from "lucide-react";
import "./SidePanel.css";
import AvatarCard from "@/components/AvatarCard/AvatarCard";
// import { chatItems } from "@/data/chatItems";
import { INITIAL_ROWS } from "@/data/initialRows";

function SidePanel() {
  const [search, setSearch] = useState("");
  const [selected, setSelected] = useState(1);
  const [mobileOpen, setMobileOpen] = useState(false);

  // const filtered = chatItems.filter(
  //   (c) =>
  //     c.title.includes(search) ||
  //     c.preview.includes(search) ||
  //     c.sender.includes(search),
  // );

  return (
    <div className={`sidepanel ${mobileOpen ? "open" : ""}`}>
      <button
        className="sidepanel-toggle"
        onClick={() => setMobileOpen((prev) => !prev)}
      >
        <ChevronLeft size={14} />
      </button>

      {mobileOpen && (
        <div
          className="sidepanel-backdrop"
          onClick={() => setMobileOpen(false)}
        />
      )}

      <div className="sidepanel-header">
        <span className="sidepanel-title">בחר איש קשר</span>

        <div className="sidepanel-mic">
          <Mic size={28} />
        </div>

        <div className="sidepanel-clear">
          <span>נקה</span>
          <span>⚡</span>
        </div>
      </div>

      {/* Search */}
      <div className="sidepanel-search">
        <MoreVertical size={16} />

        <div className="search-box">
          <Search size={13} />
          <input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="חפש..."
          />
        </div>
      </div>

      {/* List */}
      <div className="chat-list">
        {INITIAL_ROWS.map((item) => (
          <div
            key={item.id}
            className={`chat-item ${selected === item.id ? "active" : ""}`}
            onClick={() => setSelected(item.id)}
          >
            {/* Badge */}
            {item?.event?.badge  ? (
              <div className="chat-badge">{item?.event?.badge}</div>
            ) : (
              <div className="chat-badge empty" />
            )}

            {/* Text */}
            <div className="chat-content">
              <div className="chat-top">
                <div className="chat-title">{item.event?.label}</div>
              </div>
                <div className="chat-time">{item.lastUpdate}</div>

              <div className="chat-bottom">
                {item.info && <MessageSquare size={10} />}
                {item.unread && <Check size={10} />}
                {item.status && (
                  <span className="chat-sender">{item.status}:</span>
                )}
                <span className="chat-preview">{item.info}</span>
              </div>
            </div>

            <AvatarCard row={item} />
          </div>
        ))}
      </div>
    </div>
  );
}
export default SidePanel;
