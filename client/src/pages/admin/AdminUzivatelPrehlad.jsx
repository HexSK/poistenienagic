import { Alert, Badge, Button, Spinner, Table } from 'react-bootstrap';
import { useEffect, useMemo, useState } from 'react';
import api from '../../api.js';
import { useNavigate, useParams } from 'react-router-dom';
import { formatDate, formatMoneyEur } from '../../utils/format.js';

function AdminUzivatelPrehlad() {
    const navigate = useNavigate();
    const { id_uzivatel } = useParams();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [rows, setRows] = useState([]);
    const [deleteLoading, setDeleteLoading] = useState(false);

    useEffect(() => {
        let cancelled = false;
        api.get(`/api/admin/prehlad/uzivatel/${id_uzivatel}`)
            .then((res) => {
                if (cancelled) return;
                setRows(res.data?.admin_prehlad_uzivatel_detaily || []);
            })
            .catch((err) => {
                if (cancelled) return;
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať používateľa.');
            })
            .finally(() => {
                if (cancelled) return;
                setLoading(false);
            });
        return () => {
            cancelled = true;
        };
    }, [id_uzivatel]);

    const user = useMemo(() => rows[0], [rows]);

    const handleDelete = async () => {
        if (!confirm(`Naozaj chcete vymazať používateľa #${id_uzivatel}?`)) return;
        setDeleteLoading(true);
        setError(null);
        try {
            await api.delete(`/api/admin/prehlad/uzivatel/${id_uzivatel}`);
            navigate('/moj-ucet/admin/prehlad');
        } catch (err) {
            setError(err?.response?.data?.error || 'Nepodarilo sa vymazať používateľa.');
        } finally {
            setDeleteLoading(false);
        }
    };

    if (loading) return <Spinner animation="border" />;
    if (error) return <Alert variant="danger">{error}</Alert>;
    if (!user) return <Alert variant="secondary">Používateľ nemá žiadne záznamy.</Alert>;

    return (
        <>
            <h1>Používateľ #{id_uzivatel}</h1>
            <Alert variant="secondary">
                {user.nazov_firma ? (
                    <>
                        Firma: <strong>{user.nazov_firma}</strong>
                    </>
                ) : (
                    <>
                        Meno: <strong>{user.meno} {user.priezvisko}</strong>
                    </>
                )}
            </Alert>

            <Button variant="danger" onClick={handleDelete} disabled={deleteLoading}>
                {deleteLoading ? 'Mažem…' : 'Vymazať používateľa'}
            </Button>

            <h2 className="h4 mt-4">Zmluvy</h2>
            <Table striped bordered hover responsive>
                <thead>
                    <tr>
                        <th>ID zmluvy</th>
                        <th>ECV</th>
                        <th>VIN</th>
                        <th>Kategória</th>
                        <th>Začiatok</th>
                        <th>Koniec</th>
                        <th>Cena poistného</th>
                        <th>Stav</th>
                    </tr>
                </thead>
                <tbody>
                    {rows.map((r) => (
                        <tr key={`${r.id_zmluva}-${r.id_vozidlo}`}>
                            <td>{r.id_zmluva}</td>
                            <td>{r.ECV}</td>
                            <td>{r.VIN}</td>
                            <td>{r.kat_vozidla}</td>
                            <td>{formatDate(r.datum_zaciatku)}</td>
                            <td>{formatDate(r.datum_konca)}</td>
                            <td>{formatMoneyEur(r.cena_poistneho)}</td>
                            <td>
                                <Badge bg={r.stav_zmluvy === 'aktivna' ? 'success' : 'secondary'}>{r.stav_zmluvy}</Badge>
                            </td>
                        </tr>
                    ))}
                </tbody>
            </Table>
        </>
    );
}

export default AdminUzivatelPrehlad;

