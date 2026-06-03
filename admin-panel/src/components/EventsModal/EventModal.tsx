import type { FC } from "react";
import "./EventModal.css";
import MapComponent from "../Map/Map";


type Props = {
    open: boolean;
    onClose: () => void;
};

const handleSelect = (lat: number, lng: number) => {
    console.log("Selected:", lat, lng);
};

const EventsModal: FC<Props> = ({ open, onClose }) => {
    if (!open) return null;

    return (
        <div className="modal-overlay">
            <div className="modal">
                {/* HEADER */}
                <div className="modal-header">
                    <button className="close-btn" onClick={() => onClose()} >✕</button>
                    <span className="mute-map">הסתר מפה </span>
                </div>

                {/* BODY */}
                <div className="modal-body">
                    {/* LEFT - MAP */}
                    <div className="map-container">
                        <div style={{ width: "50vw", height: "68vh" }}>
                            <MapComponent onSelect={handleSelect} height="100%" />
                        </div>
                    </div>

                    {/* RIGHT - FORM */}
                    <div className="form-container">
                        <h2 className="title">יצירת אירוע</h2>

                        <label>מזהה ייחודי</label>
                        <input placeholder="מידע על הדמות" />

                        <label>מספר טלפון נוסף</label>
                        <input placeholder="הזן טלפון" />

                        <label>מקום</label>
                        <input placeholder="חפש לפי כתובת או קואורדינטות" />

                        <div className="coords-row">
                            <input placeholder="כניסה" />
                            <input placeholder="קומה" />
                            <input placeholder="דירה" />
                        </div>

                        <button className="add-address">+ הצג כתובת מלאה</button>

                        <label>פרטי  אירוע</label>
                        <textarea placeholder="הזן מידע" />
                    </div>
                </div>

                {/* FOOTER */}
                <div className="modal-footer">
                    <button className="btn-cancel" onClick={() => onClose()}>בטל</button>
                    <button className="btn secondary">שמור</button>
                    <button className="btn primary">שלח</button>
                </div>
            </div>
        </div>
    );
};

export default EventsModal;