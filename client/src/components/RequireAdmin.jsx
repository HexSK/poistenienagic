import { Navigate } from 'react-router-dom';
import { useAuth } from '../pages/auth/AuthContext.jsx';

function RequireAdmin({ children }) {
  const { user, loading } = useAuth();

  if (loading) {
    return <div>Načítavam…</div>;
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  if (user.role !== 'a') {
    return <Navigate to="/moj-ucet" replace />;
  }

  return children;
}

export default RequireAdmin;

