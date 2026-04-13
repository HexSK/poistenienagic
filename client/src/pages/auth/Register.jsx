import { Alert, Button, Col, Form, Row } from 'react-bootstrap';
import { useState } from 'react';
import api from '../../api.js';
import { useNavigate } from 'react-router-dom';

function Register() {
    const navigate = useNavigate();

    const [meno, setMeno] = useState('');
    const [priezvisko, setPriezvisko] = useState('');
    const [datumNarodenia, setDatumNarodenia] = useState('');
    const [rodCislo, setRodCislo] = useState('');
    const [telCislo, setTelCislo] = useState('');
    const [ulicaC, setUlicaC] = useState('');
    const [mesto, setMesto] = useState('');
    const [psc, setPsc] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [nazovFirma, setNazovFirma] = useState('');
    const [ico, setIco] = useState('');
    const [dic, setDic] = useState('');
    const [success, setSuccess] = useState(false);
    const [error, setError] = useState(null);

    const handlePassword = (heslo) => {
        if (heslo.length <= 8) {
            setError('Heslo musí byť dlhšie ako 8 znakov');
            return;
        }
        setPassword(heslo);
        setError(null);
    };

    const handleConfirmPassword = (confirmHeslo) => {
        setConfirmPassword(confirmHeslo);
        if (password && confirmHeslo !== password) {
            setError('Heslá sa nezhodujú.');
        } else {
            setError(null);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError(null);

        if (
            !meno ||
            !priezvisko ||
            !datumNarodenia ||
            !rodCislo ||
            !telCislo ||
            !ulicaC ||
            !mesto ||
            !psc ||
            !email ||
            !password ||
            !confirmPassword
        ) {
            setError('Prosím vyplňte všetky povinné polia!');
            return;
        }

        if (password !== confirmPassword) {
            setError('Heslá sa nezhodujú.');
            return;
        }

        const maFirmu = Boolean(nazovFirma || ico || dic);
        if (maFirmu && !(nazovFirma && ico && dic)) {
            setError('Ak vypĺňate firmu, zadajte aj názov firmy, IČO a DIČ.');
            return;
        }

        const typUzivatela = maFirmu ? 'kf' : 'k';

        try {
            await api.post('/api/register', {
                typ_uzivatela: typUzivatela,
                meno,
                priezvisko,
                datum_narodenia: datumNarodenia,
                rod_cislo: rodCislo,
                tel_c: telCislo,
                ulica_c: ulicaC,
                mesto,
                PSC: psc,
                email,
                password,
                nazov_firma: maFirmu ? nazovFirma : null,
                ICO: maFirmu ? ico : null,
                DIC: maFirmu ? dic : null,
            });

            setSuccess(true);
        } catch (err) {
            const serverError = err?.response?.data?.error;
            setError(serverError || 'Pri registrácii sa vyskytla chyba.');
        }
    };

    return (
        <>
            <h1>Registrácia</h1>
            <Form onSubmit={handleSubmit}>
                <Row>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerMeno">
                            <Form.Label>Meno</Form.Label>
                            <Form.Control type="text" placeholder="Vložte meno" required onChange={(e) => setMeno(e.target.value)} />
                        </Form.Group>
                    </Col>

                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerPriezvisko">
                            <Form.Label>Priezvisko</Form.Label>
                            <Form.Control
                                type="text"
                                placeholder="Vložte priezvisko"
                                required
                                onChange={(e) => setPriezvisko(e.target.value)}
                            />
                        </Form.Group>
                    </Col>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerDatumNarodenia">
                        <Form.Label>Dátum narodenia</Form.Label>
                        <Form.Control type="date" required onChange={(e) => setDatumNarodenia(e.target.value)} />
                    </Form.Group>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerRodneCislo">
                        <Form.Label>Rodné číslo</Form.Label>
                        <Form.Control type="text" placeholder="Vložte rodné číslo" required onChange={(e) => setRodCislo(e.target.value)} />
                    </Form.Group>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerTelCislo">
                        <Form.Label>Telefónne číslo</Form.Label>
                        <Form.Control
                            type="text"
                            placeholder="Vložte telefónne číslo"
                            required
                            onChange={(e) => setTelCislo(e.target.value)}
                        />
                    </Form.Group>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerAdresa">
                        <Form.Label>Adresa</Form.Label>
                        <Form.Control type="text" placeholder="Vložte adresu" required onChange={(e) => setUlicaC(e.target.value)} />
                    </Form.Group>
                </Row>

                <Row>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerMesto">
                            <Form.Label>Mesto</Form.Label>
                            <Form.Control type="text" placeholder="Vložte mesto" required onChange={(e) => setMesto(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerPsc">
                            <Form.Label>PSČ</Form.Label>
                            <Form.Control type="text" placeholder="Vložte PSČ" required onChange={(e) => setPsc(e.target.value)} />
                        </Form.Group>
                    </Col>
                </Row>
                <Row>
                    <Form.Group className="mb-3" controlId="registerEmail">
                        <Form.Label>E-mail</Form.Label>
                        <Form.Control type="email" placeholder="Vložte e-mail" required onChange={(e) => setEmail(e.target.value)} />
                    </Form.Group>
                </Row>
                <Row>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerPassword">
                            <Form.Label>Heslo</Form.Label>
                            <Form.Control type="password" placeholder="Vložte heslo" required onChange={(e) => handlePassword(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerConfirmPassword">
                            <Form.Label>Potvrdiť heslo</Form.Label>
                            <Form.Control
                                type="password"
                                placeholder="Potvrďte heslo"
                                required
                                onChange={(e) => handleConfirmPassword(e.target.value)}
                            />
                        </Form.Group>
                    </Col>
                </Row>

                <hr />
                <h2 className="h5">Firma (voliteľné)</h2>
                <Row>
                    <Form.Group className="mb-3" controlId="registerFirm">
                        <Form.Label>Názov firmy</Form.Label>
                        <Form.Control type="text" placeholder="Vložte názov firmy" onChange={(e) => setNazovFirma(e.target.value)} />
                    </Form.Group>
                </Row>
                <Row>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerIco">
                            <Form.Label>IČO</Form.Label>
                            <Form.Control type="text" placeholder="Vložte IČO" onChange={(e) => setIco(e.target.value)} />
                        </Form.Group>
                    </Col>
                    <Col md={6}>
                        <Form.Group className="mb-3" controlId="registerDic">
                            <Form.Label>DIČ</Form.Label>
                            <Form.Control type="text" placeholder="Vložte DIČ" onChange={(e) => setDic(e.target.value)} />
                        </Form.Group>
                    </Col>
                </Row>

                <Button type="submit" className="w-100">
                    Registrovať
                </Button>
            </Form>

            {success && (
                <Alert className="mt-3" variant="success">
                    Registrácia prebehla úspešne.{' '}
                    <Button variant="link" onClick={() => navigate('/login')}>
                        Prihlásiť sa
                    </Button>
                </Alert>
            )}
            {error && (
                <Alert className="mt-3" variant="danger">
                    {error}
                </Alert>
            )}
        </>
    );
}

export default Register;

