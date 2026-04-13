import { Alert, Badge, Button, Spinner, Table } from 'react-bootstrap';
import { useEffect, useState } from 'react';
import api from '../../api.js';
import { useNavigate } from 'react-router-dom';

function AdminZiadosti() {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [ziadosti, setZiadosti] = useState([]);

    useEffect(() => {
        let cancelled = false;
        api.get('/api/admin/ziadosti')
            .then((res) => {
                if (cancelled) return;
                setZiadosti(res.data?.ziadosti || []);
            })
            .catch((err) => {
                if (cancelled) return;
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať žiadosti.');
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

    return (
        <>
            <h1>Žiadosti o zmluvu</h1>
            {ziadosti.length === 0 ? (
                <Alert variant="secondary">Nie sú žiadne čakajúce žiadosti.</Alert>
            ) : (
                <Table striped bordered hover responsive>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Klient</th>
                            <th>Typ</th>
                            <th>Dĺžka (mesiace)</th>
                            <th>Vozidlo</th>
                            <th>ECV</th>
                            <th>Stav</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        {ziadosti.map((z) => (
                            <tr key={z.id_ziadost}>
                                <td>{z.id_ziadost}</td>
                                <td>{z.nazov_firma || `${z.meno} ${z.priezvisko}`}</td>
                                <td>{z.typ_poistenia}</td>
                                <td>{z.dlzka_zmluvy_mesiace}</td>
                                <td>
                                    {z.znacka} {z.model} ({z.kat_vozidla})
                                </td>
                                <td>{z.ECV || '-'}</td>
                                <td>
                                    <Badge bg="warning">{z.stav_ziadosti}</Badge>
                                </td>
                                <td>
                                    <Button size="sm" onClick={() => navigate(`/moj-ucet/admin/ziadost/${z.id_ziadost}`)}>
                                        Otvoriť
                                    </Button>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </Table>
            )}
        </>
    );
}

export default AdminZiadosti;

