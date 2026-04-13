import { Alert, Badge, Button, Card, Spinner } from 'react-bootstrap';
import { useEffect, useMemo, useState } from 'react';
import api from '../../api.js';
import { useNavigate, useParams } from 'react-router-dom';
import { formatDate, formatMoneyEur } from '../../utils/format.js';

function KlientZmluva() {
    const navigate = useNavigate();
    const { id_zmluva } = useParams();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [zmluva, setZmluva] = useState(null);
    const [faktury, setFaktury] = useState([]);

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
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať zmluvu.');
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
    if (!zmluva) return <Alert variant="secondary">Zmluva neexistuje.</Alert>;

    return (
        <>
            <h1>Zmluva #{id_zmluva}</h1>

            {zmluva.stav_zmluvy === 'vytvorena' && (
                <Alert variant="warning">
                    Zmluva zatiaľ nie je aktívna. Aktivuje sa po zaplatení prvej faktúry.
                </Alert>
            )}

            <Card className="mb-3">
                <Card.Body>
                    <div className="mb-2">
                        Stav:{' '}
                        <Badge bg={zmluva.stav_zmluvy === 'aktivna' ? 'success' : zmluva.stav_zmluvy === 'vytvorena' ? 'warning' : 'secondary'}>
                            {zmluva.stav_zmluvy}
                        </Badge>
                    </div>
                    <div>Začiatok: {formatDate(zmluva.datum_zaciatku)}</div>
                    <div>Koniec: {formatDate(zmluva.datum_konca)}</div>
                    <div>Cena poistného: {formatMoneyEur(zmluva.cena_poistneho)}</div>
                    <hr />
                    <div>
                        Vozidlo: {zmluva.znacka} {zmluva.model} | {zmluva.kat_vozidla}
                    </div>
                    <div>ECV: {zmluva.ECV || '-'}</div>
                    <div>VIN: {zmluva.VIN || '-'}</div>
                    <div>Číslo motora: {zmluva.cislo_motora || '-'}</div>
                    <div>Počet udalostí: {zmluva.pocet_udalosti ?? 0}</div>
                </Card.Body>
            </Card>

            <div className="d-flex gap-2 flex-wrap">
                <Button variant="outline-secondary" onClick={() => navigate(`/moj-ucet/zmluva/${id_zmluva}/faktury`)}>
                    Faktúry
                </Button>
                {prvaNezapl?.id_faktura && (
                    <Button onClick={() => navigate(`/moj-ucet/zmluva/${id_zmluva}/faktura/${prvaNezapl.id_faktura}/zaplat`)}>
                        Zaplatiť zmluvu (faktúra #{prvaNezapl.id_faktura})
                    </Button>
                )}
            </div>
        </>
    );
}

export default KlientZmluva;
