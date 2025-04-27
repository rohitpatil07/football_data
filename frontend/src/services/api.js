import axios from "axios";

const API = import.meta.env.VITE_API_URL;

export async function fetchPlayerData() {
  try {
    let access_token = localStorage.getItem("token");

    let res = await axios.get(`${API}/players`, {
      headers: {
        Authorization: `Bearer ${access_token}`,
      },
    });

    return { success: true, data: res.data, status: res.status };
    
  } catch (err) {
    if (err.response?.status === 401) {
      // try refresh
      try {

        const token = localStorage.getItem("token");

        if (!token) {
          throw new Error("No access token found"); 
        }

        let refreshRes = await axios.get(`${API}/refresh`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });

        console.log("Refreshing token");

        localStorage.setItem("token", refreshRes.data.access_token);

        // Retry player fetch
        let retry = await axios.get(`${API}/players`, {
          headers: {
            Authorization: `Bearer ${refreshRes.data.access_token}`,
          },
        });

        return { success: true, data: retry.data };
      } catch (refreshErr) {
        console.error("Refresh error:", refreshErr);
        localStorage.removeItem("access_token");
        return { success: false, reason: "auth" };
      }
    }

    return { success: false, reason: err };
  }
}
