import {MoreVertical} from "lucide-react";
import "./Panel.css";
import { type User } from "../../../types/types";
import { useState, useRef, useEffect } from "react";
import AvatarCard  from "../../AvatarCard/AvatarCard"
import AddButton from "../AddButton/AddButton";
import CollapseButton from "../CollapseButton/CollapseButton";

// ── Panel ──────────────────────────────────────────────────────────────
function Panel({
  title,
  rows,
  addLabel,
  collapseLabel,
  onRemove,
  onRename,
}: {
  title: string;
  rows: User[];
  addLabel: string | null;
  collapseLabel: string;
  showAddPanel: boolean;
  onRemove?: () => void;
  onRename?: (newTitle: string) => void;
}) {
  const [isCollapsed, setIsCollapsed] = useState(false);
  const [showOptions, setShowOptions] = useState(false);
  const [isRenaming, setIsRenaming] = useState(false);
  const [newTitle, setNewTitle] = useState(title);
  const menuRef = useRef<HTMLDivElement>(null);
  const inputRef = useRef<HTMLInputElement>(null);

  const handleCollapse = () => {
    setIsCollapsed(!isCollapsed);
  };

  const handleOptionsClick = () => {
    setShowOptions(!showOptions);
  };

  const handleRemove = () => {
    setShowOptions(false);
    onRemove?.();
  };

  const handleRenameClick = () => {
    setIsRenaming(true);
    setShowOptions(false);
  };

  const handleSaveRename = () => {
    if (newTitle.trim()) {
      onRename?.(newTitle);
      setIsRenaming(false);
    }
  };

  const handleCancelRename = () => {
    setNewTitle(title);
    setIsRenaming(false);
  };

  useEffect(() => {
    if (isRenaming && inputRef.current) {
      inputRef.current.focus();
      inputRef.current.select();
    }
  }, [isRenaming]);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setShowOptions(false);
      }
    };

    if (showOptions) {
      document.addEventListener("mousedown", handleClickOutside);
    }

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [showOptions]);

  return (
    <div className={`panel ${isCollapsed ? 'panel-collapsed' : ''}`}>
      <div className="panel-header">
        <div className="panel-header-actions" ref={menuRef}>
          <button className="panel-options-btn" onClick={handleOptionsClick}>
            <MoreVertical size={18} />
          </button>
          {showOptions && (
            <div className="panel-options-menu">
                <button className="panel-option-item" onClick={handleRemove}>
               Remove
                </button>
                      <button className="panel-option-item" onClick={handleRenameClick }>
               Rename
                </button>
                </div>
          )}
        </div>
        {isRenaming ? (
          <div className="panel-rename-container">
            <input
              ref={inputRef}
              type="text"
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  handleSaveRename();
                } else if (e.key === 'Escape') {
                  handleCancelRename();
                }
              }}
              className="panel-rename-input"
            />
            <button
              className="panel-rename-save"
              onClick={handleSaveRename}
            >
              Save
            </button>
            <button
              className="panel-rename-cancel"
              onClick={handleCancelRename}
            >
              Cancel
            </button>
          </div>
        ) : (
          <span className="panel-title">{title}</span>
        )}
      </div>

      {!isCollapsed && (
        <>
          <div className="panel-avatars">
            {addLabel && <AddButton label={addLabel} />}
            {rows.map((row) => (
              <AvatarCard key={row.id} row={row} />
            ))}
          </div>

        </>
      )}

      <div className="panel-footer">
        <CollapseButton label={collapseLabel} onClick={handleCollapse} isCollapsed={isCollapsed} />
      </div>
    </div>
  );
}
export default Panel;