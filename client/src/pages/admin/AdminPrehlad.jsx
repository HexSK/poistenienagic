import { Alert, Badge, Button, Card, Col, Row, Spinner, Table } from 'react-bootstrap';
import { useEffect, useState } from 'react';
import api from '../../api.js';
import { formatDate } from '../../utils/format.js';
import { useNavigate } from 'react-router-dom';

function AdminPrehlad() {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [data, setData] = useState(null);

    useEffect(() => {
        let cancelled = false;
        api.get('/api/admin/prehlad')
            .then((res) => {
                if (cancelled) return;
                setData(res.data);
            })
            .catch((err) => {
                if (cancelled) return;
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať admin prehľad.');
            })
            .finally(() => {
                if (cancelled) return;
                setLoading(false);
            });
        return () => {
            cancelled = true;
        };
    }, []);

    if (loading) return <Spinner animation="border" />;
    if (error) return <Alert variant="danger">{error}</Alert>;

    const statistika = data?.statistika || {};
    const posledneZmluvy = data?.posledne_zmluvy || [];
    const nezaplateneZmluvy = data?.nezaplatene_zmluvy || [];
    const otvoreneUdalosti = data?.otvorene_poistne_udalosti || [];
    const uzivatelia = data?.uzivatelia_zmluvy_vozidla || [];

    return (
        <>
            <h1>Admin prehľad</h1>

            <Row className="g-3 mb-4">
                <Col md={3}>
                    <Card>
                        <Card.Body>
                            <Card.Title>Používatelia</Card.Title>
                            <div className="display-6">{statistika.pocet_uzivatelov ?? 0}</div>
                        </Card.Body>
                    </Card>
                </Col>
                <Col md={3}>
                    <Card>
                        <Card.Body>
                            <Card.Title>Aktívne zmluvy</Card.Title>
                            <div className="display-6">{statistika.aktivne_zmluvy ?? 0}</div>
                        </Card.Body>
                    </Card>
                </Col>
                <Col md={3}>
                    <Card>
                        <Card.Body>
                            <Card.Title>Nezaplatené faktúry</Card.Title>
                            <div className="display-6">{statistika.nezaplatene_faktury ?? 0}</div>
                        </Card.Body>
                    </Card>
                </Col>
                <Col md={3}>
                    <Card>
                        <Card.Body>
                            <Card.Title>Otvorené udalosti</Card.Title>
                            <div className="display-6">{statistika.otvorene_udalosti ?? 0}</div>
                        </Card.Body>
                    </Card>
                </Col>
            </Row>

            <Row className="g-3">
                <Col md={6}>
                    <h2 className="h4">Posledné zmluvy</h2>
                    {posledneZmluvy.length === 0 ? (
                        <Alert variant="secondary">Žiadne dáta.</Alert>
                    ) : (
                        <Table striped bordered hover responsive>
                            <thead>
                                <tr>
                                    <th>ID zmluvy</th>
                                    <th>Klient</th>
                                    <th>ECV</th>
                                    <th>Stav</th>
                                    <th>Dátum začiatku</th>
                                </tr>
                            </thead>
                            <tbody>
                                {posledneZmluvy.map((z) => (
                                    <tr key={z.id_zmluva}>
                                        <td>{z.id_zmluva}</td>
                                        <td>{z.zobrazene_meno}</td>
                                        <td>{z.ECV}</td>
                                        <td>
                                            <Badge bg={z.stav_zmluvy === 'aktivna' ? 'success' : 'secondary'}>{z.stav_zmluvy}</Badge>
                                        </td>
                                        <td>{formatDate(z.datum_zaciatku)}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </Table>
                    )}
                </Col>
                <Col md={6}>
                    <h2 className="h4">Nezaplatené (po splatnosti)</h2>
                    {nezaplateneZmluvy.length === 0 ? (
                        <Alert variant="secondary">Žiadne dáta.</Alert>
                    ) : (
                        <Table striped bordered hover responsive>
                            <thead>
                                <tr>
                                    <th>ID zmluvy</th>
                                    <th>ID faktúry</th>
                                    <th>Klient</th>
                                    <th>ECV</th>
                                    <th>Splatnosť</th>
                                </tr>
                            </thead>
                            <tbody>
                                {nezaplateneZmluvy.map((f) => (
                                    <tr key={`${f.id_zmluva}-${f.id_faktura}`}>
                                        <td>{f.id_zmluva}</td>
                                        <td>{f.id_faktura}</td>
                                        <td>{f.zobrazene_meno}</td>
                                        <td>{f.ECV}</td>
                                        <td>{formatDate(f.datum_splatnosti)}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </Table>
                    )}
                </Col>
            </Row>

            <Row className="g-3 mt-2">
                <Col md={6}>
                    <h2 className="h4">Otvorené poistné udalosti</h2>
                    <Button size="sm" variant="outline-primary" onClick={() => navigate('/moj-ucet/admin/poistne-udalosti')}>
                        Spravovať udalosti
                    </Button>
                    {otvoreneUdalosti.length === 0 ? (
                        <Alert className="mt-2" variant="secondary">Žiadne dáta.</Alert>
                    ) : (
                        <Table className="mt-2" striped bordered hover responsive>
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>ECV</th>
                                    <th>Dátum</th>
                                </tr>
                            </thead>
                            <tbody>
                                {otvoreneUdalosti.slice(0, 5).map((u) => (
                                    <tr key={u.id_poistna_udalost}>
                                        <td>{u.id_poistna_udalost}</td>
                                        <td>{u.ECV}</td>
                                        <td>{formatDate(u.datum_udalosti)}</td>
                                    </tr>
                                ))}
                            </tbody>
                        </Table>
                    )}
                </Col>
                <Col md={6}>
                    <h2 className="h4">Používatelia / zmluvy</h2>
                    {uzivatelia.length === 0 ? (
                        <Alert variant="secondary">Žiadne dáta.</Alert>
                    ) : (
                        <Table striped bordered hover responsive>
                            <thead>
                                <tr>
                                    <th>ID používateľa</th>
                                    <th>Meno / firma</th>
                                    <th>ECV</th>
                                    <th>ID zmluvy</th>
                                    <th></th>
                                </tr>
                            </thead>
                            <tbody>
                                {uzivatelia.slice(0, 10).map((u) => (
                                    <tr key={`${u.id_uzivatel}-${u.id_zmluva}`}>
                                        <td>{u.id_uzivatel}</td>
                                        <td>{u.nazov_firma || `${u.meno} ${u.priezvisko}`}</td>
                                        <td>{u.ECV}</td>
                                        <td>{u.id_zmluva}</td>
                                        <td>
                                            <Button size="sm" onClick={() => navigate(`/moj-ucet/admin/prehlad/uzivatel/${u.id_uzivatel}`)}>
                                                Detail
                                            </Button>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </Table>
                    )}
                </Col>
            </Row>
        </>
    );
}

export default AdminPrehlad;

