import { Alert, Badge, Card, Col, Row, Spinner, Table } from 'react-bootstrap';
import { useEffect, useState } from 'react';
import api from '../../api.js';
import { formatDate, formatMoneyEur } from '../../utils/format.js';
import { useNavigate } from 'react-router-dom';

function MojUcetPrehlad() {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [data, setData] = useState(null);

    useEffect(() => {
        let cancelled = false;
        api.get('/api/prehlad')
            .then((res) => {
                if (cancelled) return;
                setData(res.data);
                setError(null);
            })
            .catch((err) => {
                if (cancelled) return;
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať prehľad.');
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
    const zmluvy = data?.klient_zmluvy || [];
    const udalosti = data?.poistne_udalosti || [];

    return (
        <>
            <h1>Všeobecný prehľad</h1>

            <Row className="g-3 mb-4">
                <Col md={4}>
                    <Card>
                        <Card.Body>
                            <Card.Title>Aktívne zmluvy</Card.Title>
                            <div className="display-6">{statistika.aktivne_zmluvy ?? 0}</div>
                        </Card.Body>
                    </Card>
                </Col>
                <Col md={4}>
                    <Card>
                        <Card.Body>
                            <Card.Title>Najbližšia splatnosť</Card.Title>
                            <div className="h4">{formatDate(statistika.najblizsia_splatnost)}</div>
                            <div className="text-muted">{formatMoneyEur(statistika.najblizsia_splatnost_suma)}</div>
                            <div className="mt-2 d-flex gap-2 justify-content-center flex-wrap">
                                {statistika.najblizsia_splatnost_id_zmluva && (
                                    <button
                                        className="btn btn-outline-secondary btn-sm"
                                        onClick={() => navigate(`/moj-ucet/zmluva/${statistika.najblizsia_splatnost_id_zmluva}/faktury`)}
                                    >
                                        Faktúry
                                    </button>
                                )}
                                {statistika.najblizsia_splatnost_id_zmluva && statistika.najblizsia_splatnost_id_faktura && (
                                    <button
                                        className="btn btn-primary btn-sm"
                                        onClick={() =>
                                            navigate(
                                                `/moj-ucet/zmluva/${statistika.najblizsia_splatnost_id_zmluva}/faktura/${statistika.najblizsia_splatnost_id_faktura}/zaplat`,
                                            )
                                        }
                                    >
                                        Zaplatiť
                                    </button>
                                )}
                            </div>
                        </Card.Body>
                    </Card>
                </Col>
                <Col md={4}>
                    <Card>
                        <Card.Body>
                            <Card.Title>Otvorené udalosti</Card.Title>
                            <div className="display-6">{statistika.otvorene_udalosti ?? 0}</div>
                        </Card.Body>
                    </Card>
                </Col>
            </Row>

            <h2 className="h4">Posledné zmluvy</h2>
            {zmluvy.length === 0 ? (
                <Alert variant="secondary">Nemáte žiadne zmluvy.</Alert>
            ) : (
                <Table striped bordered hover responsive>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>ECV</th>
                            <th>VIN</th>
                            <th>Stav</th>
                            <th>Začiatok</th>
                            <th>Koniec</th>
                            <th>Cena poistného</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        {zmluvy.slice(0, 5).map((z) => (
                            <tr key={z.id_zmluva ?? `${z.ECV}-${z.VIN}-${z.datum_zaciatku}`}>
                                <td>{z.id_zmluva ?? '-'}</td>
                                <td>{z.ECV ?? '-'}</td>
                                <td>{z.VIN ?? '-'}</td>
                                <td>
                                    <Badge bg={z.stav_zmluvy === 'aktivna' ? 'success' : 'secondary'}>{z.stav_zmluvy}</Badge>
                                </td>
                                <td>{formatDate(z.datum_zaciatku)}</td>
                                <td>{formatDate(z.datum_konca)}</td>
                                <td>{formatMoneyEur(z.cena_poistneho)}</td>
                                <td>
                                    {z.id_zmluva && (
                                        <button className="btn btn-sm btn-primary" onClick={() => navigate(`/moj-ucet/zmluva/${z.id_zmluva}`)}>
                                            Detail
                                        </button>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </Table>
            )}

            <h2 className="h4 mt-4">Poistné udalosti</h2>
            {udalosti.length === 0 ? (
                <Alert variant="secondary">Nemáte evidované žiadne poistné udalosti.</Alert>
            ) : (
                <Table striped bordered hover responsive>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>ECV</th>
                            <th>Dátum udalosti</th>
                            <th>Stav</th>
                            <th>Popis</th>
                        </tr>
                    </thead>
                    <tbody>
                        {udalosti.slice(0, 5).map((u) => (
                            <tr key={u.id_poistna_udalost ?? `${u.ECV}-${u.datum_udalosti}-${u.popis_udalosti}`}>
                                <td>{u.id_poistna_udalost ?? '-'}</td>
                                <td>{u.ECV ?? '-'}</td>
                                <td>{formatDate(u.datum_udalosti)}</td>
                                <td>
                                    {u.stav_udalosti ? <Badge bg="success">Vyriešená</Badge> : <Badge bg="warning">Otvorená</Badge>}
                                </td>
                                <td style={{ maxWidth: 420 }}>{u.popis_udalosti}</td>
                            </tr>
                        ))}
                    </tbody>
                </Table>
            )}
        </>
    );
}

export default MojUcetPrehlad;
