import { Alert, Badge, Button, Card, Form, Spinner } from 'react-bootstrap';
import { useEffect, useState } from 'react';
import api from '../../api.js';
import { useNavigate, useParams } from 'react-router-dom';

function AdminZiadost() {
    const navigate = useNavigate();
    const { id_ziadost } = useParams();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [ziadost, setZiadost] = useState(null);
    const [actionLoading, setActionLoading] = useState(false);
    const [sprava, setSprava] = useState('');

    useEffect(() => {
        let cancelled = false;
        api.get(`/api/admin/ziadost/${id_ziadost}`)
            .then((res) => {
                if (cancelled) return;
                setZiadost(res.data?.ziadost || null);
            })
            .catch((err) => {
                if (cancelled) return;
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať žiadosť.');
            })
            .finally(() => {
                if (cancelled) return;
                setLoading(false);
            });
        return () => {
            cancelled = true;
        };
    }, [id_ziadost]);

    const prijat = async () => {
        setActionLoading(true);
        setError(null);
        try {
            await api.post(`/api/admin/zmluva/prijat-ziadost/${id_ziadost}`);
            navigate('/moj-ucet/admin/ziadosti');
        } catch (err) {
            setError(err?.response?.data?.error || 'Žiadosť sa nepodarilo prijať.');
        } finally {
            setActionLoading(false);
        }
    };

    const odmietnut = async () => {
        setActionLoading(true);
        setError(null);
        try {
            await api.post(`/api/admin/zmluva/odmietnut-ziadost/${id_ziadost}`, { sprava });
            navigate('/moj-ucet/admin/ziadosti');
        } catch (err) {
            setError(err?.response?.data?.error || 'Žiadosť sa nepodarilo odmietnuť.');
        } finally {
            setActionLoading(false);
        }
    };

    if (loading) return <Spinner animation="border" />;
    if (error) return <Alert variant="danger">{error}</Alert>;
    if (!ziadost) return <Alert variant="secondary">Žiadosť neexistuje.</Alert>;

    return (
        <>
            <h1>Žiadosť #{id_ziadost}</h1>
            <Card className="mb-3">
                <Card.Body>
                    <div>
                        Stav: <Badge bg="warning">{ziadost.stav_ziadosti}</Badge>
                    </div>
                    <div>Typ poistenia: {ziadost.typ_poistenia}</div>
                    <div>Dĺžka (mesiace): {ziadost.dlzka_zmluvy_mesiace}</div>
                    <div>Dátum začiatku: {String(ziadost.datum_zaciatku_zmluvy || '-')}</div>
                    <hr />
                    <div>
                        Vozidlo: {ziadost.znacka} {ziadost.model} ({ziadost.kat_vozidla})
                    </div>
                    <div>ECV: {ziadost.ECV || '-'}</div>
                    <div>VIN: {ziadost.VIN || '-'}</div>
                    <div>Číslo motora: {ziadost.cislo_motora || '-'}</div>
                </Card.Body>
            </Card>

            <Button onClick={prijat} disabled={actionLoading}>
                {actionLoading ? 'Spracúvam…' : 'Prijať žiadosť'}
            </Button>
            <Button className="ms-2" variant="danger" onClick={odmietnut} disabled={actionLoading}>
                {actionLoading ? 'Spracúvam…' : 'Odmietnuť'}
            </Button>

            <Form className="mt-3">
                <Form.Group controlId="sprava">
                    <Form.Label>Správa (voliteľné)</Form.Label>
                    <Form.Control as="textarea" rows={3} value={sprava} onChange={(e) => setSprava(e.target.value)} />
                </Form.Group>
            </Form>
        </>
    );
}

export default AdminZiadost;

