import React, { useState } from 'react';
// import './App.css'; // Make sure this includes your dark theme

const API = import.meta.env.VITE_API_URL; 

function LoginSignup() {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLogin, setIsLogin] = useState(true);

  const handleAuth = async (e) => {
    e.preventDefault();
    const endpoint = "/login";
    const action = isLogin ? 'login' : 'signup';

    try {
      const response = await fetch(`${API}${endpoint}`, {
        method: 'POST',
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ username, password , action}),
      });

      const data = await response.json();

      if (data.access_token) {
        localStorage.setItem('token', data.access_token);
        alert('Authentication successful!');
        // Redirect to the main page or perform any other action
        window.location.href = '/players'; // Redirect to the players page
      } else {
        alert(data.message || 'Authentication failed');
      }
    } catch (err) {
      console.error('Auth error:', err);
      alert('Something went wrong!');
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-card">
        <h2>{isLogin ? 'Login' : 'Signup'}</h2>
        <form className="auth-form" onSubmit={handleAuth}>
          <input
            type="input"
            placeholder="username"
            className="auth-input"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            required
          />
          <input
            type="password"
            placeholder="Password"
            className="auth-input"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          <button className="auth-button" type="submit">
            {isLogin ? 'Login' : 'Signup'}
          </button>
        </form>

        <p className="auth-toggle">
          {isLogin ? 'Don’t have an account?' : 'Already have an account?'}{' '}
          <button
            className="auth-switch"
            onClick={() => setIsLogin(!isLogin)}
          >
            {isLogin ? 'Signup' : 'Login'}
          </button>
        </p>
      </div>
    </div>
  );
}

export default LoginSignup;
