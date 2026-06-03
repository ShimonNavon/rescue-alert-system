import SidePanel from "../PTT/SidePanel/SidePanel";
import "./Geography.css";
import Map from "../Map/Map"


export default function Geography() {
    return (
        <div className="panelBoardApp">
            <SidePanel />
            <Map/>

        </div>
    );
}