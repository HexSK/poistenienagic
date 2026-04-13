import { Alert, Button, Col, Form, Modal, Row, Spinner, Table } from 'react-bootstrap';
import { useEffect, useState } from 'react';
import api from '../../api.js';
import { formatDate, formatMoneyEur } from '../../utils/format.js';

function AdminPoistneUdalosti() {
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [udalosti, setUdalosti] = useState([]);

    const [resolve, setResolve] = useState(null); // { id, datum, suma }
    const [resolveLoading, setResolveLoading] = useState(false);
    const [resolveError, setResolveError] = useState(null);

    const reload = () => {
        setLoading(true);
        setError(null);
        api.get('/api/admin/prehlad')
            .then((res) => setUdalosti(res.data?.otvorene_poistne_udalosti || []))
            .catch((err) => setError(err?.response?.data?.error || 'Nepodarilo sa načítať udalosti.'))
            .finally(() => setLoading(false));
    };

    useEffect(() => {
        reload();
    }, []);

    const openResolve = (u) => {
        setResolveError(null);
        setResolve({ id: u.id_poistna_udalost, datum: '', suma: '' });
    };

    const handleResolve = async () => {
        if (!resolve?.id) return;
        setResolveLoading(true);
        setResolveError(null);
        try {
            await api.patch(`/api/admin/poistna-udalost/${resolve.id}`, {
                datum_vyriesenia: resolve.datum,
                suma_udalosti: resolve.suma === '' ? null : Number(resolve.suma),
            });
            setResolve(null);
            reload();
        } catch (err) {
            setResolveError(err?.response?.data?.error || 'Udalosť sa nepodarilo vyriešiť.');
        } finally {
            setResolveLoading(false);
        }
    };

    if (loading) return <Spinner animation="border" />;
    if (error) return <Alert variant="danger">{error}</Alert>;

    return (
        <>
            <h1>Poistné udalosti (admin)</h1>
            {udalosti.length === 0 ? (
                <Alert variant="secondary">Nie sú žiadne otvorené udalosti.</Alert>
            ) : (
                <Table striped bordered hover responsive>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>ECV</th>
                            <th>Dátum udalosti</th>
                            <th>Suma</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        {udalosti.map((u) => (
                            <tr key={u.id_poistna_udalost}>
                                <td>{u.id_poistna_udalost}</td>
                                <td>{u.ECV}</td>
                                <td>{formatDate(u.datum_udalosti)}</td>
                                <td>{formatMoneyEur(u.suma_udalosti)}</td>
                                <td>
                                    <Button size="sm" onClick={() => openResolve(u)}>
                                        Vyriešiť
                                    </Button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </Table>
            )}

            <Modal show={Boolean(resolve)} onHide={() => (resolveLoading ? null : setResolve(null))}>
                <Modal.Header closeButton={!resolveLoading}>
                    <Modal.Title>Vyriešiť udalosť</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Row className="g-3">
                        <Col md={6}>
                            <Form.Group controlId="datumVyriesenia">
                                <Form.Label>Dátum vyriešenia</Form.Label>
                                <Form.Control
                                    type="date"
                                    value={resolve?.datum || ''}
                                    onChange={(e) => setResolve((prev) => ({ ...prev, datum: e.target.value }))}
                                    disabled={resolveLoading}
                                />
                            </Form.Group>
                        </Col>
                        <Col md={6}>
                            <Form.Group controlId="sumaUdalosti">
                                <Form.Label>Suma (EUR)</Form.Label>
                                <Form.Control
                                    type="number"
                                    value={resolve?.suma || ''}
                                    onChange={(e) => setResolve((prev) => ({ ...prev, suma: e.target.value }))}
                                    disabled={resolveLoading}
                                />
                            </Form.Group>
                        </Col>
                    </Row>
                    {resolveError && <Alert className="mt-3" variant="danger">{resolveError}</Alert>}
                </Modal.Body>
                <Modal.Footer>
                    <Button variant="secondary" onClick={() => setResolve(null)} disabled={resolveLoading}>
                        Zrušiť
                    </Button>
                    <Button onClick={handleResolve} disabled={resolveLoading}>
                        {resolveLoading ? 'Ukladám…' : 'Potvrdiť'}
                    </Button>
                </Modal.Footer>
            </Modal>
        </>
    );
}

export default AdminPoistneUdalosti;
