import { Routes, Route, Navigate } from "react-router-dom";
import AuthPage from "./pages/AuthPage";
import PlayerPage from "./pages/PlayerPage";
import "./App.css"

export default function App() {
  const isAuthenticated = !!localStorage.getItem("token");

  return (
    <Routes>
      <Route path="/auth" element={<AuthPage />} />
      <Route
        path="/players"
        element={
          isAuthenticated ? <PlayerPage /> : <Navigate to="/auth" />
          // <PlayerPage />
        }
      />
      <Route path="*" element={<Navigate to="/auth" />} />
    </Routes>
  );
}
