import "./NotFoundPage.css";

export default function NotFound() {
  return (
    <div className="notfound-page">
      <div className="notfound-card">
        <div className="notfound-code">404</div>

        <h1 className="notfound-title">Page not found</h1>

        <p className="notfound-text">
          The page you’re looking for doesn’t exist or was moved.
        </p>

        <div className="notfound-actions">
          <a href="/" className="notfound-button primary">
            Go home
          </a>

          {/* <button
            className="notfound-button secondary"
            onClick={() => window.history.back()}
          >
            Go back
          </button> */}
        </div>
      </div>
    </div>
  );
}