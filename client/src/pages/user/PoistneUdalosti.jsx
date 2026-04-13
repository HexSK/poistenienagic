import { Alert, Badge, Button, Col, Form, Modal, Row, Spinner, Table } from 'react-bootstrap';
import { useEffect, useMemo, useState } from 'react';
import api from '../../api.js';
import { formatDate } from '../../utils/format.js';

function PoistneUdalosti() {
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [prehlad, setPrehlad] = useState(null);

    const [createLoading, setCreateLoading] = useState(false);
    const [createError, setCreateError] = useState(null);
    const [createSuccess, setCreateSuccess] = useState(false);
    const [idZmluva, setIdZmluva] = useState('');
    const [datumUdalosti, setDatumUdalosti] = useState('');
    const [popisUdalosti, setPopisUdalosti] = useState('');

    const [edit, setEdit] = useState(null); // { id, popis, datum }
    const [editLoading, setEditLoading] = useState(false);
    const [editError, setEditError] = useState(null);

    const reload = () => {
        setLoading(true);
        setError(null);
        api.get('/api/prehlad')
            .then((res) => setPrehlad(res.data))
            .catch((err) => setError(err?.response?.data?.error || 'Nepodarilo sa načítať údaje.'))
            .finally(() => setLoading(false));
    };

    useEffect(() => {
        reload();
    }, []);

    const aktivneZmluvy = useMemo(() => {
        const zmluvy = prehlad?.klient_zmluvy || [];
        return zmluvy.filter((z) => z.stav_zmluvy === 'aktivna' && z.id_zmluva);
    }, [prehlad]);

    const udalosti = prehlad?.poistne_udalosti || [];

    const handleCreate = async (e) => {
        e.preventDefault();
        setCreateError(null);
        setCreateSuccess(false);
        setCreateLoading(true);
        try {
            await api.post('/api/poistna-udalost', {
                id_zmluva: Number(idZmluva),
                popis_udalosti: popisUdalosti,
                datum_udalosti: datumUdalosti,
            });
            setCreateSuccess(true);
            setIdZmluva('');
            setDatumUdalosti('');
            setPopisUdalosti('');
            reload();
        } catch (err) {
            setCreateError(err?.response?.data?.error || 'Udalosť sa nepodarilo vytvoriť.');
        } finally {
            setCreateLoading(false);
        }
    };

    const openEdit = (u) => {
        setEditError(null);
        setEdit({ id: u.id_poistna_udalost, popis: u.popis_udalosti || '', datum: u.datum_udalosti || '' });
    };

    const handleEditSave = async () => {
        if (!edit?.id) return;
        setEditError(null);
        setEditLoading(true);
        try {
            await api.patch(`/api/poistna-udalost/${edit.id}`, {
                popis_udalosti: edit.popis,
                datum_udalosti: edit.datum,
            });
            setEdit(null);
            reload();
        } catch (err) {
            setEditError(err?.response?.data?.error || 'Udalosť sa nepodarilo upraviť.');
        } finally {
            setEditLoading(false);
        }
    };

    if (loading) return <Spinner animation="border" />;
    if (error) return <Alert variant="danger">{error}</Alert>;

    return (
        <>
            <h1>Poistné udalosti</h1>

            <h2 className="h4 mt-4">Nová poistná udalosť</h2>
            <Form onSubmit={handleCreate}>
                <Row className="g-3">
                    <Col md={6}>
                        <Form.Group controlId="idZmluva">
                            <Form.Label>Zmluva</Form.Label>
                            <Form.Select value={idZmluva} onChange={(e) => setIdZmluva(e.target.value)} required>
                                <option value="">Vyberte zmluvu…</option>
                                {aktivneZmluvy.map((z) => (
                                    <option key={z.id_zmluva} value={z.id_zmluva}>
                                        #{z.id_zmluva} {z.ECV ? `(${z.ECV})` : ''}
                                    </option>
                                ))}
                            </Form.Select>
                            {aktivneZmluvy.length === 0 && <div className="text-muted mt-1">Nemáte aktívne zmluvy.</div>}
                        </Form.Group>
                    </Col>
                    <Col md={6}>
                        <Form.Group controlId="datumUdalosti">
                            <Form.Label>Dátum udalosti</Form.Label>
                            <Form.Control type="date" value={datumUdalosti} onChange={(e) => setDatumUdalosti(e.target.value)} required />
                        </Form.Group>
                    </Col>
                    <Col md={12}>
                        <Form.Group controlId="popisUdalosti">
                            <Form.Label>Popis</Form.Label>
                            <Form.Control
                                as="textarea"
                                rows={3}
                                value={popisUdalosti}
                                onChange={(e) => setPopisUdalosti(e.target.value)}
                                required
                            />
                        </Form.Group>
                    </Col>
                    <Col md={12}>
                        <Button type="submit" disabled={createLoading}>
                            {createLoading ? 'Odosielam…' : 'Vytvoriť'}
                        </Button>
                    </Col>
                </Row>
                {createSuccess && <Alert className="mt-3" variant="success">Udalosť bola vytvorená.</Alert>}
                {createError && <Alert className="mt-3" variant="danger">{createError}</Alert>}
            </Form>

            <h2 className="h4 mt-4">Zoznam udalostí</h2>
            {udalosti.length === 0 ? (
                <Alert variant="secondary">Nemáte evidované žiadne poistné udalosti.</Alert>
            ) : (
                <Table striped bordered hover responsive>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Zmluva</th>
                            <th>ECV</th>
                            <th>Dátum</th>
                            <th>Stav</th>
                            <th>Popis</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        {udalosti.map((u) => (
                            <tr key={u.id_poistna_udalost ?? `${u.ECV}-${u.datum_udalosti}-${u.popis_udalosti}`}>
                                <td>{u.id_poistna_udalost ?? '-'}</td>
                                <td>{u.id_zmluva ?? '-'}</td>
                                <td>{u.ECV ?? '-'}</td>
                                <td>{formatDate(u.datum_udalosti)}</td>
                                <td>
                                    {u.stav_udalosti ? <Badge bg="success">Vyriešená</Badge> : <Badge bg="warning">Otvorená</Badge>}
                                </td>
                                <td style={{ maxWidth: 520 }}>{u.popis_udalosti}</td>
                                <td>
                                    {!u.stav_udalosti && u.id_poistna_udalost && (
                                        <Button size="sm" variant="outline-primary" onClick={() => openEdit(u)}>
                                            Upraviť
                                        </Button>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </Table>
            )}

            <Modal show={Boolean(edit)} onHide={() => (editLoading ? null : setEdit(null))}>
                <Modal.Header closeButton={!editLoading}>
                    <Modal.Title>Upraviť udalosť</Modal.Title>
                </Modal.Header>
                <Modal.Body>
                    <Form.Group className="mb-3" controlId="editDatum">
                        <Form.Label>Dátum udalosti</Form.Label>
                        <Form.Control
                            type="date"
                            value={edit?.datum || ''}
                            onChange={(e) => setEdit((prev) => ({ ...prev, datum: e.target.value }))}
                            disabled={editLoading}
                        />
                    </Form.Group>
                    <Form.Group controlId="editPopis">
                        <Form.Label>Popis</Form.Label>
                        <Form.Control
                            as="textarea"
                            rows={3}
                            value={edit?.popis || ''}
                            onChange={(e) => setEdit((prev) => ({ ...prev, popis: e.target.value }))}
                            disabled={editLoading}
                        />
                    </Form.Group>
                    {editError && <Alert className="mt-3" variant="danger">{editError}</Alert>}
                </Modal.Body>
                <Modal.Footer>
                    <Button variant="secondary" onClick={() => setEdit(null)} disabled={editLoading}>
                        Zrušiť
                    </Button>
                    <Button onClick={handleEditSave} disabled={editLoading}>
                        {editLoading ? 'Ukladám…' : 'Uložiť'}
                    </Button>
                </Modal.Footer>
            </Modal>
        </>
    );
}

export default PoistneUdalosti;
