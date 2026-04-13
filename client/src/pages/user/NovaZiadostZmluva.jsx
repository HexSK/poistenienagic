import { Alert, Button, Col, Form, Row, Spinner } from 'react-bootstrap';
import { useState } from 'react';
import api from '../../api.js';
import { useNavigate } from 'react-router-dom';

function NovaZiadostZmluva() {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(false);

    const [typPoistenia, setTypPoistenia] = useState('PZP');
    const [dlzka, setDlzka] = useState(12);
    const [datumZaciatku, setDatumZaciatku] = useState('');
    const [znacka, setZnacka] = useState('');
    const [model, setModel] = useState('');
    const [katVozidla, setKatVozidla] = useState('A');
    const [ecv, setEcv] = useState('');
    const [vin, setVin] = useState('');
    const [cisloMotora, setCisloMotora] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null);
        setSuccess(false);
        setLoading(true);
        try {
            await api.post('/api/zmluva/nova-ziadost', {
                typ_poistenia: typPoistenia,
                dlzka_zmluvy_mesiace: Number(dlzka),
                datum_zaciatku_zmluvy: datumZaciatku,
                znacka,
                model,
                kat_vozidla: katVozidla,
                ECV: ecv || null,
                VIN: vin || null,
                cislo_motora: cisloMotora || null,
            });
            setSuccess(true);
            setTimeout(() => navigate('/moj-ucet'), 500);
        } catch (err) {
            setError(err?.response?.data?.error || 'Žiadosť sa nepodarilo odoslať.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <>
            <h1>Nová žiadosť o zmluvu</h1>
            <Form onSubmit={handleSubmit}>
                <Row className="g-3">
                    <Col md={4}>
                        <Form.Group controlId="typPoistenia">
                            <Form.Label>Typ poistenia</Form.Label>
                            <Form.Select value={typPoistenia} onChange={(e) => setTypPoistenia(e.target.value)}>
                                <option value="PZP">PZP</option>
                                <option value="PZP+">PZP+</option>
                            </Form.Select>
                        </Form.Group>
                    </Col>
                    <Col md={4}>
                        <Form.Group controlId="dlzka">
                            <Form.Label>Dĺžka zmluvy (mesiace)</Form.Label>
                            <Form.Control type="number" min={1} max={24} value={dlzka} onChange={(e) => setDlzka(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={4}>
                        <Form.Group controlId="datumZaciatku">
                            <Form.Label>Dátum začiatku</Form.Label>
                            <Form.Control type="date" value={datumZaciatku} onChange={(e) => setDatumZaciatku(e.target.value)} required />
                        </Form.Group>
                    </Col>

                    <Col md={4}>
                        <Form.Group controlId="znacka">
                            <Form.Label>Značka</Form.Label>
                            <Form.Control value={znacka} onChange={(e) => setZnacka(e.target.value)} required />
                        </Form.Group>
                    </Col>
                    <Col md={4}>
                        <Form.Group controlId="model">
                            <Form.Label>Model</Form.Label>
                            <Form.Control value={model} onChange={(e) => setModel(e.target.value)} required />
                        </Form.Group>
                    </Col>

                    <Col md={4}>
                        <Form.Group controlId="katVozidla">
                            <Form.Label>Kategória vozidla</Form.Label>
                            <Form.Select value={katVozidla} onChange={(e) => setKatVozidla(e.target.value)}>
                                <option value="A">A (osobné)</option>
                                <option value="B">B (motocykel)</option>
                                <option value="C">C (nákladné)</option>
                                <option value="D">D (bicykel s pomocným motorom)</option>
                                <option value="E">E (bus)</option>
                                <option value="F">F (príves)</option>
                                <option value="G">G (iné)</option>
                            </Form.Select>
                        </Form.Group>
                    </Col>
                    <Col md={4}>
                        <Form.Group controlId="ecv">
                            <Form.Label>ECV (voliteľné)</Form.Label>
                            <Form.Control value={ecv} onChange={(e) => setEcv(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={4}>
                        <Form.Group controlId="vin">
                            <Form.Label>VIN (voliteľné)</Form.Label>
                            <Form.Control value={vin} onChange={(e) => setVin(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={4}>
                        <Form.Group controlId="cisloMotora">
                            <Form.Label>Číslo motora (voliteľné)</Form.Label>
                            <Form.Control value={cisloMotora} onChange={(e) => setCisloMotora(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={12}>
                        <Button type="submit" disabled={loading}>
                            {loading ? <Spinner size="sm" animation="border" /> : 'Odoslať žiadosť'}
                        </Button>
                        <Button className="ms-2" variant="secondary" onClick={() => navigate(-1)} disabled={loading}>
                            Späť
                        </Button>
                    </Col>
                </Row>
            </Form>

            {success && <Alert className="mt-3" variant="success">Žiadosť bola odoslaná.</Alert>}
            {error && <Alert className="mt-3" variant="danger">{error}</Alert>}
        </>
    );
}

export default NovaZiadostZmluva;

