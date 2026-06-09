/**
 * NADDEFLI — main.jsx
 * Layer: Admin Dashboard — ENTRY POINT
 * Purpose: Renders React app into DOM.
 * Connects to: App.jsx
 */

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
