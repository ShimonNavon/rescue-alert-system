import { Routes, Route, Navigate } from "react-router-dom";
import { Fragment, useState } from "react";
import "./App.css";
import Layout from "./components/Layout/Layout";
import EventTable from "./components/EventTable/EventTable";
import Situation from "./components/Situation/Situation";
import EventsModal from "./components/EventsModal/EventModal";
import Ptt from "./components/PTT/Ptt";
import Geography from "./components/Geography/Geography";
import Messages from "./components/Messages/Messages";
import Login from "./components/Login/Login";
import NotFoundPage from "./components/NotFoundPage/NotFoundPage";
import { useAuth } from "./context/AuthContext";

function App() {
  const [windowOpen, setWindowOpen] = useState(false);
  const { user, loading } = useAuth();

  if (loading) {
    return <div style={{ padding: 32, fontFamily: "sans-serif" }}>Loading…</div>;
  }

  if (!user) {
    return <Login />;
  }

  return (
    <Fragment>
      <Layout setWindowOpen={setWindowOpen} />
      {windowOpen && (
        <EventsModal open={windowOpen} onClose={() => setWindowOpen(false)} />
      )}

      <Routes>
        <Route index element={<Navigate to="/events-table" replace />} />
        <Route path="/events-table" element={<EventTable />} />
        <Route path="/situation" element={<Situation />} />
        <Route path="/*" element={<NotFoundPage />} />
        <Route path="/chat" element={<Messages />} />
        <Route path="/geography" element={<Geography />} />
        <Route path="/ptt" element={<Ptt />} />
      </Routes>
    </Fragment>
  );
}

export default App;
