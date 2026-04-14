<div style="background-color: #121212; color: #e0e0e0; padding: 24px; border-radius: 12px; border: 1px solid #333; margin: 20px 0; max-width: 100%; box-sizing: border-box; box-shadow: 0 4px 10px rgba(0,0,0,0.5);">
  
  <h2 style="color: #ffffff; margin-top: 0; font-family: sans-serif;">Server Architecture</h2>
  
  <p style="font-size: 16px; line-height: 1.6; font-family: sans-serif;">
    This is a dedicated dark-themed section. Because you are using inline CSS, this block will strictly remain dark and retain its styling regardless of what GitHub Pages theme you use in the background.
  </p>

  <ul style="list-style-type: square; margin-left: 20px; font-family: sans-serif; margin-bottom: 24px;">
    <li>Link 1</li>
    <li>Link 2</li>
    <li>Link 3</li>
  </ul>

  <div style="background-color: #000000; padding: 16px; border-radius: 8px; border: 1px solid #444; overflow-x: auto;">
    <pre style="margin: 0; font-family: 'Courier New', Consolas, monospace; font-size: 14px; color: #00ffcc; line-height: 1.2;">
┌─────────────────────────────────────────────────────────┐
│                  podman ecomm_watcher                   │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────┐   │
│  │   MariaDB   │  │  FastAPI    │  │   Vite React   │   │
│  │   :3306     │  │  :8000      │  │   :3000        │   │
│  └─────────────┘  └─────────────┘  └────────────────┘   │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐                       │
│  │ CSV Watcher │  │  start.sh   │                       │
│  │  /drop_here │  │ orchestrate │                       │
│  └─────────────┘  └─────────────┘                       │
└─────────────────────────────────────────────────────────┘
         │                              │
   /drop_here (csv)              /app/finished
   host mount only               host mount only
    </pre>
  </div>

</div>
