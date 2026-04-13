import { Navigate, useLocation } from 'react-router-dom';
import { useAuth } from '../pages/auth/AuthContext.jsx';

function RequireAuth({ children }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) {
    return <div>Načítavam…</div>;
  }

  if (!user) {
    return <Navigate to="/login" replace state={{ from: location }} />;
  }

  return children;
}

export default RequireAuth;

