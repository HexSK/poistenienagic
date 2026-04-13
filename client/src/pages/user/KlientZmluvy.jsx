import { Alert, Badge, Spinner, Table } from 'react-bootstrap';
import { useEffect, useState } from 'react';
import api from '../../api.js';
import { formatDate, formatMoneyEur } from '../../utils/format.js';
import { useNavigate } from 'react-router-dom';

function statusVariant(stav) {
    if (stav === 'aktivna') return 'success';
    if (stav === 'vytvorena') return 'warning';
    return 'secondary';
}

function KlientZmluvy() {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);
    const [data, setData] = useState(null);

    useEffect(() => {
        let cancelled = false;
        api.get('/api/zmluvy')
            .then((res) => {
                if (cancelled) return;
                setData(res.data);
            })
            .catch((err) => {
                if (cancelled) return;
                setError(err?.response?.data?.error || 'Nepodarilo sa načítať zmluvy.');
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

    const statistika = data?.statistika || {};
    const zmluvy = data?.klient_zmluvy || [];

    return (
        <>
            <h1>Zmluvy</h1>
            <Alert variant="secondary">
                Aktívne: <strong>{statistika.aktivne_zmluvy ?? 0}</strong> | Expírované: <strong>{statistika.expirovane_zmluvy ?? 0}</strong> | Zrušené:{' '}
                <strong>{statistika.zrusene_zmluvy ?? 0}</strong> | Vytvorené (nezaplatené): <strong>{statistika.vytvorene_nezaplatene_zmluvy ?? 0}</strong>
            </Alert>

            {zmluvy.length === 0 ? (
                <Alert variant="secondary">Nemáte žiadne zmluvy.</Alert>
            ) : (
                <Table striped bordered hover responsive>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>ECV</th>
                            <th>VIN</th>
                            <th>Kategória</th>
                            <th>Začiatok</th>
                            <th>Koniec</th>
                            <th>Cena poistného</th>
                            <th>Stav</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        {zmluvy.map((z) => (
                            <tr key={z.id_zmluva ?? `${z.ECV}-${z.VIN}-${z.datum_zaciatku}`}>
                                <td>{z.id_zmluva ?? '-'}</td>
                                <td>{z.ECV ?? '-'}</td>
                                <td>{z.VIN ?? '-'}</td>
                                <td>{z.kat_vozidla ?? '-'}</td>
                                <td>{formatDate(z.datum_zaciatku)}</td>
                                <td>{formatDate(z.datum_konca)}</td>
                                <td>{formatMoneyEur(z.cena_poistneho)}</td>
                                <td>
                                    <Badge bg={statusVariant(z.stav_zmluvy)}>{z.stav_zmluvy}</Badge>
                                </td>
                                <td className="d-flex gap-2 flex-wrap">
                                    {z.id_zmluva && (
                                        <>
                                            <button className="btn btn-sm btn-outline-secondary" onClick={() => navigate(`/moj-ucet/zmluva/${z.id_zmluva}`)}>
                                                Detail
                                            </button>
                                            <button className="btn btn-sm btn-primary" onClick={() => navigate(`/moj-ucet/zmluva/${z.id_zmluva}/faktury`)}>
                                                Faktúry
                                            </button>
                                        </>
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

export default KlientZmluvy;

