import SidePanel from "../PTT/SidePanel/SidePanel";
import "./Messages.css";
import GroupChat from "./GroupChat/GroupChat";


export default function Messages() {
    return (
        <div className="panelBoardApp">
            <SidePanel />
            <GroupChat/>
        </div>
    );
}