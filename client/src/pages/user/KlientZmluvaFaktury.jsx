import { Alert, Badge, Button, Spinner, Table } from 'react-bootstrap';
import { useEffect, useMemo, useState } from 'react';
import api from '../../api.js';
import { useNavigate, useParams } from 'react-router-dom';
import { formatDate, formatMoneyEur } from '../../utils/format.js';

function KlientZmluvaFaktury() {
    const navigate = useNavigate();
    const { id_zmluva } = useParams();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [faktury, setFaktury] = useState([]);
    const [zmluva, setZmluva] = useState(null);

    useEffect(() => {
        let cancelled = false;
        const run = async () => {
            setLoading(true);
            setError(null);
            try {
                const [zmluvaRes, fakturyRes] = await Promise.all([
                    api.get(`/api/zmluva/${id_zmluva}`),
                    api.get(`/api/zmluva/${id_zmluva}/faktury`),
                ]);
                if (cancelled) return;
                const rows = zmluvaRes.data?.zmluvy;
                setZmluva(Array.isArray(rows) ? rows[0] : rows);
                setFaktury(fakturyRes.data?.faktury || []);
            } catch (err) {
                if (cancelled) return;
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať faktúry.');
            } finally {
                if (!cancelled) setLoading(false);
            }
        };

        run();

        return () => {
            cancelled = true;
        };
    }, [id_zmluva]);

    const prvaNezapl = useMemo(() => faktury.find((f) => !f.datum_zaplatenia), [faktury]);

    if (loading) return <Spinner animation="border" />;
    if (error) return <Alert variant="danger">{error}</Alert>;

    return (
        <>
            <h1>Faktúry – zmluva #{id_zmluva}</h1>

            {zmluva?.stav_zmluvy === 'vytvorena' && prvaNezapl?.id_faktura && (
                <Alert variant="warning" className="d-flex align-items-center justify-content-between flex-wrap gap-2">
                    <div>Zmluva sa aktivuje po zaplatení prvej faktúry.</div>
                    <Button size="sm" onClick={() => navigate(`/moj-ucet/zmluva/${id_zmluva}/faktura/${prvaNezapl.id_faktura}/zaplat`)}>
                        Zaplatiť (faktúra #{prvaNezapl.id_faktura})
                    </Button>
                </Alert>
            )}

            {faktury.length === 0 ? (
                <Alert variant="secondary">K zmluve nie sú evidované faktúry.</Alert>
            ) : (
                <Table striped bordered hover responsive>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Číslo</th>
                            <th>Vystavenie</th>
                            <th>Splatnosť</th>
                            <th>Zaplatené</th>
                            <th>Suma</th>
                            <th>Platba</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        {faktury.map((f) => (
                            <tr key={f.id_faktura}>
                                <td>{f.id_faktura}</td>
                                <td>{f.cislo_faktura}</td>
                                <td>{formatDate(f.datum_vystavenia)}</td>
                                <td>{formatDate(f.datum_splatnosti)}</td>
                                <td>
                                    {f.datum_zaplatenia ? formatDate(f.datum_zaplatenia) : <Badge bg="warning">Nezaplatené</Badge>}
                                </td>
                                <td>{formatMoneyEur(f.suma)}</td>
                                <td>{f.typ_platby || '-'}</td>
                                <td className="d-flex gap-2">
                                    <button
                                        className="btn btn-sm btn-outline-secondary"
                                        onClick={() => navigate(`/moj-ucet/zmluva/${id_zmluva}/faktura/${f.id_faktura}`)}
                                    >
                                        Detail
                                    </button>
                                    {!f.datum_zaplatenia && (
                                        <button
                                            className="btn btn-sm btn-primary"
                                            onClick={() => navigate(`/moj-ucet/zmluva/${id_zmluva}/faktura/${f.id_faktura}/zaplat`)}
                                        >
                                            Zaplatiť
                                        </button>
                                    )}
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </Table>
            )}
        </>
    );
}

export default KlientZmluvaFaktury;
