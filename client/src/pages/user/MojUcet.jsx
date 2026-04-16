import { useEffect, useState } from 'react';
import { Alert, Badge, Button, Col, Container, Row, Spinner } from 'react-bootstrap';
import { useAuth } from '../auth/AuthContext.jsx';
import { useNavigate } from 'react-router-dom';
import api from '../../api.js';

function MojUcet() {
    const { user, loading } = useAuth();
    const navigate = useNavigate();
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

    if (loading || !user || !user.meno_priezvisko) {
        return <Spinner animation="border" />;
    }

    if (!user) {
        navigate('/login');
        return null;
    }

    return (
        <Container>
            <Row className="mb-3">
                <h1>Môj účet</h1>
                <Alert variant="info">
                    Prihlásený používateľ: <strong style={{
                        color: user.role === "a" ? "red" : "white"
                    }}>{user.meno_priezvisko.nazov_firma === null ? `${user.meno_priezvisko.meno} ${user.meno_priezvisko.priezvisko}` : `${user.meno_priezvisko.meno} ${user.meno_priezvisko.priezvisko} (${user.meno_priezvisko.nazov_firma})`}</strong>
                </Alert>
            </Row>

            <Row className="g-3">
                <Col md={3}>
                    <Button className="w-100" onClick={() => navigate('/moj-ucet/prehlad')}>
                        Všeobecný prehľad
                    </Button>
                </Col>
                <Col md={3}>
                    <Button className="w-100" onClick={() => navigate('/moj-ucet/zmluvy')}>
                        Prehľad zmlúv
                    </Button>
                </Col>
                <Col md={3}>
                    <Button className="w-100" onClick={() => navigate('/moj-ucet/nova-ziadost')}>
                        Nová žiadosť o zmluvu
                    </Button>
                </Col>
                <Col md={3}>
                    <Button className="w-100" onClick={() => navigate('/moj-ucet/poistne-udalosti')}>
                        Poistné udalosti
                    </Button>
                </Col>
            </Row>

            {user.role === 'a' && (
                <Row className="g-3 mt-4">
                    <h2 className="h4">Admin</h2>
                    <Col md={4}>
                        <Button className="w-100" variant="secondary" onClick={() => navigate('/moj-ucet/admin/prehlad')}>
                            Admin prehľad
                        </Button>
                    </Col>
                    <Col md={4}>
                        <Button className="w-100 d-flex align-items-center justify-content-center gap-2" variant="secondary" onClick={() => navigate('/moj-ucet/admin/ziadosti')}>
                            <span>Žiadosti o zmluvu</span>
                            {pendingZiadostiCount > 0 && (
                                <Badge pill bg="danger">
                                    {pendingZiadostiCount}
                                </Badge>
                            )}
                        </Button>
                    </Col>
                    <Col md={4}>
                        <Button className="w-100" variant="secondary" onClick={() => navigate('/moj-ucet/admin/poistne-udalosti')}>
                            Poistné udalosti
                        </Button>
                    </Col>
                </Row>
            )}
        </Container>
    );
}

export default MojUcet;
