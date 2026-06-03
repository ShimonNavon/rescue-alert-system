import Panel from "./Panel/Panel";
import { INITIAL_ROWS } from "../../data/initialRows";
import SidePanel from "./SidePanel/SidePanel";
import "./Ptt.css";
import { Plus} from "lucide-react";
import { useState } from "react";
import type { User } from "@/types/types";


interface DynamicPanel {
  id: string;
  title: string;
  rows: User[];
}

export default function Ptt() {
  const [dynamicPanels, setDynamicPanels] = useState<DynamicPanel[]>([]);

  const handleAddPanel = () => {
    const newPanel: DynamicPanel = {
      id: `panel-${Date.now()}`,
      title: `פאנל ${dynamicPanels.length + 1}`,
      rows: INITIAL_ROWS,
    };
    setDynamicPanels([...dynamicPanels, newPanel]);
  };

  const handleRemovePanel = (panelId: string) => {
    setDynamicPanels(dynamicPanels.filter(panel => panel.id !== panelId));
  };

  const handleRenamePanel = (panelId: string, newTitle: string) => {
    setDynamicPanels(dynamicPanels.map(panel =>
      panel.id === panelId ? { ...panel, title: newTitle } : panel
    ));
  };

  return (
    <div className="app">
      <SidePanel />

      <div className="content">
        <Panel
          title="מועדפים"
          rows={INITIAL_ROWS}
          addLabel="הוסף מועדף"
          collapseLabel="כיווץ"
          showAddPanel={false}
        />

        <Panel
          title="AlphaTrial"
          rows={INITIAL_ROWS}
          addLabel="הוסף משתמש"
          collapseLabel="כיווץ והשתקה"
          showAddPanel={true}
        />

        {dynamicPanels.map((panel) => (
          <Panel
            key={panel.id}
            title={panel.title}
            rows={panel.rows}
            addLabel="הוסף משתמש"
            collapseLabel="כיווץ"
            showAddPanel={false}
            onRemove={() => handleRemovePanel(panel.id)}
            onRename={(newTitle) => handleRenamePanel(panel.id, newTitle)}
          />
        ))}
   
            <div className="panel-add">
              <button className="panel-add-btn" onClick={handleAddPanel}>
                <Plus size={16} /> הוסף פאנל
              </button>
            </div>
       
      </div>
    </div>
  );
}