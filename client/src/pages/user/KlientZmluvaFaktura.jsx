import { Alert, Badge, Button, Card, Spinner } from 'react-bootstrap';
import { useEffect, useMemo, useState } from 'react';
import api from '../../api.js';
import { useNavigate, useParams } from 'react-router-dom';
import { formatDate, formatMoneyEur } from '../../utils/format.js';

function KlientZmluvaFaktura() {
    const navigate = useNavigate();
    const { id_zmluva, id_faktura } = useParams();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [faktury, setFaktury] = useState([]);

    useEffect(() => {
        let cancelled = false;
        const run = async () => {
            setLoading(true);
            setError(null);
            try {
                const res = await api.get(`/api/zmluva/${id_zmluva}/faktury`);
                if (cancelled) return;
                setFaktury(res.data?.faktury || []);
            } catch (err) {
                if (cancelled) return;
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať faktúru.');
            } finally {
                if (!cancelled) setLoading(false);
            }
        };

        run();

        return () => {
            cancelled = true;
        };
    }, [id_zmluva]);

    const faktura = useMemo(() => faktury.find((f) => String(f.id_faktura) === String(id_faktura)), [faktury, id_faktura]);

    if (loading) return <Spinner animation="border" />;
    if (error) return <Alert variant="danger">{error}</Alert>;
    if (!faktura) return <Alert variant="secondary">Faktúra neexistuje.</Alert>;

    const jeZapl = Boolean(faktura.datum_zaplatenia);

    return (
        <>
            <h1>Faktúra #{id_faktura}</h1>

            {!jeZapl && <Alert variant="info">Po zaplatení faktúry môže dôjsť k aktivácii zmluvy (ak ide o prvú faktúru).</Alert>}

            <Card className="mb-3">
                <Card.Body>
                    <div>Zmluva: #{id_zmluva}</div>
                    <div>Číslo faktúry: {faktura.cislo_faktura}</div>
                    <div>Dátum vystavenia: {formatDate(faktura.datum_vystavenia)}</div>
                    <div>Dátum splatnosti: {formatDate(faktura.datum_splatnosti)}</div>
                    <div>Suma: {formatMoneyEur(faktura.suma)}</div>
                    <div>Typ platby: {faktura.typ_platby || '-'}</div>
                    <div>
                        Stav: {jeZapl ? <Badge bg="success">Zaplatená</Badge> : <Badge bg="warning">Nezaplatená</Badge>}
                    </div>
                    {faktura.datum_zaplatenia && <div>Dátum zaplatenia: {formatDate(faktura.datum_zaplatenia)}</div>}
                    {faktura.poznamka && <div>Poznámka: {faktura.poznamka}</div>}
                </Card.Body>
            </Card>

            {!jeZapl && (
                <Button onClick={() => navigate(`/moj-ucet/zmluva/${id_zmluva}/faktura/${id_faktura}/zaplat`)}>Zaplatiť faktúru</Button>
            )}
            <Button className="ms-2" variant="secondary" onClick={() => navigate(`/moj-ucet/zmluva/${id_zmluva}/faktury`)}>
                Späť na faktúry
            </Button>
        </>
    );
}

export default KlientZmluvaFaktura;
