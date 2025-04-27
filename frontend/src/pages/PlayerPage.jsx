import { useState } from "react";
import { fetchPlayerData } from "../services/api";

export default function PlayersPage() {
  const [data, setData] = useState([]);

  const loadData = async () => {
    const res = await fetchPlayerData();
    console.log(res);
    if (res.success) {
      setData(res.data.players);
    } else if (res.reason === "auth") {
      window.location.href = "/auth";
    } else {
      alert("Something went wrong");
    }
  };

  const headings = ["Name", "Goals","Club","Trophies","Assists"]

  return (
    <div className="centered-page">
      <h1>Player Data</h1>
      <button onClick={loadData}>Request Data</button>
  
      {data.length > 0 && (
        <table className="players-table">
          <thead>
            <tr>
              {headings.map((heading, key) => (
                <th key={key}>{heading}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.map((player, idx) => (
              <tr key={idx}>
                <td>{player.name ? player.name : "Unknown"}</td>
                <td>{player.goals ? player.goals : 0}</td>
                <td>{player.club ? player.club : "Unknown"}</td>
                <td>{player.trophies ? player.trophies : 0}</td>
                <td>{player.assists ? player.assists : 0}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
