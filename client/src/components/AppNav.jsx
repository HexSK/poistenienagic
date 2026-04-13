import { useEffect, useState } from 'react';
import { Badge, Button, Container, Nav, Navbar } from 'react-bootstrap';
import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../pages/auth/AuthContext.jsx';
import api from '../api.js';
import { getTheme, toggleTheme } from '../theme.js';

function AppNav() {
  const navigate = useNavigate();
  const { user, loading, logout } = useAuth();
  const [theme, setTheme] = useState(() => getTheme());
  const [pendingZiadostiCount, setPendingZiadostiCount] = useState(null);

  useEffect(() => {
    let cancelled = false;
    const run = async () => {
      if (!user || user.role !== 'a') {
        if (!cancelled) setPendingZiadostiCount(null);
        return;
      }

      try {
        const res = await api.get('/api/admin/ziadosti');
        if (cancelled) return;
        const count = Array.isArray(res.data?.ziadosti) ? res.data.ziadosti.length : 0;
        setPendingZiadostiCount(count);
      } catch {
        if (cancelled) return;
        setPendingZiadostiCount(null);
      }
    };

    run();

    return () => {
      cancelled = true;
    };
  }, [user]);

  const handleLogout = async () => {
    await logout();
    navigate('/');
  };

  const handleToggleTheme = () => {
    const next = toggleTheme();
    setTheme(next);
  };

  return (
    <Navbar expand="lg" className="app-navbar mb-4">
      <Container>
        <Navbar.Brand as={NavLink} to="/" className="app-brand">
          Poistenie Nagic
        </Navbar.Brand>
        <Navbar.Toggle aria-controls="main-nav" />
        <Navbar.Collapse id="main-nav">
          <Nav className="me-auto">
            {user && (
              <>
                <Nav.Link as={NavLink} to="/moj-ucet">
                  Môj účet
                </Nav.Link>
                <Nav.Link as={NavLink} to="/moj-ucet/zmluvy">
                  Zmluvy
                </Nav.Link>
                <Nav.Link as={NavLink} to="/moj-ucet/poistne-udalosti">
                  Poistné udalosti
                </Nav.Link>
                {user.role === 'a' && (
                  <>
                    <Nav.Link as={NavLink} to="/moj-ucet/admin/prehlad">
                      Admin
                    </Nav.Link>
                    <Nav.Link as={NavLink} to="/moj-ucet/admin/ziadosti" className="d-flex align-items-center gap-2">
                      <span>Žiadosti</span>
                      {pendingZiadostiCount > 0 && (
                        <Badge pill bg="danger">
                          {pendingZiadostiCount}
                        </Badge>
                      )}
                    </Nav.Link>
                  </>
                )}
              </>
            )}
          </Nav>
          <Nav className="align-items-lg-center gap-2">
            <Button variant="outline-secondary" onClick={handleToggleTheme}>
              {theme === 'dark' ? 'Svetlý režim' : 'Tmavý režim'}
            </Button>
            {!loading && !user && (
              <>
                <Nav.Link as={NavLink} to="/login">
                  Prihlásenie
                </Nav.Link>
                <Nav.Link as={NavLink} to="/register">
                  Registrácia
                </Nav.Link>
              </>
            )}
            {!loading && user && (
              <Button variant="outline-danger" onClick={handleLogout}>
                Odhlásiť
              </Button>
            )}
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
}

export default AppNav;
