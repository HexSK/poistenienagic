import { Alert, Button, Form, Spinner } from 'react-bootstrap';
import { useState } from 'react';
import api from '../../api.js';
import { useNavigate, useParams } from 'react-router-dom';

function ZaplatFakturu() {
    const navigate = useNavigate();
    const { id_zmluva, id_faktura } = useParams();
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const [success, setSuccess] = useState(false);
    const [typPlatby, setTypPlatby] = useState('karta');

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null);
        setSuccess(false);
        setLoading(true);
        try {
            await api.post(`/api/faktura/${id_faktura}/zaplat`, { typ_platby: typPlatby });
            setSuccess(true);
            setTimeout(() => navigate(`/moj-ucet/zmluva/${id_zmluva}/faktura/${id_faktura}`), 400);
        } catch (err) {
            setError(err?.response?.data?.error || 'Platba zlyhala.');
        } finally {
            setLoading(false);
        }
    };

    return (
        <>
            <h1>Zaplatiť faktúru #{id_faktura}</h1>
            <Alert variant="secondary">Po zaplatení sa zmluva môže automaticky aktivovať (pri prvej faktúre).</Alert>
            <Form onSubmit={handleSubmit}>
                <Form.Group className="mb-3" controlId="typPlatby">
                    <Form.Label>Typ platby</Form.Label>
                    <Form.Select value={typPlatby} onChange={(e) => setTypPlatby(e.target.value)}>
                        <option value="karta">Karta</option>
                        <option value="prevod">Bankový prevod</option>
                        <option value="hotovost">Hotovosť</option>
                    </Form.Select>
                </Form.Group>

                <Button type="submit" disabled={loading}>
                    {loading ? <Spinner size="sm" animation="border" /> : 'Zaplatiť'}
                </Button>
                <Button className="ms-2" variant="secondary" onClick={() => navigate(-1)} disabled={loading}>
                    Späť
                </Button>
            </Form>

            {success && <Alert className="mt-3" variant="success">Faktúra bola zaplatená.</Alert>}
            {error && <Alert className="mt-3" variant="danger">{error}</Alert>}
        </>
    );
}

export default ZaplatFakturu;

